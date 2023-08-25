function [H,V,A,D,R,L,S0,S1,S2,S3] = PolCameraStokes(frame, resetOverlap)
%POLCAMERASTOKES Expects a "split" image, with a beam on each half of the
%frame. On the right half should be the original beam (for H,V,A,D for be
%measured). The the left half should have a copy of the beam that has been
%passed through a QWP at 90 degrees. (might be opposite, physically)
%
%This function automatically does an optimal overlap between the beams,
%which is computationally intensive. The overlap is cached and must be
%reset manually if the setup alignment is changed.
%
% TODO: Add region of interest support.
%
% frame         : The camera frame to be computed.
% resetOverlap  : Reset the overlap calculation if the setup is changed.
%                 Don't run this every time - it's very very slow (minutes).

debug = false; %set to true to get more info

global crr;

if nargin > 1
    if resetOverlap
        crr = [];
        fprintf('Deleting cached overlap. Do not do this unnecessarily!\n');
        debug = true;
    end
end


%Figure out separation between left and right halves ----------------------
%Find the correlation between left and right and split
%We do this on S0 since the left and right are most similar
%From https://www.mathworks.com/help/signal/ref/xcorr2.html

sframe = single(frame); % no need to use double, which is slower

% WARNING: Encoding alignment should be ok since frame is even size. Check this if
% it seems broken.
sframeleft = sframe(:, 1:size(sframe,2)/2);
sframeright = sframe(:, size(sframe,2)/2+1:end);

if isempty(crr)
    fprintf('Please wait while the overlap is computed... This will take a few minutes.\n');
    crr = xcorr2(sframeleft, sframeright); % this takes a few seconds
else
    fprintf('Using cached value. If you need to recalc, set resetOverlap to true, once.\n')
end

[~,snd] = max(crr(:));
[ypeak,xpeak] = ind2sub(size(crr),snd);
corr_offset = [(ypeak-size(sframeleft,1)) (xpeak-size(sframeleft,2))];

if debug
    fprintf('Done! Offset is [%d,%d]. Enjoy :)\n', corr_offset(1), corr_offset(2));
end

%keep right, and overlay the left on top
%pad with lots of zeros and then clip out the part we need

%the clip is the coordinate of the unpadded matrix, shifted by the offset
rowColClip = abs(corr_offset) + corr_offset;

compositeBefore = cat(3, sframeleft, zeros(size(sframeleft)), sframeright);

sframeleftPadded = padarray(sframeleft, abs(corr_offset), 0, 'both');
sframeleft = sframeleftPadded((rowColClip(1)+1):rowColClip(1)+size(sframeright,1), (rowColClip(2)+1):rowColClip(2)+size(sframeright,2));

compositeAfter = cat(3, sframeleft, zeros(size(sframeleft)), sframeright);

% Debug the overlap
if debug
    figure;
    set(gca,'dataAspectRatio',[1 1 1]);
    subplot(1,2,1);
    imagesc(compositeBefore);
    title('Overlap without compensation');
    subplot(1,2,2);
    imagesc(compositeAfter);
    title('Overlap after compensation');
end

% Separate out the different polarisations
% Encoding is [90 45; 135 0]
% Note that the sframeright is as it is on the camera and the left is moved
% to overlap nicely.

V = sframeright(1:2:end, 1:2:end);
H = sframeright(2:2:end, 2:2:end);
D = sframeright(1:2:end, 2:2:end);
A = sframeright(2:2:end, 1:2:end);
R = sframeleft(1:2:end, 2:2:end);
L = sframeleft(2:2:end, 1:2:end);

% Reduced stokes
S0 = R + L;
S1 = 2*H - S0;
S2 = 2*D - S0;
S3 = R - L;

if debug
    frameTop = [V D S0 S1];
    frameBot = [A H S2 S3];
    frameComposition = vertcat(frameTop, frameBot);

    frameRows = size(frame,1)/2;
    frameCols = size(frame,2)/4; %because we split left and right

    figure;
    imagesc(frameComposition);
    set(gca,'dataAspectRatio',[1 1 1]);
    set(gca,'color','none');
    set(gcf,'ToolBar','none');
    set(gca, 'Units', 'normalized', 'Position', [0.01 .01 0.98 0.96])
    text(20,20,'V','Color','white');
    text(20+frameCols,20,'D','Color','white');
    text(20,20+frameRows,'A','Color','white');
    text(20+frameCols,20+frameRows,'H','Color','white');
    
    text(20+2*frameCols,20,'S0','Color','white');
    text(20+3*frameCols,20,'S1','Color','white');
    text(20+2*frameCols,20+frameRows,'S2','Color','white');
    text(20+3*frameCols,20+frameRows,'S3','Color','white');
end

end


function [] = CameraPreviewStokes(vid, viewAll, movAveNumFrames, minMax)
%CAMERAPREVIEW An enhanced camera preview function with some cool features
% as documented below.
%   vid :       An initialised camera object with ROI, exposure, etc. set up.
%   movAveNumFrames :   Default = 1, display a moving average rather than
%                       frame by frame.
%   minMax :    Default [0 255] but other options could be [0 1023]
%   viewAll :   Default = false, if false only shows stokes.
%
%   Hit p then ENTER to save a screenshot and matrices.
%
%   Created by Mitchell A. Cox, mitchell.cox@wits.ac.za, 2023
%
%   Shortcut: v = videoinput("gige", 1, "Mono12");

if nargin < 3
    movAveNumFrames = 1;
end

if nargin < 4
    autoMinMax = true;
    minMax = [0 255];
else
    autoMinMax = false;
end

if nargin < 2
    viewAll = false;
end

global crr

%check if camera is started
if ~isa(vid, 'uint8') %if we pass a frame matrix into vid, use that for testing

    if isrunning(vid)
        stop(vid);
    end

    triggerconfig(vid, 'manual');

    if ~isrunning(vid)
        start(vid);
    end

    frame = getsnapshot(vid); %TODO use resolution rather than a snapshot

else
    frame = vid;
end

% Frame buffer ------------------------------------------------------------

framesBuffer = zeros(size(frame,1), size(frame,2), movAveNumFrames);
bufferHead = 1; %when this is > length then wraps back to 1 (circular buffer)

if autoMinMax == true
    maxVal = max(frame(:));
    if maxVal > 255
        minMax = [0 1023]; %maybe its 10 bits

        if max(max(frame)) > 1023
            minMax = [0 4095]; %but... maybe its 12 bits
        end
    end
end

%Figure out separation between left and right halves ----------------------
%Find the correlation between left and right and split
%We do this on S0 since the left and right are most similar
%From https://www.mathworks.com/help/signal/ref/xcorr2.html
fprintf('Please wait while the overlap is computed... This will take up to a minute.\n');
frameV = frame(1:2:end, 1:2:end);
frameH = frame(2:2:end, 2:2:end);
s0 = single(frame);% + single(frameH);

s0left = s0(:, 1:size(s0,2)/2);
s0right = s0(:, size(s0,2)/2+1:end);

freshCrr = false;
if isempty(crr)
    freshCrr = true;
    crr = xcorr2(s0left, s0right); % this takes a few seconds
else
    fprintf('Using cached value. If you need to recalc, run "clear(''global'',''crr'')" in the console.\n')
end
[~,snd] = max(crr(:));
[ypeak,xpeak] = ind2sub(size(crr),snd);
corr_offset = [(ypeak-size(s0left,1)) (xpeak-size(s0left,2))];

fprintf('Done! Offset is [%d,%d]. Enjoy :)\n', corr_offset(1), corr_offset(2));

%keep right, and overlay the left on top
%pad with lots of zeros and then clip out the part we need

s0leftPadded = padarray(s0left, abs(corr_offset), 0, 'both');

%the clip is the coordinate of the unpadded matrix, shifted by the offset
rowColClip = abs(corr_offset) + corr_offset;

compositeBefore = cat(3, s0left, zeros(size(s0left)), s0right) / minMax(2);

s0left = s0leftPadded((rowColClip(1)+1):rowColClip(1)+size(s0right,1), (rowColClip(2)+1):rowColClip(2)+size(s0right,2));

compositeAfter = cat(3, s0left, zeros(size(s0left)), s0right) / minMax(2);

% Debug the overlap
if freshCrr && 0
    figure;
    set(gca,'dataAspectRatio',[1 1 1]);
    subplot(1,2,1);
    imagesc(compositeBefore);
    title('Overlap without compensation');
    subplot(1,2,2);
    imagesc(compositeAfter);
    title('Overlap after compensation');
end


% Setup the window --------------------------------------------------------

h = figure('name','Polarisation Camera Preview (#ProTip: Run this in dedicated MATLAB instance)','NumberTitle','off');

% Create a nice colourmap:
negativeColormap = [zeros(1,130), linspace(0,1,126)];
positiveColormap = [linspace(1,0,126), zeros(1,130)];
cm = [positiveColormap; negativeColormap; zeros(1,256)]';

frameRows = size(frame,1)/2;
frameCols = size(frame,2)/4; %because we split left and right

if viewAll
    viewport = zeros(frameRows*2, frameCols*2*2);
else
    viewport = zeros(frameRows*2, frameCols*2);
end

p1 = imshow(viewport,[-1 1],'colormap',cm,'Border','tight');
set(gca,'dataAspectRatio',[1 1 1]);
set(gca,'color','none');
set(gcf,'ToolBar','none');
set(gca, 'Units', 'normalized', 'Position', [0.01 .01 0.98 0.96])
colorbar;

set(h,'CurrentCharacter','@'); %for checking keypresses later

if viewAll
    text(20,20,'V','Color','white');
    text(20+frameCols,20,'D','Color','white');
    text(20,20+frameRows,'A','Color','white');
    text(20+frameCols,20+frameRows,'H','Color','white');

    text(20+2*frameCols,20,'S0','Color','white');
    text(20+3*frameCols,20,'S1','Color','white');
    text(20+2*frameCols,20+frameRows,'S2','Color','white');
    text(20+3*frameCols,20+frameRows,'S3','Color','white');

    %add a line for alignment of left and right beams
    %     line([4.5*frameCols/2, 4.5*frameCols/2],[0,frameRows], 'Color', 'white','linestyle','--');
    %     line([5.5*frameCols/2, 5.5*frameCols/2],[0,frameRows], 'Color', 'white','linestyle','--');
    %
    %     line([4*frameCols/2, 6*frameCols/2], [frameRows/2,frameRows/2], 'Color', 'white','linestyle','--');

else
    text(20,20,'S0','Color','white');
    text(20+frameCols,20,'S1','Color','white');
    text(20,20+frameRows,'S2','Color','white');
    text(20+frameCols,20+frameRows,'S3','Color','white');

    %add a line for alignment of left and right beams
    %     line([0.5*frameCols/2, 0.5*frameCols/2],[0, frameRows], 'Color', 'white','linestyle','--');
    %     line([1.5*frameCols/2, 1.5*frameCols/2],[0, frameRows], 'Color', 'white','linestyle','--');
    %     line([0, frameCols], [frameRows/2, frameRows/2], 'Color', 'white','linestyle','--');
end

fps = 0;

% Display the preview -----------------------------------------------------

while ishandle(h) %is window open?

    tic;

    if ~isa(vid, 'uint8')
        sn = single(getsnapshot(vid));
        noise = mean(sn(5,1:5));
        sn = sn - noise*2;
        sn(sn<0)=0;
        framesBuffer(:,:,bufferHead) = sn/minMax(2);
    else
        framesBuffer(:,:,bufferHead) = single(vid)/minMax(2); %debug mode where vid is the frame
    end

    bufferHead = bufferHead + 1;
    if (bufferHead > movAveNumFrames)
        bufferHead = 1;
    end

    %we use frame variable, which is the average
    frame = mean(framesBuffer,3);

    minVal = min(frame(:));
    maxVal = max(frame(:));

    %imshow(viewport,[minMax(1) minMax(2)],'colormap',cm,'Border','tight');

    %split the sides
    frameLeft = frame(:, 1:size(frame,2)/2);
    frameRight = frame(:, size(frame,2)/2+1:end);
    frameLeftPadded = padarray(frameLeft, abs(corr_offset), 0, 'both');
    frameLeft = frameLeftPadded((rowColClip(1)+1):rowColClip(1)+size(frameRight,1), (rowColClip(2)+1):rowColClip(2)+size(frameRight,2));

    %Separate out the different polarisations
    %Encoding is [90 45; 135 0]
    frameV = frameRight(1:2:end, 1:2:end);
    frameH = frameRight(2:2:end, 2:2:end);
    frameD = frameRight(1:2:end, 2:2:end);
    frameA = frameRight(2:2:end, 1:2:end);
    frameR = frameLeft(1:2:end, 2:2:end);
    frameL = frameLeft(2:2:end, 1:2:end);

    %reduced stokes
    frameS0 = frameR + frameL;
    frameS1 = 2*frameH - frameS0;
    frameS2 = 2*frameD - frameS0;
    frameS3 = frameR - frameL;

    if viewAll
        frameTop = [frameV frameD frameS0 frameS1];
        frameBot = [frameA frameH frameS2 frameS3];
        ellipseCenter = [round(size(frameS0,2) * 2.5) round(size(frameS0,1)*0.5)];
    else
        frameTop = [frameS0 frameS1];
        frameBot = [frameS2 frameS3];
        ellipseCenter = [round(size(frameS0,2) * 0.5) round(size(framframeS0eV,1)*0.5)];
    end

    frameComposition = vertcat(frameTop, frameBot);
    %     imagesc(frameComposition);
    %     min(frameComposition(:))
    %     max(frameComposition(:))

    if ishandle(h)
        set(p1, 'CData', frameComposition);
        title(strcat('[min,max]=[', num2str(minVal,'%4.2f'), ',', num2str(maxVal,'%4.2f'), ']', ', FPS=', num2str(fps,'%4.1f')));
    end

    %Draw an ellipse
    eL=sqrt(mean(frameS1,'all').^2+mean(frameS2,'all').^2);
    ea=real(sqrt((mean(frameS0,'all')+eL)/2)) * size(frameS0,1)*0.7; % Semi-major axis
    eb=real(sqrt((mean(frameS0,'all')-eL)/2)) * size(frameS0,1)*0.7; % Semi-minor axis
    ephi=angle(mean(frameS1,'all')+1i*mean(frameS2,'all'))/2; % Rotation angle
    eh=sign(mean(frameS3,'all')); % Handedness: (+) Righthanded = Red (-) Lefthanded = Blue
    aux = mod(ephi,2*pi) * 180/pi;

    if (eb/ea) >= .05 && eh < 0
        ecolor = 'red';
    elseif (eb/ea) >= .05 && eh > 0
        ecolor = 'green';
    elseif  (eb/ea) <= .05
        ecolor = 'white';
    end

    drawellipse(gca,'Center',ellipseCenter,'SemiAxes',[ea,eb],'RotationAngle',aux,'color',ecolor,...
        'InteractionsAllowed','none','LineWidth',1,'FaceAlpha',0);

    k=get(gcf,'CurrentCharacter');
    if k~='@' % has it changed from the dummy character?
        set(gcf,'CurrentCharacter','@'); % reset the character
        % now process the key as required
        if k=='p'
            %screenshot.
            ds = datestr(now,'mmddyyyy-HHMMss');
            print(gcf,strcat('stokes-',ds),'-dpng');
            save(strcat('stokes-',ds), "frameV", "frameH", "frameD", "frameA", "frameR", "frameL", "frameS0", "frameS1", "frameS2", "frameS3","-v7");
            figure(h);
        end
    end

    pause(1/20);
    fps = 1/(toc);

    ellipseHandle = findobj(gca,'Type','images.roi.Ellipse'); delete(ellipseHandle);
end

if ~isa(vid,'uint8')
    if isrunning(vid)
        stop(vid); %back to how it was
    end
end

end


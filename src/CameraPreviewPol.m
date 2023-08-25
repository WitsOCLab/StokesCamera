function [] = CameraPreviewPol(vid, movAveNumFrames, minMax)
%CAMERAPREVIEW An enhanced camera preview function with some cool features
% as documented below.
%   vid :       An initialised camera object with ROI, exposure, etc. set up.
%   movAveNumFrames :   Default = 1, display a moving average rather than
%                       frame by frame.
%   minMax :    Default [0 255] but other options could be [0 1023]
%
% v = videoinput("gentl", 1, "Mono12Packed");

stop(vid);

if nargin < 2
    movAveNumFrames = 1;
end

if nargin < 3
    autoMinMax = true;
    minMax = [0 255];
else
    autoMinMax = false;
end

if nargin < 3
    movAveNumFrames = 1;
end


%check if camera is started
triggerconfig(vid, 'manual');
wasRunning = true;
if ~isrunning(vid)
    wasRunning = false;
    start(vid);
end

h = figure('name','Polarisation Camera Preview','NumberTitle','off');

frame = getsnapshot(vid); %TODO use resolution rather than a snapshot

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

cm = parula(minMax(2));

if max(size(frame)) > 512
    fontSize = 32;
    statsAreaTopHeight = fontSize*4;
else
    fontSize = 11;
    statsAreaTopHeight = fontSize*2 + 2;
end

viewport = zeros(size(frame,1) + statsAreaTopHeight, size(frame,2));

p1 = imshow(viewport,[minMax(1) minMax(2)],'colormap',cm,'Border','tight');
set(gca,'dataAspectRatio',[1 1 1]);
set(gca,'color','none');
%set(gcf,'ToolBar','none');
set(gca, 'Units', 'normalized', 'Position', [0.01 .01 0.98 0.96])
%colorbar;

fps = 0;
lastTic = tic;

while ishghandle(h) %is window open?
    tic;

    framesBuffer(:,:,bufferHead) = getsnapshot(vid);

    bufferHead = bufferHead + 1;
    if (bufferHead > movAveNumFrames)
        bufferHead = 1;
    end

    %we use frame variable, which is the average
    frame = mean(framesBuffer,3);

    minVal = min(frame(:));
    maxVal = max(frame(:));

    %imshow(viewport,[minMax(1) minMax(2)],'colormap',cm,'Border','tight');

    title(strcat('[min,max]=[', num2str(minVal,'%4.2f'), ',', num2str(maxVal,'%4.2f'), ']', ', FPS=', num2str(fps,'%4.1f')));

    hold on;

    %Separate out the different polarisations
    %Encoding is [90 45; 135 0]
    frameV = frame(1:2:end, 1:2:end);
    frameH = frame(2:2:end, 2:2:end);
    frameD = frame(1:2:end, 2:2:end);
    frameA = frame(2:2:end, 1:2:end);

    frameTop = [frameV frameD];
    frameBot = [frameA frameH];
    frameComposition = vertcat(frameTop, frameBot);

    set(p1, 'CData', frameComposition);

    % Draw text descriptions only once:
    if ~exist('firstTime') 
        firstTime = true;

        text(20,20,'V','Color','white');
        text(20+size(frameV,2),20,'D','Color','white');
        text(20,20+size(frameV,1),'A','Color','white');
        text(20+size(frameV,2),20+size(frameV,1),'H','Color','white');
    end

    hold off;

    pause(1/60); %we will never be able to display more than 60 FPS anyway
    fps = 1/(toc);
end


if ~wasRunning
    stop(vid); %back to how it was
end

end


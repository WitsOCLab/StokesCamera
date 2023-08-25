function [H,V,A,D] = PolCameraSplitFrame(frame,roi)
%PolCameraSplitFrame Splits a frame from the polarisation camera into it's
%component H, V, A and D frames (each a quarter of the size of the initial
%frame obviously).
%   frame   : The raw frame from the camera.
%   roi     : (Optional) If a region of interest was used, input it here so that the
%             pixels are properly aligned to corresponding polarisations.

% Encoding is [90 45; 135 0]

% These are the default starting indices for the encoding:
startPixelX1 = 1;
startPixelX2 = 2;
startPixelY1 = 1;
startPixelY2 = 2;

% If the region of interest start odd then we switch the start pixels:
if nargin > 1
    if mod(roi(1),2) ~= 0 %ROI start on an odd X (col)
        startPixelX1 = 2;
        startPixelX2 = 1;
    end
    if mod(roi(2),2) ~= 0 %ROI start on an odd Y (row)
        startPixelY1 = 2;
        startPixelY2 = 1;
    end
end

% Separate out the different polarisations:
% TODO: These lines are doing very heavy lifting. If too slow, investigate
% if there is a faster way using things like reshape(). 
V = frame(startPixelY1:2:end, startPixelX1:2:end);
D = frame(startPixelY1:2:end, startPixelX2:2:end);
H = frame(startPixelY2:2:end, startPixelX2:2:end);
A = frame(startPixelY2:2:end, startPixelX1:2:end);
end


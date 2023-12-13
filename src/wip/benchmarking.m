%frame = randn(2000,2000);

% code to test

frameLeft = frame(:, 1:size(frame,2)/2);
    frameRight = frame(:, size(frame,2)/2+1:end);

    %Separate out the different polarisations
    %Encoding is [90 45; 135 0]
    frameV = frameRight(1:2:end, 1:2:end);
    frameH = frameRight(2:2:end, 2:2:end);
    frameD = frameRight(1:2:end, 2:2:end);
    frameA = frameRight(2:2:end, 1:2:end);
    frameR = frameLeft(1:2:end, 2:2:end);
    frameL = frameLeft(2:2:end, 1:2:end);
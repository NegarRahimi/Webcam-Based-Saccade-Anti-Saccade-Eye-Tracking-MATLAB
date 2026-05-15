function [RightDir, LeftDir, MidDir] = EyeCalibration(cam, faceDetector, eyeDetector)
% EYECALIBRATION
%
% -------------------------------------------------------------
% Webcam-Based Eye Calibration for Saccade/Anti-Saccade Tasks
% -------------------------------------------------------------
%
% Author:
%   Negar Rahimi
%
% Description:
%   This function captures gaze templates for left, right, and
%   center eye positions using a webcam and computer vision
%   detectors.
%
%   These templates are later used for gaze classification in
%   the Saccade and AntiSaccade tasks.
%
% Inputs:
%   cam          : MATLAB webcam object
%   faceDetector : vision.CascadeObjectDetector for face detection
%   eyeDetector  : vision.CascadeObjectDetector for eye-pair detection
%
% Outputs:
%   RightDir : Template for right gaze
%   LeftDir  : Template for left gaze
%   MidDir   : Template for center gaze
%
% Requirements:
%   - MATLAB Support Package for USB Webcams
%   - Computer Vision Toolbox
%   - Image Processing Toolbox
%
% -------------------------------------------------------------

% Create calibration figure
figure('Name', 'Eye Calibration', ...
       'NumberTitle', 'off', ...
       'Color', 'w');

% Capture calibration templates
LeftDir  = captureEyeTemplate(cam, faceDetector, eyeDetector, 0.5, 10, 'o', 'Look LEFT');
RightDir = captureEyeTemplate(cam, faceDetector, eyeDetector, 19.5, 10, 'o', 'Look RIGHT');
MidDir   = captureEyeTemplate(cam, faceDetector, eyeDetector, 10, 10, '+', 'Look CENTER');

% Close calibration window
try
    close(gcf);
catch
end

end


function eyeTemplate = captureEyeTemplate(cam, faceDetector, eyeDetector, x, y, markerType, instructionText)
% Helper function to capture one gaze template

nFramesToCapture = 70;
eyeTemplate = [];

while nFramesToCapture > 0

    % Display calibration target
    cla;

    if markerType == '+'
        plot(x, y, 'b+', ...
            'LineWidth', 1, ...
            'MarkerSize', 12, ...
            'MarkerEdgeColor', 'g');
    else
        plot(x, y, 'bo', ...
            'LineWidth', 1, ...
            'MarkerSize', 18, ...
            'MarkerEdgeColor', 'g', ...
            'MarkerFaceColor', [0 1 0]);
    end

    xlim([0 20]);
    ylim([0 20]);
    title(instructionText);
    grid on;
    drawnow;

    % Capture frame
    img = snapshot(cam);

    % Convert to grayscale
    if size(img, 3) == 3
        grayImg = rgb2gray(img);
    else
        grayImg = img;
    end

    % Reduce size for faster face detection
    smallImg = imresize(grayImg, 1/12);
    faceBoxes = step(faceDetector, smallImg);

    if isempty(faceBoxes) || size(faceBoxes, 2) ~= 4
        continue;
    end

    % Use first detected face
    faceBox = round(faceBoxes(1, :) * 12);
    faceBox = sanitizeBox(faceBox, size(grayImg));
    if isempty(faceBox)
        continue;
    end

    faceImg = imcrop(grayImg, faceBox);

    % Detect eyes within face
    eyeBoxes = step(eyeDetector, faceImg);
    if isempty(eyeBoxes) || size(eyeBoxes, 2) ~= 4
        continue;
    end

    % Use first detected eye pair
    eyeBox = round(eyeBoxes(1, :));
    eyeBox = sanitizeBox(eyeBox, size(faceImg));
    if isempty(eyeBox)
        continue;
    end

    eyePair = imcrop(faceImg, eyeBox);

    % Keep one eye only
    oneEye = eyePair(:, 1:round(size(eyePair, 2) / 2));

    % Normalize eye template
    eyeTemplate = double(oneEye);
    eyeTemplate = (eyeTemplate - mean(eyeTemplate(:))) / 256;

    nFramesToCapture = nFramesToCapture - 1;
    drawnow;
end

if isempty(eyeTemplate)
    error('No valid eye template was captured during calibration.');
end

end


function boxOut = sanitizeBox(boxIn, imgSize)
% Ensures a crop box stays within image boundaries

if numel(boxIn) ~= 4
    boxOut = [];
    return;
end

x = max(1, round(boxIn(1)));
y = max(1, round(boxIn(2)));
w = round(boxIn(3));
h = round(boxIn(4));

if w <= 1 || h <= 1
    boxOut = [];
    return;
end

if x > imgSize(2) || y > imgSize(1)
    boxOut = [];
    return;
end

w = min(w, imgSize(2) - x);
h = min(h, imgSize(1) - y);

if w <= 1 || h <= 1
    boxOut = [];
    return;
end

boxOut = [x y w h];

end
function Result = showfre(img, faceDetector, eyeDetector, RMask, LMask, MMask, handles)
% SHOWFRE
%
% -------------------------------------------------------------
% Gaze Direction Detection for Webcam-Based Eye Tracking
% -------------------------------------------------------------
%
% Author:
%   Negar Rahimi
%
% Description:
%   This function estimates gaze direction from a webcam frame
%   using face detection, eye-pair detection, and template
%   matching against precomputed calibration masks.
%
%   The function compares the current eye image with templates
%   corresponding to right, left, and center gaze directions.
%
% Inputs:
%   img          : Input image captured from the webcam
%   faceDetector : vision.CascadeObjectDetector for face detection
%   eyeDetector  : vision.CascadeObjectDetector for eye-pair detection
%   RMask        : Calibration template for right gaze
%   LMask        : Calibration template for left gaze
%   MMask        : Calibration template for center gaze
%   handles      : GUI handles structure (optional)
%
% Output:
%   Result:
%       0 = gaze not detected
%       1 = right gaze
%       2 = left gaze
%       4 = center gaze
%
% Requirements:
%   - Computer Vision Toolbox
%   - Image Processing Toolbox
%
% -------------------------------------------------------------

if nargin < 7
    handles = [];
end

Result = 0;

%% Convert input image to grayscale
if size(img, 3) == 3
    grayImg = rgb2gray(img);
else
    grayImg = img;
end

%% Face detection on resized image for speed
smallImg = imresize(grayImg, 1/12);
faceBoxes = step(faceDetector, smallImg);

% Reset GUI button color
setButtonColor(handles, [0 0 0]);

if isempty(faceBoxes) || size(faceBoxes, 2) ~= 4
    return;
end

%% Use first detected face
faceBox = round(faceBoxes(1, :) * 12);
faceBox = sanitizeBox(faceBox, size(grayImg));
if isempty(faceBox)
    return;
end

faceImg = imcrop(grayImg, faceBox);

%% Detect eyes within the face region
eyeBoxes = step(eyeDetector, faceImg);
if isempty(eyeBoxes) || size(eyeBoxes, 2) ~= 4
    return;
end

%% Use first detected eye pair
eyeBox = round(eyeBoxes(1, :));
eyeBox = sanitizeBox(eyeBox, size(faceImg));
if isempty(eyeBox)
    return;
end

eyePair = imcrop(faceImg, eyeBox);

% Use one eye only
oneEye = eyePair(:, 1:round(size(eyePair, 2) / 2));

%% Normalize current eye image
imgEye = double(oneEye);
imgEye = (imgEye - mean(imgEye(:))) / 256;

%% Cross-correlation with gaze templates
corrRight  = xcorr2(imgEye, RMask);
corrLeft   = xcorr2(imgEye, LMask);
corrCenter = xcorr2(imgEye, MMask);

maxRight  = localCentralMax(corrRight);
maxLeft   = localCentralMax(corrLeft);
maxCenter = localCentralMax(corrCenter);

[~, bestMatch] = max([maxRight, maxLeft, maxCenter]);

%% Assign gaze label
if bestMatch == 1
    setButtonColor(handles, [1 0 0]);
    Result = 1;   % Right
elseif bestMatch == 2
    setButtonColor(handles, [0 0 1]);
    Result = 2;   % Left
elseif bestMatch == 3
    setButtonColor(handles, [0 1 0]);
    Result = 4;   % Center
end

end


function val = localCentralMax(C)
% Returns the maximum correlation value in the central region
% of the correlation map.

r1 = max(1, round(size(C,1) * 2/5));
r2 = min(size(C,1), round(size(C,1) * 3/5));
c1 = max(1, round(size(C,2) * 2/5));
c2 = min(size(C,2), round(size(C,2) * 3/5));

val = max(max(C(r1:r2, c1:c2)));

end


function setButtonColor(handles, colorVal)
% Updates the GUI pushbutton color if valid GUI handles exist.

try
    if ~isempty(handles) && isfield(handles, 'pushbutton1') && isgraphics(handles.pushbutton1)
        handles.pushbutton1.ForegroundColor = colorVal;
    end
catch
end

end


function boxOut = sanitizeBox(boxIn, imgSize)
% Ensures the crop box remains inside image boundaries.

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
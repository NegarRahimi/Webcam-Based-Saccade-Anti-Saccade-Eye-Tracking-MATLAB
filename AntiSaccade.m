function varargout = AntiSaccade(varargin)
% ANTISACCADE MATLAB code for AntiSaccade.fig
%
% -------------------------------------------------------------
% Webcam-Based Anti-Saccade Eye Tracking Task
% -------------------------------------------------------------
%
% Author:
%   Negar Rahimi
%
% Description:
%   This MATLAB GUI implements a webcam-based anti-saccade task.
%   In an anti-saccade task, participants must look in the
%   direction opposite to the presented visual stimulus.
%
%   The system detects gaze direction (left/right) using
%   webcam images, face detection, and eye template matching.
%
% Requirements:
%   - MATLAB Support Package for USB Webcams
%   - Computer Vision Toolbox
%   - Image Processing Toolbox
%
% Required Files:
%   - EyeCalibration.m
%   - showfre.m
%   - AntiSaccade.fig
%
% Output:
%   timer_AntiSaccade : Reaction times for each trial
%   correct_AS        : Response accuracy (1 = correct, 0 = incorrect)
%
% -------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;

gui_State = struct( ...
    'gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @AntiSaccade_OpeningFcn, ...
    'gui_OutputFcn',  @AntiSaccade_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
    'gui_Callback',   []);

if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

end


function AntiSaccade_OpeningFcn(hObject, eventdata, handles, varargin)
% Executes just before AntiSaccade GUI becomes visible

handles.output = hObject;
guidata(hObject, handles);

end


function varargout = AntiSaccade_OutputFcn(hObject, eventdata, handles)
% Returns outputs to command line

varargout{1} = handles.output;

end


function pushbutton1_Callback(hObject, eventdata, handles)
% Starts the Anti-Saccade experiment

%% Webcam Initialization
try
    cam = webcam(1);
catch ME
    errordlg(['Could not start webcam.' newline newline ME.message], 'Camera Error');
    return;
end

%% Initialize detectors
faceDetector = vision.CascadeObjectDetector('FrontalFaceCART');
eyeDetector  = vision.CascadeObjectDetector('EyePairBig');

%% Task parameters
nTrials = 10;
reactionTimeOffset = 0.260;

correct_AS = zeros(1,nTrials);
timer_AntiSaccade = zeros(1,nTrials);
stimulusSide = zeros(1,nTrials);

%% Eye calibration
try
    [RightDir, LeftDir, MidDir] = EyeCalibration(cam, faceDetector, eyeDetector);
catch ME
    clear cam;
    errordlg(['Calibration failed.' newline newline ME.message], 'Calibration Error');
    return;
end

%% Run trials
for i = 1:nTrials

    % Center fixation
    axes(handles.axes1);
    cla;
    plot(10,10,'b+', ...
        'LineWidth',1, ...
        'MarkerSize',12, ...
        'MarkerEdgeColor','b');
    xlim([0 20]);
    ylim([0 20]);
    grid on;
    drawnow;
    pause(1.5);

    % Random target direction
    stimulusSide(i) = floor(100*rand);

    if stimulusSide(i) >= 50

        % Left stimulus -> correct response RIGHT
        axes(handles.axes1);
        cla;
        plot(0.5,10,'bo', ...
            'LineWidth',1, ...
            'MarkerSize',18, ...
            'MarkerEdgeColor','b', ...
            'MarkerFaceColor',[1 0 0]);
        xlim([0 20]);
        ylim([0 20]);
        grid on;
        drawnow;

        Q = 0;
        while Q == 0
            img = snapshot(cam);
            Q = showfre(img, faceDetector, eyeDetector, RightDir, LeftDir, MidDir, handles);
        end

        tic
        while true
            img = snapshot(cam);
            Q = showfre(img, faceDetector, eyeDetector, RightDir, LeftDir, MidDir, handles);
            if Q == 1 || Q == 2
                break
            end
        end
        timer_AntiSaccade(i) = toc;

        correct_AS(i) = (Q == 1);

    else

        % Right stimulus -> correct response LEFT
        axes(handles.axes1);
        cla;
        plot(19.5,10,'bo', ...
            'LineWidth',1, ...
            'MarkerSize',18, ...
            'MarkerEdgeColor','b', ...
            'MarkerFaceColor',[1 0 0]);
        xlim([0 20]);
        ylim([0 20]);
        grid on;
        drawnow;

        Q = 0;
        while Q == 0
            img = snapshot(cam);
            Q = showfre(img, faceDetector, eyeDetector, RightDir, LeftDir, MidDir, handles);
        end

        tic
        while true
            img = snapshot(cam);
            Q = showfre(img, faceDetector, eyeDetector, RightDir, LeftDir, MidDir, handles);
            if Q == 1 || Q == 2
                break
            end
        end
        timer_AntiSaccade(i) = toc;

        correct_AS(i) = (Q == 2);

    end
end

%% Adjust reaction times
timer_AntiSaccade = timer_AntiSaccade - reactionTimeOffset;

%% Display results
disp('Reaction times of AntiSaccade:');
disp(timer_AntiSaccade);

disp('Correct / Incorrect for AntiSaccade:');
disp(correct_AS);

%% Release webcam
clear cam;

end
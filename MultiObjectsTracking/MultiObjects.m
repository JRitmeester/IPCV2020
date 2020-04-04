%% Track Multi Objects

clear classes;
close all
clc
%% Instantiate video, and KLT object tracker

% The Video name make sure that you have the video in the directory
fname = 'subject1/proefpersoon 1.2_M.avi';
% Start from second 2
vidReader = VideoReader(fname,'CurrentTime',2);
tracker = MultiObjectTrackerKLT; % Tracking Obj
% Get a frame for frame-size information
frame = readFrame(vidReader);
figure; imshow(frame);
frameSize = size(frame);
% Create a video player instance
videoPlayer  = vision.VideoPlayer('Position',[200 100 fliplr(frameSize(1:2)+30)]);
%% Iterate until we select all ROI
% Define number of ROI(Region Of Interest) to select
nOfROI = 2;
bboxes = zeros(1,4);

for i=1:nOfROI
    holder = drawrectangle;
    bboxes(i,:) = round(holder.Position);
end

frameGray = rgb2gray(frame);
tracker.addDetections(frameGray, bboxes);
%% And loop until the player is closed
frameNumber = 0;
disp('Press Ctrl-C to exit...');

while hasFrame(vidReader)
    
    % Convert to grayscale (required by the detectMinEigenFeatures)
    framergb = readFrame(vidReader);
    frame = rgb2gray(framergb);
    frame = imsharpen(frame);
    % Track the points using KLT
    [points_out, pFound] = tracker.track(frame);
    
    %   Detect when one region is completly lost
    try
        if size(tracker.BoxIds)<nOfROI
            error('One ROI is lost.')
        end
    catch exception
        warning('One ROI is lost. Select Again.')
        [framergb,tracker,finished] = selectAgain(tracker, vidReader);
        if finished==1
            break
        end
    end
    
    % Display bounding boxes and tracked points.
    displayFrame = insertObjectAnnotation(framergb, 'rectangle',...
        tracker.Bboxes, tracker.BoxIds);
    displayFrame = insertMarker(displayFrame, tracker.Points);
    videoPlayer.step(displayFrame);
    
    %   We can skip frames
    %     iskip = 1;
    %     while hasFrame(vidReader)
    %         frameRGB = readFrame(vidReader);
    %         iskip = iskip+1;
    %         if iskip>2, break; end
    %     end
    
    frameNumber = frameNumber + 1;
end
%% Clean up
release(videoPlayer);

%% Functions

function [frame,trackerNew,finished] = selectAgain(trackObj, VidObj)
%   This is called when one ROI is completely lost, it allows us to
%   reselect it

%   First we skip some frames (predefined should be better method)
iskip = 1;
while hasFrame(VidObj)
    temp = readFrame(VidObj);
    iskip = iskip+1;
    if iskip>120, break; end
end

%   Save the existing ROIs
bboxes = trackObj.Bboxes;
%   Delete the old tracker
%release(trackObj);
%   Initiate new tracker Obj
trackerNew = MultiObjectTrackerKLT;
%   Read new frame
try  % check if the video is finished
    frame = readFrame(VidObj);
catch
    warning('The video is finished')
    %   Flag the video is finished
    finished = 1;
    return;
end
%   Show the framce to select new ROI
figure; imshow(frame);
holder = drawrectangle;
bboxes(end+1,:) = round(holder.Position);
%   Send those new ROIs to the tracker
frameGray = rgb2gray(frame);
trackerNew.addDetections(frameGray, bboxes);
finished = 0;
end

% From there To Redetect
%     if mod(frameNumber, 2) == 0
%         % (Re)detect.
%         if ~isempty(tracker.Bboxes)
%             tracker.addDetections(frame, tracker.Bboxes);
%         end
%     else
%         % Track
%         [points_out, pFound] = tracker.track(frame);
%     end
%
%% Track Multi Objects

clear 
close all
clc
% Required Files Structure Here:
% Matlab Dir:   -> Videos       -> subject1/ ...
%                               -> subject2/ ..
%                                  ...
%               -> TestRANSAC   -> files of RANSAC 
%           (consistencycheck.m, distest.m, est_mu_cov.m, ut_ransac.m)
%               
%               -> MultiObjects.m
%               -> MultiObjectTrackerKLT.m
mkdir('RANSAC Functions')
addpath (genpath('RANSAC Functions'))
%% Instantiate video, and KLT object tracker

% The Video name make sure that you have the video in the directory
fname = 'Videos/subject2/proefpersoon 2_M.avi';
% Start from which second 2 & 8.4
vidReader = VideoReader(fname,'CurrentTime',3);
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
frameNumber = 1;
disp('Press Ctrl-C to exit...');
estimatedPath = [];
while hasFrame(vidReader)
    estimated = [];
    % Convert to grayscale (required by the detectMinEigenFeatures)
    framergb = readFrame(vidReader);
%     framergb = undistortedImage(framergb,);
    frame = rgb2gray(framergb);
    frame = imsharpen(frame);
    % Track the points using KLT
    [estimated, points_out, IDs, lost] = tracker.track(frame);
    % The x,y location of the tongue and reference points
    % Did we lose any ROI?
    if lost
        [framergb,tracker,finished] = selectAgain(tracker, vidReader);
        points_out = tracker.Points;
        IDs = tracker.PointIds;
        % Is the video finished
        if finished==1
            break
        end
    end
    % Estimate the XY with the Average and Median
    [av, med, IDx] = getAverageX(points_out, IDs);
    averageX(frameNumber, :) = av;
    medianX(frameNumber, :) = med;
    [av, med, IDy] = getAverageY(points_out, IDs);
    averageY(frameNumber, :) = av;
    medianY(frameNumber, :) = med;
    % Store the estimated XY with RANSAC
    estimatedPath = [estimatedPath; estimated];
    
    % Display the frame with bounding boxes and tracked points.
    displayFrame = insertObjectAnnotation(framergb, 'rectangle',...
        tracker.Bboxes, tracker.BoxIds);
    displayFrame = insertMarker(displayFrame, tracker.Points);
    videoPlayer.step(displayFrame);
    frameNumber = frameNumber + 1;
end
%% Clean up
release(videoPlayer);

figure; imshow(framergb);
hold on
scatter(averageX(:,2),averageY(:,2))
scatter(averageX(:,1),averageY(:,1))
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
delete(trackObj);
%   Initiate new tracker Obj
trackerNew = MultiObjectTrackerKLT;
%   Read new frame
try  % check if the video is finished
    frame = readFrame(VidObj);
catch
    warning('The video is finished')
    %   Flag the video is finished
    frame = temp;
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

function [averageX, medianX, IDx] = getAverageX(points, IDs)
    averageX = [];
    medianX = [];
    IDx = [];
    for i = unique(IDs)'
        xPositions = [];
        xPositions = points((IDs == i),1);
        averageX = [averageX, mean(xPositions)];
        medianX = [medianX, median(xPositions)];
        IDx = [IDx i];
    end
end

function [averageY, medianY, IDy] = getAverageY(points, IDs)
    averageY = [];
    medianY = [];
    IDy = [];
    for i = unique(IDs)'
        yPositions = [];
        yPositions = points((IDs == i),2);
        averageY = [averageY, mean(yPositions)];
        medianY = [medianY, median(yPositions)];
        IDy = [IDy i];
    end
end
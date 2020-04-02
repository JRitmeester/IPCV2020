%% Track Multi Objects

clear classes;
%% Instantiate video, and KLT object tracker

% The Video name make sure that you have the video in the directory
fname = 'proefpersoon 1.2_M.avi';
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
    % Track the points using KLT
    tracker.track(frame);
    
    %   Detect when one region is completly lost
    if size(tracker.BoxIds)<nOfROI
        error('One ROI is lost.')
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
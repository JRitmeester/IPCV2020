%%
% IPCV 2020 - Tongue Tracker Project
%
% Ayham Alharbat, Protik Banerji, Jeroen Ritmeester
%%

% Cleanup and init workspace
close all;
clear variables;
addpath(genpath('.'));


videoReader = VideoReader('subjects\subject1\proefpersoon 1.2_M.avi');
videoPlayer = vision.DeployableVideoPlayer;

frame = readFrame(videoReader);
imshow(frame);
%%

% [x,y] = getpts;
% temp = frame(round(x),round(y),:);
% r = temp(1,1,1);
% g = temp(1,1,2);
% b = temp(1,1,3);
% c = [r g b];

load c c; % Contains illuminant data

rect = drawrectangle;
objectRegion = round(rect.Position);
points = detectMinEigenFeatures(rgb2gray(frame), 'ROI', objectRegion);
points = points.Location; % Points of interest in the drawn bounding box

% frame = insertShape(frame,'Rectangle',objectRegion,'Color','red');
frame = insertMarker(frame, points,'+', 'Color', 'green');
% figure;
imshow(frame);

pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
initialize(pointTracker, points, frame);
oldPoints = points;

% Start video from frame 100 and skip every 2 frames
frameCounter = 100;
frameOffset = 10;

% Open a videofile
v = VideoWriter('newfile.avi','Uncompressed AVI');
v.FrameRate = videoReader.FrameRate/frameOffset;
open(v);

% Run till you run out of video frames
while hasFrame(videoReader)
    % get the next frame
    frame = read(videoReader, frameCounter);

    % Track the points. Note that some points may be lost.
    [points, isFound] = pointTracker(frame);
    visiblePoints = points(isFound, :);
    oldInliers = oldPoints(isFound, :);

    if size(visiblePoints, 1) >= 2 % need at least 2 points

        % Estimate the geometric transformation between the old points
        % and the new points and eliminate outliers
        [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
            oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);

        % Display tracked points
        gFrame = gpuArray(frame);
        color_corected_frame = chrom_adapt(gFrame,c);

        marked_image = insertMarker(gather(color_corected_frame), visiblePoints, '+', ...
            'Color', 'white');

        % Reset the points
        oldPoints = visiblePoints;
        setPoints(pointTracker, oldPoints);
        % Display the annotated video frame using the video player object
        videoPlayer(marked_image);
        % Write video to file
        writeVideo(v, marked_image);

        % Increment frame counter by frame offset
    end
    frameCounter = frameCounter + frameOffset;
    % Check to ensure we don't overshoot the end of the video
    if (frameCounter > videoReader.NumFrames)
        break;
    end
end
close(v);



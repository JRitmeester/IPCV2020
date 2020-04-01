%%
% HEADER
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

load c c;
%%

frameCounter = 100;

% while hasFrame(videoReader)
%    frame = read(videoReader, frameCounter);
%    frame = chromadapt(frame,c);
%    step(videoPlayer, frame);
%    frameCounter = frameCounter + 1;
% end

%%
rect = drawrectangle;
objectRegion = round(rect.Position);
points = detectMinEigenFeatures(rgb2gray(frame), 'ROI', objectRegion);
points = points.Location;

frame = insertShape(frame,'Rectangle',objectRegion,'Color','red');
frame = insertMarker(frame, points,'+', 'Color', 'green');
% figure;
imshow(frame);

pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
initialize(pointTracker, points, frame);
oldPoints = points;

% [img_x, img_y] = size(frame);
% image_storage = cell(videoReader.NumFrames, img_x*img_y, 3);
image_counter = 1;
while hasFrame(videoReader)
    % get the next frame
    frame = readFrame(videoReader);

    % Track the points. Note that some points may be lost.
    [points, isFound] = pointTracker(frame);
    visiblePoints = points(isFound, :);
    oldInliers = oldPoints(isFound, :);

    if size(visiblePoints, 1) >= 2 % need at least 2 points

        % Estimate the geometric transformation between the old points
        % and the new points and eliminate outliers
        [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
            oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);

        % Apply the transformation to the bounding box points
%         bboxPoints = transformPointsForward(xform, bboxPoints);

%         % Insert a bounding box around the object being tracked
%         bboxPolygon = reshape(bboxPoints', 1, []);
%         frame = insertShape(frame, 'Polygon', bboxPolygon, ...
%             'LineWidth', 2);
%
        % Display tracked points
        gFrame = gpuArray(frame);
        color_corected_frame = chrom_adapt(gFrame,c);

        image_storage{image_counter} = insertMarker(gather(color_corected_frame), visiblePoints, '+', ...
            'Color', 'white');

        % Reset the points
        oldPoints = visiblePoints;
        setPoints(pointTracker, oldPoints);
        %     Display the annotated video frame using the video player object
        videoPlayer(image_storage{image_counter});
    end

image_counter = image_counter + 1;
end
v = VideoWriter('newfile.avi','Uncompressed AVI');
open(v);
for index = 1: videoReader.NumFrames - 1
   writeVideo(v,image_storage{index});
end
close();


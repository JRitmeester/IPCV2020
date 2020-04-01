%%
% HEADER
% Ayham Alharbat, Protik Banerji, Jeroen Ritmeester
%%

% Cleanup and init workspace
close all;
clear variables;
addpath(genpath('.'));


videoReader = VideoReader('subjects\subject1\proefpersoon 1.2_M.avi');
videoPlayer = vision.VideoPlayer;

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
% figure; imshow(frame);

pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
initialize(pointTracker, points, frame);
oldPoints = points;

while hasFrame(videoReader)
    % get the next frame
    frame = readFrame(videoReader);

    % Track the points. Note that some points may be lost.
    [points, isFound] = step(pointTracker, frame);
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
        frame = insertMarker(gather(color_corected_frame), visiblePoints, '+', ...
            'Color', 'white');       
        
        % Reset the points
        oldPoints = visiblePoints;
        setPoints(pointTracker, oldPoints);        
    end
    
%     Display the annotated video frame using the video player object
    step(videoPlayer, frame)
end

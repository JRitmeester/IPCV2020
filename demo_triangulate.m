clear variables
close all

% Create 2 video players.
videoReaderM = VideoReader('subjects\subject1\proefpersoon 1.2_M.avi');
videoReaderL = VideoReader('subjects\subject1\proefpersoon 1.2_L.avi');
videoPlayer = vision.VideoPlayer;

load stereoCameraCalibrations/stereoParamsLM stereoParams;

% Read an image from both sides
frameM = readFrame(videoReaderM);
frameL = readFrame(videoReaderL);

frameM = undistortImage(frameM,stereoParams.CameraParameters1);
frameL = undistortImage(frameL,stereoParams.CameraParameters2);

% Manually selected a point to track on both sides
figure(1); 

imshow(frameL);
point = drawpoint;
ptL = point.Position(:);

imshow(frameM);
point = drawpoint;
ptM = point.Position(:);

point3d = triangulate(ptL', ptM', stereoParams);

% Try to visualise what is going on...
camera1world = [0, 0, 0];
camera2world = stereoParams.TranslationOfCamera2;
p = [camera1world; camera2world; point3d];

scatter3(p(:,1),p(:,2),p(:,3),'r'); % plot3(X's, Y's, Z's)
set(gca, 'Projection', 'Perspective');
text(p(1,1), p(1,2), p(1,3), 'Left camera');
text(p(2,1), p(2,2), p(2,3), 'Middle camera');
text(p(3,1), p(3,2), p(3,3), 'Selected point'); % Millimeters

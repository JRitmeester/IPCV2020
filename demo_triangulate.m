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

%%
% Manually selected a point to track on both sides
colors = ['r', 'g', 'b', 'y', 'm'];

figure(1);  imshow(frameL);
figure(2);  imshow(frameM);

% for n = 1:5
% imshow(frameL);
% point = drawpoint;
% pt(n,:,1) = point.Position(:);
% 
% imshow(frameM);
% point = drawpoint;
% pt(n,:,2) = point.Position(:);
% 
% end

%%
load Paths_xy
% pt(tracker_number, coordinate (x or y), image_number (L or M))
pt(:,1,1) = averageX(:,1);
pt(:,1,2) = averageX(:,2);
pt(:,2,1) = averageY(:,1);
pt(:,2,2) = averageY(:,2);
[length, ~, ~] = size(pt); % Amount of points.
% 
% for image = 1:2
%     for index = 1:length
%         figure(image);
%         hold on
%         scatter(pt(index,1,image), pt(index,2,image), colors(index));
%         hold off
%     end
% end

%%
figure(3);
points3d(:,:) = triangulate(pt(:,:,1), pt(:,:,2), stereoParams);

% TODO: Verify how cameras were calibrated.

cameraMiddle = [0, 0, 0];
cameraLeft = stereoParams.TranslationOfCamera2;

% set(gca, 'Projection', 'Perspective');
xlabel('X')
ylabel('Y')
zlabel('Z')
% xlim([-180 20])
% ylim([-180 20])

hold on
scatter3(points3d(:,1), points3d(:,2), points3d(:,3), 'r+');

scatter3(0, 0, 0, 'b')
text(0,0,0, 'Middle camera');

scatter3(cameraLeft(1), cameraLeft(2), cameraLeft(3), 'b');
text(cameraLeft(1), cameraLeft(2), cameraLeft(3), 'Left camera');
hold off

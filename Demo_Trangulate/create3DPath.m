function create3DPath(path1, path2, stereoParams)
% TODO: Verify how cameras were calibrated.
% Get camera coordinates
cameraPath1 = [0, 0, 0];
cameraPath2 = stereoParams.TranslationOfCamera2;
R= stereoParams.RotationOfCamera2;

% Prevent errors due to different length paths
maxElement = min(size(path1, 1), size(path2,1));
% Triangulate the points using two different angles of the same points.
points3d(:,:) = triangulate(path1(1:maxElement,:), path2(1:maxElement,:), stereoParams);

% Plot the individual 2D paths.
figure;
subplot(1,2,1); scatter(path1(1:maxElement,1), path1(1:maxElement,2));
set(gca, 'YDir','reverse')
title("Path 1")
subplot(1,2,2); scatter(path2(1:maxElement,1), path2(1:maxElement,2));
set(gca, 'YDir','reverse')
title("Path 2");

% Plot 3D points
figure;
scatter3(points3d(:,1), points3d(:,2), points3d(:,3), 'r.', 'LineWidth', 1);
set(gca, 'YDir','reverse')
title("Reconstructed 3D path");
%     Show cameras in plot
hold on
cam1 = plotCamera('Location',[0 0 0],'Orientation',eye(3),'Opacity',0, 'Size', 10);
cam2 = plotCamera('Location', [132.6274   -1.9489  -56.859],...
    'Orientation',R,'Opacity',0, 'Size', 10);

% scatter3(cameraPath1(1), cameraPath1(2), cameraPath1(3), 'b')
% text(cameraPath1(1), cameraPath1(2), cameraPath1(3), 'Camera path 1');
% scatter3(cameraPath2(1), cameraPath2(2), cameraPath2(3), 'b');
% text(cameraPath2(1), cameraPath2(2), cameraPath2(3), 'Camera path 2');
hold off
view (180,-30)
set(gca, 'Projection', 'Perspective');
xlabel('X')
ylabel('Y')
zlabel('Z')
%     zLimits =[min(points3d(:,3)) max(points3d(:,3))];
%     xlim (zLimits)
%     ylim (zLimits)
%     zlim (zLimits)
xlim auto
zlim auto
ylim auto
end
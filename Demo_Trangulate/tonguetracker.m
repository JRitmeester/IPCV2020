% HEADER
% Ayham Alharbat, Protik Banerji, Jeroen Ritmeester
close all
clear variables

load stereoParams_Cam1M_L;
load TongueandTrackerPathsFor3Cam

%Create 3D path using triangulation
path_tongue = create3DPath(PathTip_M, PathTip_L, stereoParams_Cam1M_L, 0);
path_tracker = create3DPath(pathTracker_M, pathTracker_L, stereoParams_Cam1M_L, 0);
path_relative = path_tongue - path_tracker;

figure;
scatter3(path_relative(:,1), path_relative(:,2), path_relative(:,3));
set(gca, 'YDir','reverse')
set(gca, 'XDir','reverse')
title("Tongue Path w.r.t Fixed Reference Point");
set(gca, 'Projection', 'Perspective');
xlabel('X (Millimeteres)')
ylabel('Y (Millimeteres)')
zlabel('Z (Millimeteres)')
axis equal
view (-180,0)
hold on
scatter3(0,0,0, 'ro', 'lineWidth', 2)
text(0,0,0,'  Origin')
min(:) = min(path_relative(:,:));
max(:) = max(path_relative(:,:));
diff = max - min;
% minX = min(path_relative(:,1));
% maxX = max(path_relative(:,1));
% minY = min(path_relative(:,2));
% maxY = max(path_relative(:,2));
% minZ = min(path_relative(:,3));
% maxZ = max(path_relative(:,3));
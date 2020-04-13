% Ayham Alharbat, Protik Banerji, Jeroen Ritmeester
close all
clear variables

load stereoParams_Cam1M_L;
load TongueandTrackerPathsFor3Cam

% Create 3D path for the tracker point and the tongue tip
% using triangulation
path_tongue = create3DPath(PathTip_M, PathTip_L, stereoParams_Cam1M_L, 1);
path_tracker = create3DPath(pathTracker_M, pathTracker_L, stereoParams_Cam1M_L, 1);
% Transform the tongue tip points from camera-one coordinate system
% to tracker point coordinate system
TonguePath_relative = path_tongue - path_tracker;
% Show the tongue path w.r.t the new coordinate system
figure;
scatter3(TonguePath_relative(:,1), ...
    TonguePath_relative(:,2), TonguePath_relative(:,3));
% Reverse the x and y axis
set(gca, 'YDir','reverse')
set(gca, 'XDir','reverse')
title("Tongue Path w.r.t Fixed Reference Point");
set(gca, 'Projection', 'Perspective');
xlabel('X (Millimeteres)')
ylabel('Y (Millimeteres)')
zlabel('Z (Millimeteres)')
axis equal
view (-185,10)
hold on
scatter3(0,0,0, 'rO', 'lineWidth', 3)
text(0,0,0,'  Origin')
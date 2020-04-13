% HEADER
% Ayham Alharbat, Protik Banerji, Jeroen Ritmeester
close all
clear variables

load stereoParams_Cam1M_L;
load ..\path_tongue_left
load ..\path_tongue_middle
load ..\path_tracker_left
load ..\path_tracker_middle

path1 = path_tongue_left;
path2 = path_tongue_middle;

%Create 3D path using triangulation
path = create3DPath(path2, path1, stereoParams_Cam1M_L);

minX = min(path(:,1));
maxX = max(path(:,1));
minY = min(path(:,2));
maxY = max(path(:,2));
minZ = min(path(:,3));
maxZ = max(path(:,3));


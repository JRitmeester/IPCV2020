%%
% HEADER
% Ayham Alharbat, Protik Banerji, Jeroen Ritmeester
%%

close all
clear variables

videoReader = VideoReader('subjects\subject1\proefpersoon 1.2_M.avi');
videoPlayer = vision.VideoPlayer;

frame = readFrame(videoReader);
figure(1); imshow(frame);

load stereoCameraCalibrations/stereoParamsLM stereoParams;

%% Insert Ayham's code that produces 2 paths
% Now mimicked by loading the saved paths
load path_tongue_left
load path_tongue_middle
load path_tracker_left
load path_tracker_middle

path1 = path_tongue_left;
path2 = path_tongue_middle;

%% Create 3D path using triangulation
create3DPath(path1, path2, stereoParams);


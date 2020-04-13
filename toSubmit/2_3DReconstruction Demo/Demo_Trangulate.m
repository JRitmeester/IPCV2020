% Load Stereo Parameters and 2D paths from 3 Camers
close all
load("stereoParams_Cam1M_L.mat")
load("stereoParams_Cam1M_R.mat")
load("stereoParams_Cam1L_R.mat")
load('Paths_RML_withTracker.mat')
% 3D reconstruction from Middle and Left cameras
ML = create3DPath(pathM, pathL, stereoParams_Cam1M_L);
% 3D reconstruction from Middle and Right cameras
MR = create3DPath(pathM, pathR, stereoParams_Cam1M_R);
% 3D reconstruction from Left and Right cameras
LR = create3DPath(pathL, pathR, stereoParams_Cam1L_R);
load("stereoParams_Cam1M_L.mat")
load("stereoParams_Cam1M_R.mat")
load("stereoParams_Cam1L_R.mat")
load('Paths_RML_withTracker.mat')
create3DPath(pathM, pathR, stereoParams_Cam1M_R)
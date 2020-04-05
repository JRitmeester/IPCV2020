%% Clear and Load

clear
close all
clc

load('pointsData.mat');
figure; grid;
hold on;
numOfROI = (unique(allPointIds))';
pointsOut = [];
pointIDsOut = [];
for i = [1 2]
    pointsIn = [];
    pointsIn(:,:) = allPoints(allPointIds == i, :);
    scatter(allPoints(allPointIds == i,1),allPoints(allPointIds == i,2))
    pointsIn = pointsIn';
    [M, inliers, ntrial] = ut_ransac(pointsIn, @est_mu_cov, 10,...
        @distest, 30, @consistencycheck, 0.8);
    pointsOut = [pointsOut;(pointsIn(:,inliers))'];
    idx = ones(size(pointsIn(:,inliers), 2), 1) * i;
    pointIDsOut = [pointIDsOut; idx];
    plot(pointsIn(1,inliers),pointsIn(2,inliers),'r.');
    %break;
end
%%  For the whole set of points
figure; grid; hold on;
scatter(allPoints(:,1),allPoints(:,2))
allPoints = allPoints';
[M, inliers, ntrial] = ut_ransac(allPoints, @est_mu_cov, 5,...
        @distest, 10, @consistencycheck, 0.3);
plot(allPoints(1,inliers),allPoints(2,inliers),'r.');
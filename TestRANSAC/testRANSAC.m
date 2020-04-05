%% Clear and Load

clear
close all
clc

load('pointsData.mat');
figure; grid;
hold on;
numOfROI = length(unique(allPointIds));
for i=1:numOfROI
    points = [];
    points(:,:) = allPoints(allPointIds == i,:);
    scatter(allPoints(allPointIds == i,1),allPoints(allPointIds == i,2))
    points = points';
    [M, inliers, ntrial] = ut_ransac(points, @est_mu_cov, 5,...
        @distest, 9, @consistencycheck, 0.3);
    plot(points(1,inliers),points(2,inliers),'r.');
    %break;
end
%%  For the whole set of points
figure; grid; hold on;
scatter(allPoints(:,1),allPoints(:,2))
allPoints = allPoints';
[M, inliers, ntrial] = ut_ransac(allPoints, @est_mu_cov, 5,...
        @distest, 10, @consistencycheck, 0.3);
plot(allPoints(1,inliers),allPoints(2,inliers),'r.');
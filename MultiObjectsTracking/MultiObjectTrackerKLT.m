% MultiObjectTrackerKLT implements tracking multiple objects using the
% Kanade-Lucas-Tomasi (KLT) algorithm.
% tracker = MultiObjectTrackerKLT() creates the multiple object tracker.
%
% MultiObjectTrackerKLT properties:
%   PointTracker - a vision.PointTracker object
%   Bboxes       - object bounding boxes
%   BoxIds       - ids associated with each bounding box
%   Points       - tracked points from all objects
%   PointIds     - ids associated with each point
%   NextId       - the next object will have this id
%   BoxScores    - and indicator of whether or not an object is lost
%
% MultiObjectTrackerKLT methods:
%   addDetections - add detected bounding boxes
%   track         - track the objects
%   Added:
%   RANSACing     - find and eleminate outliers
% Copyright 2013-2014 The MathWorks, Inc

classdef MultiObjectTrackerKLT < handle
    properties
        % PointTracker A vision.PointTracker object
        PointTracker;
        
        % Bboxes M-by-4 matrix of [x y w h] object bounding boxes
        Bboxes = [];
        
        % BoxIds M-by-1 array containing ids associated with each bounding box
        BoxIds = [];
        
        % Points M-by-2 matrix containing tracked points from all objects
        Points = [];
        
        % PointIds M-by-1 array containing object id associated with each
        %   point. This array keeps track of which point belongs to which object.
        PointIds = [];
        
        % NextId The next new object will have this id.
        NextId = 1;
        
        % BoxScores M-by-1 array. Low box score means that we probably lost the object.
        BoxScores = [];
        counter = 1;
    end
    
    methods
        %------------------------------------------------------------------
        function this = MultiObjectTrackerKLT()
            % Constructor
            this.PointTracker = ...
                vision.PointTracker('MaxBidirectionalError', 2); % default 2
        end
        
        %------------------------------------------------------------------
        function addDetections(this, I, bboxes)
            % addDetections Add detected bounding boxes.
            % addDetections(tracker, I, bboxes) adds detected bounding boxes.
            % tracker is the MultiObjectTrackerKLT object, I is the current
            % frame, and bboxes is an M-by-4 array of [x y w h] bounding boxes.
            % This method determines whether a detection belongs to an existing
            % object, or whether it is a brand new object.
            for i = 1:size(bboxes, 1)
                % Determine if the detection belongs to one of the existing
                % objects.
                boxIdx = this.findMatchingBox(bboxes(i, :));
                
                if isempty(boxIdx)
                    % This is a brand new object.
                    this.Bboxes = [this.Bboxes; bboxes(i, :)];
                    points = detectMinEigenFeatures(I, 'ROI', bboxes(i, :));
                    points = points.Location;
                    % Add random points to track
                    xMin = bboxes(i,1);
                    xMax = bboxes(i,1)+bboxes(1,3);
                    yMin = bboxes(i,2);
                    yMax = bboxes(i,2)+bboxes(1,4);
                    addPoints = [];
                    addPoints = [((xMax-xMin).*rand(100,1) + xMin)'; ...
                        ((yMax-yMin).*rand(100,1) + yMin)'];
                    addPoints = addPoints';
                    points = [points; addPoints];
                    this.BoxIds(end+1) = this.NextId;
                    idx = ones(size(points, 1), 1) * this.NextId;
                    this.PointIds = [this.PointIds; idx];
                    this.NextId = this.NextId + 1;
                    this.Points = [this.Points; points];
                    this.BoxScores(end+1) = 1;
                    
                else % The object already exists.
                    
                    % Delete the matched box
                    currentBoxScore = this.deleteBox(boxIdx);
                    
                    % Replace with new box
                    this.Bboxes = [this.Bboxes; bboxes(i, :)];
                    
                    % Re-detect the points. This is how we replace the
                    % points, which invariably get lost as we track.
                    points = detectMinEigenFeatures(I, 'ROI', bboxes(i, :));
                    points = points.Location;
                    this.BoxIds(end+1) = boxIdx;
                    idx = ones(size(points, 1), 1) * boxIdx;
                    this.PointIds = [this.PointIds; idx];
                    this.Points = [this.Points; points];
                    this.BoxScores(end+1) = currentBoxScore + 1;
                end
            end
            
            % Determine which objects are no longer tracked.
            minBoxScore = -2;
            this.BoxScores(this.BoxScores < 3) = ...
                this.BoxScores(this.BoxScores < 3) - 0.5;
            boxesToRemoveIds = this.BoxIds(this.BoxScores < minBoxScore);
            while ~isempty(boxesToRemoveIds)
                this.deleteBox(boxesToRemoveIds(1));
                boxesToRemoveIds = this.BoxIds(this.BoxScores < minBoxScore);
            end
            
            % Update the point tracker.
            if this.PointTracker.isLocked()
                this.PointTracker.setPoints(this.Points);
            else
                this.PointTracker.initialize(this.Points, I);
            end
        end
        
        %------------------------------------------------------------------
        function [estimated,points_out,pointsIds, lost] = track(this, I)
            % TRACK Track the objects.
            % TRACK(tracker, I) tracks the objects into frame I. tracker is the
            % MultiObjectTrackerKLT object, I is the current video frame. This
            % method updates the points and the object bounding boxes.
            
            oldNumberofROI = size(unique(this.PointIds),1);
            [newPoints, isFound] = this.PointTracker.step(I);
            this.Points = newPoints(isFound, :);
            this.PointIds = this.PointIds(isFound);
            % RANSAC Called
            %   This is better to be used if some condition is true
            %   for example: the  boundaries of box surrounding
            %   the data is bigger than some value
            estimated = RANSACing(this);
            
            generateNewBoxes(this);
            if ~isempty(this.Points)
                % this.PointTracker.setPoints(this.Points);
                % In case of using RANSACing use the two lines below
                % If not RANSACing use the line above
                this.PointTracker.release;
                this.PointTracker.initialize(this.Points, I);
            end
            
            points_out = this.Points;
            pointsIds = this.PointIds;
            lost = false;
            if size(this.BoxIds,1) < oldNumberofROI
                try
                    error('One ROI is lost.')
                catch
                    warning('One ROI is lost. Select Again.')
                    lost = true;
                end
            end
            this.counter = this.counter +1;
        end
        
        %------------------------------------------------------------------
        function boxIdx = findMatchingBox(this, box)
            % Determine which tracked object (if any) the new detection
            % belongs to.
            boxIdx = [];
            for i = 1:size(this.Bboxes, 1)
                area = rectint(this.Bboxes(i,:), box);
                if area > 0.2 * this.Bboxes(i, 3) * this.Bboxes(i, 4)
                    boxIdx = this.BoxIds(i);
                    return;
                end
            end
        end
        
        %------------------------------------------------------------------
        function currentScore = deleteBox(this, boxIdx)
            % Delete object.
            this.Bboxes(this.BoxIds == boxIdx, :) = [];
            this.Points(this.PointIds == boxIdx, :) = [];
            this.PointIds(this.PointIds == boxIdx) = [];
            currentScore = this.BoxScores(this.BoxIds == boxIdx);
            this.BoxScores(this.BoxIds == boxIdx) = [];
            this.BoxIds(this.BoxIds == boxIdx) = [];
            
        end
        
        %------------------------------------------------------------------
        function generateNewBoxes(this)
            % Get bounding boxes for each object from tracked points.
            oldBoxIds = this.BoxIds;
            oldScores = this.BoxScores;
            this.BoxIds = unique(this.PointIds);
            numBoxes = numel(this.BoxIds);
            this.Bboxes = zeros(numBoxes, 4);
            this.BoxScores = zeros(numBoxes, 1);
            for i = 1:numBoxes
                points = this.Points(this.PointIds == this.BoxIds(i), :);
                newBox = getBoundingBox(points);
                this.Bboxes(i, :) = newBox;
                this.BoxScores(i) = oldScores(oldBoxIds == this.BoxIds(i));
            end
        end
        
        %------------------------------------------------------------------
        function EstimatedXY = RANSACing(this)
            % This method eleminates the outliers in each ROI
            allPoints = (this.Points);
            allIds = (this.PointIds);
            ROInum = (unique(this.PointIds))';
            EstimatedXY = [];
            pointsOut = [];
            pointIDsOut = [];
            for i = ROInum
                pointsIn = [];
                pointsIn(:,:) = allPoints(allIds == i, :);
                pointsIn = pointsIn';
                if size(pointsIn,2) >= 11
                    [M, inliers, ntrial] = ut_ransac(pointsIn,...
                        @est_mu_cov, 10, @distest, 15,...
                        @consistencycheck, 0.6);
                    EstimatedXY(i,1) = M(1,1);
                    EstimatedXY(i,2) = M(2,1);
                    validPoints = (pointsIn(:,inliers))'; %added this and replaced it to pointsOut next line
                    if (mod(this.counter, 50) == 0)
                        if validPoints<40
                            validPoints = repopulate(validPoints,this); %comment this to not repopulate
                        end
                    end
                    pointsOut = [pointsOut;validPoints];
                    idx = ones(size(validPoints, 1), 1) * i;
                    pointIDsOut = [pointIDsOut; idx];
                    
                else
                    pointsOut = [pointsOut;(pointsIn)'];
                    idx = ones(size(pointsIn, 2), 1) * i;
                    pointIDsOut = [pointIDsOut; idx];
                end
            end
            this.Points = pointsOut;
            this.PointIds = pointIDsOut;
        end
        %------------------------------------------------------------------
        function validPointsOut = repopulate(validPointsIn,this)
            % This method will add points to track when the number of
            % points tracker becomes low
            xMin = min(validPointsIn(:, 1));
            yMin = min(validPointsIn(:, 2));
            xMax = max(validPointsIn(:, 1));
            yMax = max(validPointsIn(:, 2));
            addPoints = [];
            try
            addPoints = [((xMax-xMin).*rand(10,1) + xMin)'; ...
                ((yMax-yMin).*rand(10,1) + yMin)'];
            catch
                xMax
                xMin
                yMax
                yMin
                size (validPointsIn)
            end
            addPoints = addPoints';
            validPointsOut = [validPointsIn; addPoints];
        end
    end
end

%--------------------------------------------------------------------------
function bbox = getBoundingBox(points)
x1 = min(points(:, 1));
y1 = min(points(:, 2));
x2 = max(points(:, 1));
y2 = max(points(:, 2));
bbox = [x1 y1 x2 - x1 y2 - y1];
end

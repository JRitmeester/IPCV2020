function points3d = create3DPath(path1, path2, stereoParams, showCameras)
    % Construct 3D path from two 2D paths.
    camera1Position = [0, 0, 0];
    camera2Position = -stereoParams.TranslationOfCamera2;
    R = stereoParams.RotationOfCamera2';

    % Prevent errors due to different length paths
    maxElement = min(size(path1, 1), size(path2,1));
    % Triangulate the points using two different angles of the same points.
    points3d(:,:) = triangulate(path1(1:maxElement,:), path2(1:maxElement,:), stereoParams);

    % Plot the individual 2D paths.
    figure;
    subplot(1,2,2); scatter(path2(1:maxElement,1), path2(1:maxElement,2), 'ko');
    set(gca, 'YDir','reverse')
    title("Second camera path");
    xlabel('x (mm)');
    ylabel('y (mm)');
    grid
    subplot(1,2,1); scatter(path1(1:maxElement,1), path1(1:maxElement,2), 'ko');
    set(gca, 'YDir','reverse')
    title("First camera path")
    xlabel('x (mm)');
    ylabel('y (mm)');
    grid
    
    % Plot 3D points
    figure;
    scatter3(points3d(:,1), points3d(:,2), points3d(:,3), 'k.', 'LineWidth', 1);
    set(gca, 'YDir','reverse')
    set(gca, 'XDir','reverse')
    title("Reconstructed 3D path");
    if showCameras
    % Show cameras in plot
        hold on
        cam1 = plotCamera('Location',camera1Position,'Orientation',eye(3),...
           'Opacity',0, 'Size', 10, 'Color', 'b');
        cam2 = plotCamera('Location', camera2Position,...
           'Orientation',R,'Opacity',0, 'Size', 10, 'Color', 'r');

        hold off
    end
    set(gca, 'Projection', 'Perspective');
    xlabel('X (Millimeteres)')
    ylabel('Y (Millimeteres)')
    zlabel('Z (Millimeteres)')
    axis equal
    view (180,-82)

end
function create3DPath(path1, path2, stereoParams)
    % TODO: Verify how cameras were calibrated.
    % Get camera coordinates
    cameraPath1 = [0, 0, 0];
    cameraPath2 = stereoParams.TranslationOfCamera2;

    % Prevent errors due to different length paths
    maxElement = min(size(path1, 1), size(path2,1));
    % Triangulate the points using two different angles of the same points.
    points3d(:,:) = triangulate(path1(1:maxElement,:), path2(1:maxElement,:), stereoParams);

    % Plot the individual 2D paths.
    figure;
    subplot(1,3,1); scatter(path1(1:maxElement,1), -path1(1:maxElement,2));
    title("Path 1")
    subplot(1,3,2); scatter(path2(1:maxElement,1), -path2(1:maxElement,2));
    title("Path 2");

    % Plot 3D points
    subplot(1,3,3);
    scatter3(points3d(:,1), points3d(:,2), points3d(:,3), 'r.', 'LineWidth', 1);
    title("Reconstructed 3D path");

    % Show cameras in plot
    hold on
    scatter3(cameraPath1(1), cameraPath1(2), cameraPath1(3), 'b')
    text(cameraPath1(1), cameraPath1(2), cameraPath1(3), 'Camera path 1');
    scatter3(cameraPath2(1), cameraPath2(2), cameraPath2(3), 'b');
    text(cameraPath2(1), cameraPath2(2), cameraPath2(3), 'Camera path 2');
    hold off

    set(gca, 'Projection', 'Perspective');
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    xlim auto
    ylim auto
    zlim auto
end
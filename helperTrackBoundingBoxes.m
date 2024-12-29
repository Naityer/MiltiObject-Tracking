function [boxes, labels] = helperTrackBoundingBoxes(tracker, frameRate, frameCount, boxes)
    % Convertir cajas delimitadoras al formato objectDetection
    numMeasurementsInFrame = size(boxes, 1);
    detectionsInFrame = cell(numMeasurementsInFrame, 1);
    for detCount = 1:numMeasurementsInFrame
        detectionsInFrame{detCount} = objectDetection( ...
            frameCount / frameRate, ... % Tiempo en base al contador de cuadros
            boxes(detCount, :), ... % Medición de la caja delimitadora
            'MeasurementNoise', diag([25 25 25 25])); % Ruido de medición
    end

    % Actualizar el rastreador
    if isLocked(tracker) || ~isempty(detectionsInFrame)
        tracks = tracker(detectionsInFrame, frameCount / frameRate);
    else
        tracks = objectTrack.empty;
    end

    positionSelector = [1 0 0 0 0 0 0 0; 0 0 1 0 0 0 0 0; 0 0 0 0 1 0 0 0; 0 0 0 0 0 0 1 0];
    boxes = getTrackPositions(tracks, positionSelector);
    ids = [tracks.TrackID];
    isCoasted = [tracks.IsCoasted];

    % Etiquetas personalizadas
    labels = arrayfun(@(a)num2str(a), ids, "uni", 0);
    isPredicted = cell(size(labels));
    isPredicted(isCoasted) = {'predicted'};
    labels = strcat(labels, isPredicted);
end

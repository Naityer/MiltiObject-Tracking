function [boxes, labels] = helperTrackBoundingBoxes(tracker, frameRate, frameCount, boxes)
    numMeasurementsInFrame = size(boxes, 1);
    detectionsInFrame = cell(numMeasurementsInFrame, 1);
    
    % Convertir las cajas delimitadoras en un formato adecuado para el rastreador
    for detCount = 1:numMeasurementsInFrame
        detectionsInFrame{detCount} = objectDetection( ...
            frameCount / frameRate, ... % Tiempo en base al contador de cuadros
            boxes(detCount, :), ... % Medición de la caja delimitadora
            'MeasurementNoise', diag([25 25 25 25])); % Ruido de medición
    end

    % Actualizar el rastreador si está bloqueado o hay detecciones válidas
    if isLocked(tracker) || ~isempty(detectionsInFrame)
        tracks = tracker(detectionsInFrame, frameCount / frameRate);
    else
        tracks = objectTrack.empty;
    end

    % Extraer posiciones de las pistas y generar las etiquetas
    positionSelector = [1 0 0 0 0 0 0 0; 0 0 1 0 0 0 0 0; 0 0 0 0 1 0 0 0; 0 0 0 0 0 0 1 0];
    boxes = getTrackPositions(tracks, positionSelector);
    ids = [tracks.TrackID];
    isCoasted = [tracks.IsCoasted];

    % Crear etiquetas personalizadas
    labels = arrayfun(@(id) num2str(id), ids, "uni", 0);
    isPredicted = cell(size(labels));
    isPredicted(isCoasted) = {'predicted'};
    labels = strcat(labels, isPredicted);
end
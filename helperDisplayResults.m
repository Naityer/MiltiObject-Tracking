function frame = helperDisplayResults(frame, keypointConnections, keypoints, validity, boxes, labels, frameCount)
    % Dibujar puntos clave y conexiones
    if ~isempty(validity)
        frame = insertObjectKeypoints(frame, keypoints, "KeypointVisibility", validity, ...
            Connections=keypointConnections, ConnectionColor="green", KeypointColor="yellow");
        % Dibujar cajas delimitadoras
        frame = insertObjectAnnotation(frame, "rectangle", boxes, labels, TextBoxOpacity=0.5);
        % Agregar contador de cuadros
        frame = insertText(frame, [0 0], "Frame: " + int2str(frameCount), BoxColor="black", TextColor="yellow", BoxOpacity=1);
    end
end

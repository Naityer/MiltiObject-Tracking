function box = helperDetectObjects(detector, frame, detectionThreshold, frameCount, skipFrame, minDetectionSize, debugFile)
    box = [];
    if mod(frameCount, skipFrame) == 0
        % Detectar utilizando el modelo YOLOv4
        [bboxes, scores] = detect(detector, frame, 'Threshold', detectionThreshold);
        
        % Guardar las cajas detectadas en el archivo de depuración
        fprintf(debugFile, 'Frame %d\n', frameCount);
        fprintf(debugFile, 'Bboxes:\n');
        fprintf(debugFile, '%s\n', mat2str(bboxes));  % Guardar las cajas detectadas
        fprintf(debugFile, 'Scores:\n');
        fprintf(debugFile, '%s\n', mat2str(scores));  % Guardar las puntuaciones

        % Obtener las dimensiones de la imagen
        [frameHeight, frameWidth, ~] = size(frame);
        
        % Convertir minDetectionSize a valores normalizados
        normalizedMinWidth = minDetectionSize(1) / frameWidth;
        normalizedMinHeight = minDetectionSize(2) / frameHeight;

        % Validar las detecciones, asegurando que las cajas sean mayores que el tamaño mínimo
        valid = scores > detectionThreshold & ...
                (bboxes(:, 3) >= normalizedMinWidth) & ...
                (bboxes(:, 4) >= normalizedMinHeight);
        
        box = bboxes(valid, :);
        
        % Guardar la cantidad de detecciones válidas en el archivo de depuración
        fprintf(debugFile, 'Valid detections: %d\n\n', sum(valid));
    end
end

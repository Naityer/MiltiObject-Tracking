function [keypoints, validity] = helperDetectKeypointsUsingHRNet(frame, keyPtDet, boxes)
    if ~isempty(boxes)
        % Obtener las dimensiones de la imagen
        [frameHeight, frameWidth, ~] = size(frame);

        % Ajustar las cajas para que no se salgan de los límites
        boxes(:, 3) = min(boxes(:, 3), frameWidth - boxes(:, 1)); % Limitar el ancho
        boxes(:, 4) = min(boxes(:, 4), frameHeight - boxes(:, 2)); % Limitar la altura

        % Verificar que las cajas sean válidas (positivas y dentro de los límites de la imagen)
        validBoxes = all(boxes > 0, 2) & ...
                     all(boxes(:, 3) <= frameWidth, 2) & ...
                     all(boxes(:, 4) <= frameHeight, 2);

        if any(validBoxes) % Si hay cajas válidas
            validBoxes = find(validBoxes); % Obtener los índices de las cajas válidas
            boxes = boxes(validBoxes, :); % Filtrar las cajas válidas

            % Detectar los puntos clave usando las cajas válidas
            [keypoints, ~, validity] = detect(keyPtDet, frame, boxes);
        else
            keypoints = [];
            validity = [];
        end
    else
        keypoints = [];
        validity = [];
    end
end

function frame = helperDisplayResults(frame, keypointConnections, keypoints, validity, boxes, labels, frameCount)
    % Verificar que las cajas estén dentro de los límites de la imagen
    [frameHeight, frameWidth, ~] = size(frame);
    
    % Asegurarse de que las posiciones de las cajas no se salgan de los límites
    boxes(:, 3) = min(boxes(:, 3), frameWidth - boxes(:, 1));  % Limitar el ancho
    boxes(:, 4) = min(boxes(:, 4), frameHeight - boxes(:, 2)); % Limitar la altura

    % Dibujar puntos clave y conexiones si existen
    if ~isempty(validity) && ~isempty(keypoints)
        % Dibujar puntos clave y sus conexiones
        frame = insertObjectKeypoints(frame, keypoints, "KeypointVisibility", validity, ...
            "Connections", keypointConnections, "ConnectionColor", "green", "KeypointColor", "yellow");
        
        % Agregar números de los puntos clave en cada punto clave
        for i = 1:size(keypoints, 1)
            if validity(i) == 1  % Si el punto clave es válido
                position = keypoints(i, :);
                % Asegurarse de que la posición esté dentro de los límites de la imagen
                x = min(max(round(position(1)), 1), frameWidth);  % Coordenada X (ajustada a los límites)
                y = min(max(round(position(2)), 1), frameHeight); % Coordenada Y (ajustada a los límites)
                
                % Insertar el número del punto clave en la posición correspondiente
                frame = insertText(frame, [x, y], num2str(i), 'BoxColor', 'black', 'TextColor', 'yellow', 'FontSize', 10, 'AnchorPoint', 'Center');
            end
        end
    end
    
    % Dibujar cajas delimitadoras y etiquetas
    if ~isempty(boxes)
        try
            % Dibujar las cajas con las etiquetas
            frame = insertObjectAnnotation(frame, "rectangle", boxes, labels, 'TextBoxOpacity', 0.5, 'FontSize', 12, 'TextColor', 'white');
        catch
            warning('Error al insertar la anotación en el cuadro %d', frameCount);
        end
    end
    
    % Agregar el contador de cuadros en la esquina superior izquierda
    frame = insertText(frame, [10 10], "Frame: " + int2str(frameCount), 'BoxColor', 'black', 'TextColor', 'yellow', 'BoxOpacity', 1, 'FontSize', 16);
end

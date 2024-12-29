function [reader, frameRate, frameSize] = preprocessVideo(videoFile)
    % Función para procesar y convertir el video a un formato adecuado.
    % Devuelve el VideoReader, la tasa de fotogramas y el tamaño de los cuadros.

    % Verificar si el archivo existe
    if exist(videoFile, 'file') ~= 2
        error('El archivo de video no se encuentra en la ruta especificada.');
    end

    % Leer los datos del video
    reader = VideoReader(videoFile);
    
    % Obtener la tasa de fotogramas y tamaño de los cuadros
    frameRate = reader.FrameRate;  
    frameSize = [reader.Width reader.Height]; 

    % Opcional: Si deseas ajustar la resolución o el formato, aquí podrías agregarlo.
    % No redimensionamos el video aquí para mantener el encuadre original
    % Si necesitas redimensionarlo, lo puedes hacer aquí.

    % Asegurarse de que el video esté en formato RGB adecuado
    % El VideoReader en MATLAB entrega imágenes en formato RGB
end

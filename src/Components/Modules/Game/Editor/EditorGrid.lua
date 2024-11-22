return function(camera, cellSize)
    -- Obter dimensões da tela
    local screenWidth, screenHeight = love.graphics.getDimensions()

    -- Ajustar o tamanho das células da grade com base no zoom
    local adjustedCellSize = cellSize * camera.scale

    -- Calcular a posição inicial da grade para o alinhamento com a câmera
    local startX = math.floor(camera.x / adjustedCellSize) * adjustedCellSize
    local startY = math.floor(camera.y / adjustedCellSize) * adjustedCellSize

    -- Definir a cor da grade (RGBA)
    love.graphics.setColor(1, 1, 1, 0.3)

    -- Desenhar as linhas verticais
    for x = startX, camera.x + screenWidth, adjustedCellSize do
        love.graphics.line(x - camera.x, 0, x - camera.x, screenHeight)
    end

    -- Desenhar as linhas horizontais
    for y = startY, camera.y + screenHeight, adjustedCellSize do
        love.graphics.line(0, y - camera.y, screenWidth, y - camera.y)
    end

    -- Resetar cor para o padrão
    love.graphics.setColor(1, 1, 1, 1)
end

return function(type, offsetX, offsetY, w, h)
    return {
        offsetX = offsetX or 0,
        offsetY = offsetY or 0,
        w = w,
        h = h,
        type = type
    }
end
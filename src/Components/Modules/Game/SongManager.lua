local SongManager = {}

function SongManager.getSongSource(protocol)
    local param, value = protocol:match('^([%w|_]+)%s-=%s-(.+)$')
    if param and value then
        switch(param, {
            ["newgrounds"] = function()
                
            end,
            ["default"] = function()
                
            end
        })
    end
end

return SongManager
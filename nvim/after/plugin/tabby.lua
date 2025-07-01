local theme = {
  fill = 'TabLineFill',
  current_tab = {fg = '#282828', bg = '#ebdbb2'},
  tab = {fg = '#7c6f64', bg = '#141414'},
  bg1 = {fg = '#f2e9de', bg = '#a89984'},
  bg2 = {fg = '#f2e9de', bg = '#141414'},
  unsaved1 = {fg = '#282828', bg = '#d65d0e'},
  unsaved2 = {bg = '#ffaf5f'},
}

require('tabby').setup({
    line = function(line)
        return {
            line.tabs().foreach(function(tab)
                local hl = tab.is_current() and theme.current_tab or theme.tab
                local tabn = ' ' .. tab.number() .. ' '
                local unsaved = false
                local tab_name = (function()
                    local name = ''
                    local win_count = 0
                    --[[
                    in this function, we check for
                    1. buffer count in tab
                    2. special buffer types
                    3. buffer has unsaved changes
                    --]]
                    tab.wins().foreach(function(win)
                        win_count = win_count + 1
                        local buf = win.buf()
                        local buftype = buf.type()
                        if buf.is_changed() then
                            unsaved = true
                        end
                        if buftype == 'help' then
                            name = name .. '[H] '
                        elseif buftype == 'quickfix' then
                            name = name .. '[Q] '
                        elseif win_count <= 1 then
                            name = name .. buf.name() .. ' '
                        end
                    end)
                    if win_count > 1 then
                        name = name .. '(' .. win_count .. ') '
                    end
                    --if unsaved then
                    --    name = '[+] ' .. name
                    --end
                    return name ~= '' and ' ' .. name or '[New] '
                end)()
                local unsaved_marker = unsaved and '[+] ' or ''
                return {
                    line.sep(tabn, theme.bg1, theme.bg2),
                    tab_name,
                    {unsaved_marker, hl = tab.is_current() and theme.unsaved1 or theme.unsaved2},
                    hl = hl,
                }
            end),
            line.spacer(),
        }
    end,
    option = {
        nerdfont = true, -- whether use nerdfont
        buf_name = {
            mode = 'shorten', -- or 'relative', 'tail', 'shorten'
        },
    },
})

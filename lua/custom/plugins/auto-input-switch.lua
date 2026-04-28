return {
    'amekusa/auto-input-switch.nvim',
    config = function()
        require('auto-input-switch').setup {
            -- To use macism instead of im-select on macOS, uncomment below:
            -- os_settings = {
            --     macos = {
            --         cmd_get = 'macism',
            --         cmd_set = 'macism %s',
            --     },
            -- },
        }

        -- HACK: Monkey patch for TermLeave/TermEnter — plugin doesn't handle terminal buffers.
        -- Hopefully the plugin supports this natively later :)
        local term_saved_input = nil
        vim.api.nvim_create_autocmd('TermLeave', {
            callback = function()
                term_saved_input = vim.fn.system('im-select'):gsub('%s+$', '')
                vim.fn.system('im-select com.apple.keylayout.Australian')
            end,
        })
        vim.api.nvim_create_autocmd('TermEnter', {
            callback = function()
                if term_saved_input then
                    vim.fn.system('im-select ' .. term_saved_input)
                end
            end,
        })
    end,
}

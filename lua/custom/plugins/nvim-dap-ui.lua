-- Debugging Support
return {
    -- https://github.com/rcarriga/nvim-dap-ui
    'rcarriga/nvim-dap-ui',
    event = 'VeryLazy',
    dependencies = {
        -- https://github.com/mfussenegger/nvim-dap
        'mfussenegger/nvim-dap',
        -- https://github.com/nvim-neotest/nvim-nio
        'nvim-neotest/nvim-nio',
        -- https://github.com/theHamsta/nvim-dap-virtual-text
        'theHamsta/nvim-dap-virtual-text', -- inline variable text while debugging
        -- https://github.com/nvim-telescope/telescope-dap.nvim
        'nvim-telescope/telescope-dap.nvim', -- telescope integration with dap
    },
    opts = {
        controls = {
            element = 'repl',
            enabled = false,
            icons = {
                disconnect = '',
                pause = '',
                play = '',
                run_last = '',
                step_back = '',
                step_into = '',
                step_out = '',
                step_over = '',
                terminate = '',
            },
        },
        element_mappings = {},
        expand_lines = true,
        floating = {
            border = 'single',
            mappings = {
                close = { 'q', '<Esc>' },
            },
        },
        force_buffers = true,
        icons = {
            collapsed = '',
            current_frame = '',
            expanded = '',
        },
        layouts = {
            {
                elements = {
                    {
                        id = 'scopes',
                        size = 0.50,
                    },
                    {
                        id = 'stacks',
                        size = 0.30,
                    },
                    {
                        id = 'watches',
                        size = 0.10,
                    },
                    {
                        id = 'breakpoints',
                        size = 0.10,
                    },
                },
                size = 40,
                position = 'left', -- Can be "left" or "right"
            },
            {
                elements = {
                    'repl',
                    'console',
                },
                size = 10,
                position = 'bottom', -- Can be "bottom" or "top"
            },
        },
        mappings = {
            edit = 'e',
            expand = { '<CR>', '<2-LeftMouse>' },
            open = 'o',
            remove = 'd',
            repl = 'r',
            toggle = 't',
        },
        render = {
            indent = 1,
            max_value_lines = 100,
        },
    },
    config = function(_, opts)
        local dap = require 'dap'
        require('dapui').setup(opts)

        -- Customize breakpoint signs
        vim.api.nvim_set_hl(0, 'DapStoppedHl', { fg = '#98BB6C', bg = '#2A2A2A', bold = true })
        vim.api.nvim_set_hl(0, 'DapStoppedLineHl', { bg = '#204028', bold = true })
        vim.fn.sign_define('DapStopped', { text = '', texthl = 'DapStoppedHl', linehl = 'DapStoppedLineHl', numhl = '' })
        vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DiagnosticSignError', linehl = '', numhl = '' })
        vim.fn.sign_define('DapBreakpointCondition', { text = '', texthl = 'DiagnosticSignWarn', linehl = '', numhl = '' })
        vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DiagnosticSignError', linehl = '', numhl = '' })
        vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DiagnosticSignInfo', linehl = '', numhl = '' })

        dap.listeners.after.event_initialized['dapui_config'] = function()
            require('dapui').open()
        end

        -- Automatically skip over exceptions that don't originate from our project.
        -- Disable catching exceptions after one is found that doesn't originate from our project.
        dap.listeners.before.event_stopped['filter_non_project_exceptions'] = function(session, body)
            if body.reason == 'exception' then
                session:request('stackTrace', { threadId = body.threadId }, function(err, resp)
                    if not err and resp and resp.stackFrames then
                        for _, frame in ipairs(resp.stackFrames) do
                            local source = frame.source and frame.source.path or ''
                            -- 1    == start searching from the start
                            -- true == match literally (don't pattern match)
                            if source:find(vim.fn.getcwd(), 1, true) then
                                -- We are in our own packages code, so return now (avoiding a later call to 'continue')
                                return
                            end
                        end

                        -- We disable exception breakpoints upon catching an exception that doesn't originate from our
                        -- project as we expect to receive even more exceptions that don't originate from our project at this point.
                        vim.notify('Disabling exception breakpoints (see nvim-dap-ui.lua config for info)', vim.log.levels.INFO)
                        dap.set_exception_breakpoints {}

                        -- If none of the frames are yours, resume
                        session:request('continue', { threadId = body.threadId })
                    end
                end)
            end
        end

        dap.listeners.before.event_terminated['dapui_config'] = function()
            -- Commented to prevent DAP UI from closing when unit tests finish
            -- require('dapui').close()
        end

        dap.listeners.before.event_exited['dapui_config'] = function()
            -- Commented to prevent DAP UI from closing when unit tests finish
            -- require('dapui').close()
        end

        -- Add dap configurations based on your language/adapter settings
        -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
        dap.configurations.java = {
            {
                name = 'Debug Launch (2GB)',
                type = 'java',
                request = 'launch',
                vmArgs = '' .. '-Xmx2g ',
            },
            {
                name = 'Debug Attach (8000)',
                type = 'java',
                request = 'attach',
                hostName = '127.0.0.1',
                port = 8000,
            },
            {
                name = 'Debug Attach (5005)',
                type = 'java',
                request = 'attach',
                hostName = '127.0.0.1',
                port = 5005,
            },
            {
                name = 'My Custom Java Run Configuration',
                type = 'java',
                request = 'launch',
                -- You need to extend the classPath to list your dependencies.
                -- `nvim-jdtls` would automatically add the `classPaths` property if it is missing
                -- classPaths = {},

                -- If using multi-module projects, remove otherwise.
                -- projectName = "yourProjectName",

                -- javaExec = "java",
                mainClass = 'replace.with.your.fully.qualified.MainClass',

                -- If using the JDK9+ module system, this needs to be extended
                -- `nvim-jdtls` would automatically populate this property
                -- modulePaths = {},
                vmArgs = '' .. '-Xmx2g ',
            },
        }
    end,
}

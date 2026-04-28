local vault_path = vim.loop.os_uname().sysname == 'Darwin' and vim.fn.expand '~/Library/Mobile Documents/iCloud~md~obsidian/Documents/main'
    or '/mnt/c/Users/Alex/Documents/ObsidianVaults/Obsidian Vault'

if vim.fn.isdirectory(vault_path) == 0 then
    vim.notify('obsidian.nvim: vault not found at ' .. vault_path, vim.log.levels.INFO)
    return {}
end

return {
    'epwalsh/obsidian.nvim',
    version = '*',
    lazy = true,
    ft = 'markdown',
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    opts = {
        workspaces = {
            { name = 'ObsidianVault', path = vault_path },
        },
        ui = { enable = false },
    },
}

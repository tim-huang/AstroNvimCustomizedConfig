-- Configuration for neovide
-- For further information, visit https://neovide.dev/configuration.html
if vim.g.neovide then
  local alpha = function() return string.format("%x", math.floor((255 * vim.g.transparency) or 0.8)) end
  vim.o.guifont = "JetBrainsMono Nerd Font:h12"
  vim.g.neovide_transparency = 0.0
  vim.g.transparency = 0.8
  vim.g.neovide_background_color = "#0f1117" .. alpha()
  vim.g.neovide_input_macos_alt_is_meta = true

  -- Animate switch to command line
  vim.g.neovide_cursor_animate_command_line = true

  -- Cursor particles
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_cursor_vfx_particle_lifetime = 1.5
  vim.g.neovide_cursor_vfx_particle_density = 10.0

  -- Only enable IME in insert & search mode
  local function set_ime(args)
    if args.event:match "Enter$" then
      vim.g.neovide_input_ime = true
    else
      vim.g.neovide_input_ime = false
    end
  end

  local ime_input = vim.api.nvim_create_augroup("ime_input", { clear = true })

  vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
    group = ime_input,
    pattern = "*",
    callback = set_ime,
  })

  vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
    group = ime_input,
    pattern = "[/\\?]",
    callback = set_ime,
  })

  -- Enable cmd+c/cmd+v/cmd+s
  vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save
  vim.keymap.set("v", "<D-c>", '"+y') -- Copy
  vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
  vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
  vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
  vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode

  -- Toggle fullscreen
  vim.keymap.set("", "<D-f>", function() vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen end)
  vim.keymap.set("", "<C-D-f>", function() vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen end)
end

return {}

return {
  {
    "michaelb/sniprun",
    -- to run a post installation script (install.sh) is required, plese visit
    -- https://michaelb.github.io/sniprun/sources/README.html#installation
    -- the script can be found at ~/.local/share/nvim/lazy/sniprun
    -- init = "sh ./install.sh",
    opts = {},
    cmd = { "SnipRun", "SnipInfo", "SnipClose", "SnipReset" },
  },
}

local utils = require "astronvim.utils"
local is_available = utils.is_available

-- terminate dapDebugServer automatically after debugger detached
if is_available "nvim-dap" then
  require("dap").listeners.after.event_terminated["dapui_config"] = function(session)
    if session.parent then return end

    if is_available "nvim-dap-ui" then require("dapui").close {} end

    vim.fn.system(
      "ps -fea | grep node | grep 'dapDebugServer.js "
        .. session.adapter["port"]
        .. "' | grep -v grep | awk '{print $2}' | xargs kill -9"
    )
  end
end

return {}

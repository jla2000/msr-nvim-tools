local M = {}

function M.analyze()
  local Job = require("plenary.job")
  local notify = require("notify")
  local msr_workspace = string.match(vim.fn.expand("%:p:h"), "(.*)BSW.*")

  local single_file_analysis = string.format(
    "%s/Infrastructure/bauhaus/utils/single_file_analysis/single_file_analysis.py",
    msr_workspace
  )
  local ipcbinding_build_folder =
    string.format("%s/build/caches/linux_cafecc.cmake_cafecc_linux_x86_64", msr_workspace)
  local current_file = vim.fn.expand("%:p")

  local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }
  local spinner_frame_idx = 1
  local bauhaus_spinner = nil

  local filename = vim.fn.expand("%:t")
  local function update_spinner()
    if bauhaus_spinner then
      spinner_frame_idx = (spinner_frame_idx + 1) % #spinner_frames
      bauhaus_spinner = notify(filename, nil, {
        icon = spinner_frames[spinner_frame_idx],
        replace = bauhaus_spinner,
        hide_from_history = true,
      })
      vim.defer_fn(function()
        update_spinner()
      end, 100)
    end
  end

  bauhaus_spinner = notify(filename, "info", {
    title = "Bauhaus Single-File Analysis",
    icon = spinner_frames[spinner_frame_idx],
    timeout = false,
    hide_from_history = false,
  })
  update_spinner()

  -- Clear quickfix list
  vim.fn.setqflist({}, " ", { title = "Bauhaus Analyze" })
  vim.api.nvim_command("copen")

  local append_to_quickfix = function(error, data)
    local line = error and error or data
    vim.fn.setqflist({}, "a", { lines = { line } })
    vim.api.nvim_command("cbottom")
  end

  Job
    :new({
      command = "python3",
      args = {
        single_file_analysis,
        "-b" .. ipcbinding_build_folder,
        current_file,
      },
      on_stdout = vim.schedule_wrap(function(err, data)
        append_to_quickfix(err, data)
      end),
      on_stderr = vim.schedule_wrap(function(err, data)
        append_to_quickfix(err, data)
      end),
      on_exit = vim.schedule_wrap(function(_, code, signal)
        append_to_quickfix("Exited with code " .. code, "")
        local title = (code == 0) and "Analysis completed." or "Analysis failed!"
        local icon = (code == 0) and "" or ""
        notify(title, nil, {
          icon = icon,
          replace = bauhaus_spinner,
          timeout = 3000,
        })
        bauhaus_spinner = nil
      end),
    })
    :start()
end

return M

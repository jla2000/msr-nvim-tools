local M = {}

local Job = require("plenary.job")
local Path = require("plenary.path")
local notify = require("notify")

local title = "Bauhaus Single-File Analysis"

--- @param build_folder Path
function create_build_folder(build_folder)
  notify("Creating bauhaus build folder", "info", {
    title = title,
  })
end

function M.analyze()
  local current_file = vim.fn.expand("%:p")
  -- if not string.match(current_file, "*.cpp|*.h)") then
  --   notify("Not a c++ file", "error", {
  --     title = title,
  --   })
  --   return
  -- end

  local msr_workspace = string.match(current_file, "(.*)BSW.*")
  if msr_workspace == nil then
    notify("File does not belong to MSRA component", "error", {
      title = title,
    })
    return
  end

  local single_file_analysis = string.format(
    "%s/Infrastructure/bauhaus/utils/single_file_analysis/single_file_analysis.py",
    msr_workspace
  )

  if single_file_analysis == nil then
    notify("Failed to find single_file_analysis.py", "error", {
      title = title,
    })
    return
  end

  local build_folder = Path:new(msr_workspace .. "build/cafecc_linux_x86_64")
  if not build_folder:exists() then
    create_build_folder(build_folder)
  end

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
        "-b" .. build_folder.filename,
        current_file,
      },
      on_stdout = vim.schedule_wrap(function(err, data)
        append_to_quickfix(err, data)
      end),
      on_stderr = vim.schedule_wrap(function(err, data)
        append_to_quickfix(err, data)
      end),
      on_exit = vim.schedule_wrap(function(_, code, _)
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

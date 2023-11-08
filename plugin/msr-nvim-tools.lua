local msr_nvim_tools = require("msr-nvim-tools")

vim.api.nvim_create_user_command(
	"BauhausAnalyze", -- name
	msr_nvim_tools.bauhaus_analyze, -- command
	{ -- opts
		nargs = 0,
		desc = "Bauhaus Single-File Analysis",
	}
)

# msr-nvim-tools

## Usage

```lua
require("lazy").setup({
  "jla2000/msr-nvim-tools",
  ft = "cpp",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "rcarriga/nvim-notify",
    "L3MON4D3/LuaSnip",
  },
  config = true,
  keys = {
    {
      "<leader>ba",
      "<cmd>BauhausAnalyze<CR>",
      desc = "Bauhaus Single File Analysis",
    },
  },
})
```

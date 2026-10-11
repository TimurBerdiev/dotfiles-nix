return {
  {
    'MeanderingProgrammer/markdown.nvim',
    name = 'render-markdown',
    ft = { 'markdown' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {},
  },
  {
    'folke/which-key.nvim',
    lazy = false,
    config = true,  -- popup that shows what my leader keys do
  },
}


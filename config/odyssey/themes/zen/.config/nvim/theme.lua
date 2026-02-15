-- Odyssey by Lavdal
-- Theme: Zen
-- https://github.com/Lavdal-Yahya

return {
	{
		"vague2k/vague.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
		config = function(_, opts)
			require("vague").setup(opts)
			vim.cmd.colorscheme("vague")
		end,
	},
}

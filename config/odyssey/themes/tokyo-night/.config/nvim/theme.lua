-- Odyssey by Lavdal
-- Theme: Tokyo Night
-- https://github.com/Lavdal-Yahya

return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},
}

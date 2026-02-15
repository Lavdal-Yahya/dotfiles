-- Odyssey by Lavdal
-- Theme: Nordic
-- https://github.com/Lavdal-Yahya

return {
	{
		"AlexvZyl/nordic.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("nordic").load()
		end,
	},
}

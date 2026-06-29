return {
  {
    "3rd/image.nvim",
    cond = function()
      return require("config.terminal").supports_sixel()
    end,
    opts = {
      backend = "sixel",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          download_remote_images = true,
          only_render_image_at_cursor = true,
          only_render_image_at_cursor_mode = "popup",
        },
      },
    },
  },
}

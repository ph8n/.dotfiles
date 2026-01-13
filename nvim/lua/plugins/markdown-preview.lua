return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = "markdown",
  build = function()
    local install_path = vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim/app"
    vim.fn.system({ "bash", "-c", "cd " .. install_path .. " && npm install && git checkout ." })
  end,
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
}

return { -- CopilotChat
  "CopilotC-Nvim/CopilotChat.nvim",
  enabled = false,
  version = "*",
  config = function()
    require("CopilotChat").setup {
      prompts = {
        Fix = {
          prompt = 'There is a problem in this code. Identify the issues and rewrite the code with fixes. Explain what was wrong and how your changes address the problems. Do not put the explanation between the header and its code block., put it after the code block.',
        },
        Optimize = {
          prompt = 'Optimize the selected code to improve performance and readability. Explain your optimization strategy and the benefits of your changes. Do not put the explanation between the header and its code block, put it after the code block.',
        },
        Commit = {
          prompt = 'Write commit message for the change with commitizen convention. Keep the title under 50 characters and wrap message at 72 characters. Format as a gitcommit code block. Format the commit message body using bullet points.'
        },
      },
      mappings = {
        reset = { 
          normal = "<M-l>",
          insert = "<M-l>",
        },
      }
    }
    vim.keymap.set('n', '<Leader>co', ':CopilotChatOpen<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<Leader>cc', ':CopilotChatClose<CR>', { noremap = true, silent = true })
    -- Close preview window when copilot-chat window is closed
    vim.api.nvim_create_autocmd("WinClosed", {
      callback = function(args)
        local win = tonumber(args.match)
        if not win then return end
        local ok, buf = pcall(vim.api.nvim_win_get_buf, win)
        if not ok then return end
        local ft = vim.bo[buf].filetype
        if ft == "copilot-chat" or ft == "CopilotChat" then
          vim.cmd("silent! pclose")
        end
      end,
    })
  end,
}

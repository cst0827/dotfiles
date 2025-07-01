require("CopilotChat").setup {
    prompts = {
        Fix = {
            prompt = 'There is a problem in this code. Identify the issues and rewrite the code with fixes. Explain what was wrong and how your changes address the problems. Do not put the explanation between the header and its code block., put it after the code block.',
        },
        Optimize = {
            prompt = 'Optimize the selected code to improve performance and readability. Explain your optimization strategy and the benefits of your changes. Do not put the explanation between the header and its code block, put it after the code block.',
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

local fixer = require('fixer')

local M = {}

function M.commit(t)
    setmetatable(t, { __index = { type = "fixup", hunk_only = false } })

    require('telescope.builtin').git_commits {
        git_command = { "git", "log", "--pretty=oneline", "--abbrev-commit", "origin..HEAD" }, -- Only show commits since master/origin
        prompt_title = 'Select commit',
        attach_mappings = function(_, map)
            map('i', '<cr>', function(bufnr)
                local entry = require "telescope.actions.state".get_selected_entry()
                -- Close telescope-buffer here, so that the cursor will be on the hunk again!
                require "telescope.actions".close(bufnr)
                if t.hunk_only then
                    fixer.start_single_hunk_commit()
                end
                fixer.commit(t.type, entry.value)
                if t.hunk_only then
                    fixer.finish_single_hunk_commit()
                end
            end)
            return true
        end
    }
end

return M

local fixer = require('fixer')

local M = {}

function M.commit(t)
    local args = vim.tbl_deep_extend('force', fixer._config.default_picker_args, t)

    local git_log_cmd = { "git", "log", "--pretty=oneline", "--abbrev-commit" }
    if args.only_commits_since_main then
        table.insert(git_log_cmd, fixer.master_or_main() .. '..HEAD')
    end

    require('telescope.builtin').git_commits {
        git_command = git_log_cmd,
        prompt_title = 'Select commit',
        attach_mappings = function(_, map)
            map('i', '<cr>', function(bufnr)
                local entry = require "telescope.actions.state".get_selected_entry()
                -- Close telescope-buffer here, so that the cursor will be on the hunk again!
                require "telescope.actions".close(bufnr)
                if args.hunk_only then
                    fixer.start_single_hunk_commit()
                end
                fixer.commit(args.type, entry.value)
                if args.hunk_only then
                    fixer.finish_single_hunk_commit()
                end
            end)
            return true
        end
    }
end

return M

local fixer = require('fixer')

local M = {}

local match_commit_hash = function(line, opts)
    if type(opts.fn_match_commit_hash) == "function" then
        return opts.fn_match_commit_hash(line, opts)
    else
        return line:match("[^ ]+")
    end
end

function M.commit(t)
    local args = vim.tbl_deep_extend('force', fixer._config.default_picker_args, t)

    local git_log_cmd = "git log --pretty=oneline --abbrev-commit"
    if args.only_commits_since_main then
        git_log_cmd = git_log_cmd .. ' ' .. fixer.master_or_main() .. '..HEAD'
    end

    require 'fzf-lua'.git_commits {
        cmd = git_log_cmd,
        actions = {
            ["default"] = function(selected, opts)
                local entry = match_commit_hash(selected[1], opts)
                if args.hunk_only then
                    fixer.start_single_hunk_commit()
                end
                fixer.commit(args.type, entry)
                if args.hunk_only then
                    fixer.finish_single_hunk_commit()
                end
                return true
            end
        }
    }
end

return M

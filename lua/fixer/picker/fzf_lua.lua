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
    setmetatable(t, { __index = { type = "fixup", hunk_only = false } })

    require('fzf-lua').git_commits {
        actions = {
            ["default"] = function(selected, opts)
                local entry = match_commit_hash(selected[1], opts)
                if t.hunk_only then
                    fixer.start_single_hunk_commit()
                end
                fixer.commit(t.type, entry)
                if t.hunk_only then
                    fixer.finish_single_hunk_commit()
                end
                return true
            end
        }
    }
end

return M

local M = {}
local v = vim

-- Constants --
local TMP_DIFF_F = "/tmp/G_STAGED_HUNKS.diff"

-- Library functions --
function M.start_single_hunk_commit()
    v.cmd("silent exec \"!git diff --cached > " .. TMP_DIFF_F .. " ; git reset > /dev/null 2>&1\"")
    M._config.stage_hunk_action()
end

function M.finish_single_hunk_commit()
    v.cmd("silent exec \"! [ -s " ..
        TMP_DIFF_F ..
        " ] && git apply --3way --ignore-space-change --ignore-whitespace --cached " ..
        TMP_DIFF_F .. "> /dev/null 2>&1; exit 0\"")
    M._config.refresh_hunks_action()
end

function M.abort_single_hunk_commit()
    M._config.undo_stage_hunk_action()
    v.cmd("silent exec \"! [ -s " ..
        TMP_DIFF_F .. " ] && git apply --cached " .. TMP_DIFF_F .. "> /dev/null 2>&1; exit 0\"")
    M._config.refresh_hunks_action()
end

function M.commit(commit_type, commit_hash)
    assert(M.is_supported_commit_option(commit_type), "Commit type should be fixup, amend, reword or squash")
    local flag = M.commit_option_to_flag(commit_type)

    if commit_type == "fixup" then
        v.cmd("silent exec \"!git commit " .. flag .. commit_hash .. "\"")
    else
        v.cmd("G commit " .. flag .. commit_hash)
    end
end

function M.commit_option_to_flag(option)
    local option_to_flag = {
        fixup = "--fixup=",
        amend = "--fixup=amend:",
        reword = "--fixup=reword:",
        squash = "--squash="
    }
    return option_to_flag[option]
end

function M.is_supported_commit_option(option)
    return M.commit_option_to_flag(option) ~= nil
end

function M.commit_hunk()
    local msg = v.fn.input("Commit message: ")
    if msg == '' then
        return
    end
    M.start_single_hunk_commit()
    v.cmd("silent exec \"!git commit -m '" .. msg .. "'\"")
    M.finish_single_hunk_commit()
end

-- Configuration --

local function default_opts()
    return {
        stage_hunk_action = function() require("gitsigns").stage_hunk() end,
        undo_stage_hunk_action = function() require("gitsigns").undo_stage_hunk() end,
        refresh_hunks_action = function() require("gitsigns").refresh() end,
    }
end

M._config = default_opts()

function M.setup(opts)
    M._config = v.tbl_extend("force", M._config, opts)
end

return M

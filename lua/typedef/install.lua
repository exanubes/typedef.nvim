local env = require("typedef.env")
local config = require("typedef.config")
local data_dir = config.data_dir
local binary_name = config.binary_name
local binary_path = config.binary_path
local repo_name = config.repo_name

local function has_rpc_binary()
    return vim.fn.executable(binary_path) == 1
end

local function get_binary_version()
    local result = vim.system({ binary_path, "version" }, { text = true }):wait()

    if result.code ~= 0 then
        return {}, false
    end

    local ok, info = pcall(vim.json.decode, result.stdout)

    if not ok then
        return {}, false
    end

    return { version = info.version or "", commit = info.commit_sha or "", created_at = info.build_time or "" }, true
end
--- TODO: Replace vim.notify with custom logger that does not block the UI
local function compare(expected, received)
    if expected.version == "dev" then
        -- vim.notify("Dev mode detected, skipping version verification", vim.log.levels.WARN)
        return true, ""
    end

    if expected.version ~= received.version then
        return false, "Expected version: " .. expected.version .. ", received: " .. received.version
    end

    if expected.commit ~= received.commit then
        return false, "Expected commit: " .. expected.commit .. ", received: " .. received.commit
    end

    return true, ""
end

local function verify_binary()
    -- vim.notify("Verifying binary at: " .. binary_path, vim.log.levels.DEBUG)

    local has_binary = has_rpc_binary()
    if not has_binary then
        -- vim.notify("Binary not found", vim.log.levels.DEBUG)
        return false
    end

    local binary_version, ok = get_binary_version()

    if not ok then
        -- vim.notify("Failed to get binary version", vim.log.levels.DEBUG)
        return false
    end

    -- vim.notify(
    --     string.format("Binary version: %s, commit: %s", binary_version.version, binary_version.commit),
    --     vim.log.levels.DEBUG
    -- )
    -- vim.notify(string.format("Expected version: %s, commit: %s", env.version, env.commit), vim.log.levels.DEBUG)

    local ok2, err = compare(env, binary_version)

    if not ok2 then
        -- vim.notify("Version mismatch: " .. err, vim.log.levels.ERROR)
        error(err)
    end

    -- vim.notify("Binary verification successful", vim.log.levels.DEBUG)
    return true
end

local function ensure_tools()
    if vim.fn.executable("curl") ~= 1 then
        error("curl is required but not found in PATH")
    end

    if vim.fn.executable("tar") ~= 1 then
        error("tar is required but not found in PATH")
    end
end

--- @return "linux" | "darwin", "amd64" | "arm64"
local function detect_platform()
    local uname = vim.uv.os_uname()
    local os
    local arch

    if string.lower(uname.sysname) == "linux" then
        os = "linux"
    elseif string.lower(uname.sysname) == "darwin" then
        os = "darwin"
    else
        error("Unsupported OS: " .. uname.sysname)
    end

    if string.lower(uname.machine) == "x86_64" then
        arch = "amd64"
    elseif string.lower(uname.machine) == "arm64" or string.lower(uname.machine) == "aarch64" then
        arch = "arm64"
    else
        error("Unsupported architecture: " .. uname.machine)
    end

    return os, arch
end

--- @param artifact_name string
--- @param version string
--- @return string
local function create_download_url(artifact_name, version)
    if not version or version == "" or version == "unknown" then
        error("version is missing; cannot determine which release to download")
    end

    return string.format("https://github.com/%s/releases/download/v%s/%s", repo_name, version, artifact_name)
end

local function create_asset_name(os, arch)
    return string.format("%s-%s-%s.tar.gz", binary_name, os, arch)
end

---@param asset_name string
---@return string, string, string, string
local function create_temp_paths(asset_name)
    local tmpdir = vim.fn.tempname()
    vim.fn.mkdir(tmpdir, "p")
    local archive = tmpdir .. "/" .. asset_name
    local extracted_bin = tmpdir .. "/" .. binary_name
    local staged_bin = binary_path .. ".new"

    return tmpdir, archive, extracted_bin, staged_bin
end

---@param archive string
---@param url string
local function download_binary(archive, url)
    local result = vim.system({ "curl", "-L", "-f", "-o", archive, url }, { text = true }):wait()
    if result.code ~= 0 then
        error(string.format("Download failed(%d): %s", result.code, result.stderr or ""))
    end
end

local function extract_zip(archive, tmp, extracted_bin_path)
    local result = vim.system({ "tar", "-xzf", archive, "-C", tmp }, { text = true }):wait()
    if result.code ~= 0 then
        error(string.format("Extraction failed(%d): %s", result.code, result.stderr or ""))
    end

    if vim.fn.filereadable(extracted_bin_path) ~= 1 then
        error("Extracted archive did not contain expected binary: " .. extracted_bin_path)
    end
end

local function stage_new_binary(staged_bin_path, extracted_bin_path)
    vim.fn.delete(staged_bin_path) --- NOTE: ensuring the path is not occupied
    vim.fn.rename(extracted_bin_path, staged_bin_path)
    vim.fn.setfperm(staged_bin_path, "rwxr-xr-x")
end

local function replace_current_binary(staged_bin_path)
    vim.fn.delete(binary_path)
    vim.fn.rename(staged_bin_path, binary_path)
end

local function cleanup_temp_dirs(archive, tmpdir)
    pcall(vim.fn.delete, archive)
    pcall(vim.fn.delete, tmpdir, "rf")
end

local function download_and_install()
    ensure_tools()
    vim.fn.mkdir(data_dir, "p")
    local os, arch = detect_platform()
    local asset_name = create_asset_name(os, arch)
    local download_url = create_download_url(asset_name, env.version)
    local tmp_dir, archive_dir, extracted_bin_path, staged_bin_path = create_temp_paths(asset_name)
    download_binary(archive_dir, download_url)
    extract_zip(archive_dir, tmp_dir, extracted_bin_path)
    stage_new_binary(staged_bin_path, extracted_bin_path)
    replace_current_binary(staged_bin_path)
    cleanup_temp_dirs(archive_dir, tmp_dir)
end

return function()
    local ok, result = pcall(verify_binary)

    if ok and result then
        --- NOTE: binary is installed and matches the version of the plugin. Do nothing
        return
    end

    local okx, _ = xpcall(download_and_install, function(error)
        return debug.traceback(error, 2)
    end)

    if not okx then
        error("Failed to install rpc binary: ", vim.log.levels.ERROR)
    end

    local ok2, result2 = pcall(verify_binary)

    if not ok2 then
        error("Installed binary failed verification (error): " .. tostring(result2))
    end

    if not result2 then
        error("Installed binary failed verification (returned false)")
    end
end

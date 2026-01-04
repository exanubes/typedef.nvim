local data_dir = vim.fn.stdpath("data") .. "/typedef"
local binary_name = "typedef-rpc"
local binary_path = data_dir .. "/" .. binary_name
local repo_name = "exanubes/typedef"

return {
    data_dir = data_dir,
    binary_name = binary_name,
    binary_path = binary_path,
    repo_name = repo_name,
}

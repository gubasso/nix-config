-- Security: Protect sensitive files by disabling swap/backup/undo/shada
local api = vim.api

local function augroup(name)
  return api.nvim_create_augroup(name, { clear = true })
end

-- Protected patterns:
-- /dev/shm/gopass*        -> gopass temporary entries
-- *vault*                 -> Ansible vault-related paths
-- ~/.ansible/tmp*         -> Ansible temporary directory
-- */secret/*              -> Any path with a 'secret' directory
-- */secrets/*             -> Any path with a 'secrets' directory
-- ~/.aws/credentials      -> AWS credentials file
-- ~/.aws/config           -> AWS config file
-- ~/.docker/config.json   -> Docker credential store
-- ~/.git-credentials      -> Git stored credentials
-- ~/.npmrc                -> npm auth/token file
-- ~/.netrc                -> netrc credentials file
-- ~/.ssh/*                -> SSH keys and configs (private keys)
-- ~/.kube/config          -> Kubernetes kubeconfig (can contain tokens)
-- ~/.azure/*              -> Azure auth files
-- */.env                  -> .env files in project root
-- */.env.*                -> .env.* files (env variants)
local sensitive_files = {
  "/dev/shm/gopass*",
  "*vault*",
  "~/.ansible/tmp*",
  "*/secret/*",
  "*/secrets/*",
  "~/.aws/credentials",
  "~/.aws/config",
  "~/.docker/config.json",
  "~/.git-credentials",
  "~/.npmrc",
  "~/.netrc",
  "~/.ssh/*",
  "~/.kube/config",
  "~/.azure/*",
  "*/.env",
  "*/.env.*",
}

api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup("secure_sensitive_files"),
  pattern = sensitive_files,
  callback = function()
    -- Disable persistence and backups for buffers that may contain secrets
    vim.opt_local.swapfile = false
    vim.opt_local.backup = false
    vim.opt_local.writebackup = false
    vim.opt_local.undofile = false
    -- Clear shada so entries are not stored
    vim.opt_local.shada = ""
  end,
})

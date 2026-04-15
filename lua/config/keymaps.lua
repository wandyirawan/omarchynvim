-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local function unmap(mode, lhs)
  pcall(vim.api.nvim_del_keymap, mode, lhs)
end

-- Global variable to track current layout mode
_G.gallium_mode = false

-- Path to save Gallium state
local state_file = vim.fn.stdpath("data") .. "/gallium_state"

-- Load saved Gallium state
local function load_gallium_state()
  local file = io.open(state_file, "r")
  if file then
    local content = file:read("*all")
    file:close()
    return content == "true"
  end
  return false
end

-- Save Gallium state
local function save_gallium_state(enabled)
  local file = io.open(state_file, "w")
  if file then
    file:write(tostring(enabled))
    file:close()
  end
end

-- Gallium layout mappings (colstags variant)
-- Navigation: p,h,a,i (QWERTY: h,j,k,l)
-- Original functions: j=insert, k=append, -=paste, m=substitute
local function apply_gallium_mappings()
  -- ==================== NAVIGATION (Gallium → QWERTY) ====================
  map("", "p", "h", {}) -- left
  map("", "h", "j", {}) -- down
  map("", "a", "k", {}) -- up
  map("", "i", "l", {}) -- right

  -- Capital navigation
  map("", "P", "H", {}) -- left (cap)
  map("", "H", "J", {}) -- down (cap)
  map("", "A", "K", {}) -- up (cap)
  map("", "I", "L", {}) -- right (cap)

  -- ==================== ORIGINAL FUNCTIONS RESTORED ====================
  -- p (paste/put) → , (comma)
  map("", ",", "p", {})
  map("", "<", "P", {}) -- P = paste before

  -- i (insert) → j (Gallium home row!)
  map("", "j", "i", {})
  map("", "J", "I", {}) -- I = insert at BOL

  -- a (append) → k (Gallium home row!)
  map("", "k", "a", {})
  map("", "K", "A", {}) -- A = append at EOL

  -- o/O (open new line) → n/N
  map("", "n", "o", {}) -- open below
  map("", "N", "O", {}) -- open above

  -- l (join lines) → Gallium L stays as L → J
  map("", "l", "j", {}) -- join lines (l→j)
  map("", "L", "J", {}) -- Join lines (cap)

  -- ==================== KEEP ORIGINAL (no remap) ====================
  -- r/R (replace) → keep original: r=replace char, R=replace mode
  -- s/S (substitute) → use <leader>s instead (conflict with flash.nvim)
  --   s = delete char + insert (substitute char)
  --   S = delete line + insert (substitute line) 
  -- x/X (delete char) → keep original: x=delete char, X=delete char before
  -- y/Y (yank) → keep original
  -- c/C (change) → keep original: c=change, C=change to EOL
  -- d/D (delete) → keep original: d=delete, D=delete to EOL

  -- ==================== SUBSTITUTE (via leader, Gallium mode) ====================
  -- <leader>s = substitute character (original 's' - conflict with flash.nvim)
  -- <leader>S = substitute line (original 'S')

  vim.notify("Gallium layout activated", vim.log.levels.INFO)
end

local function remove_gallium_mappings()
  -- Remove Gallium mappings to restore normal QWERTY
  local keys = { "p", "h", "a", "i", ",", "<", "j", "J", "k", "K", "n", "N", "l", "L", "P", "H", "A", "I" }
  for _, key in ipairs(keys) do
    unmap("", key)
  end

  -- Remove Gallium-specific leader mappings
  pcall(vim.api.nvim_del_keymap, "n", "<leader>s")
  pcall(vim.api.nvim_del_keymap, "n", "<leader>S")

  vim.notify("Normal QWERTY layout activated", vim.log.levels.INFO)
end

-- Toggle function between Normal and Gallium
function ToggleGalliumLayout()
  if _G.gallium_mode then
    remove_gallium_mappings()
    _G.gallium_mode = false
    save_gallium_state(false)
  else
    apply_gallium_mappings()
    _G.gallium_mode = true
    save_gallium_state(true)
  end
  -- NOTE: If Neo-tree is open, close it (<leader>e) and reopen after toggle
  -- because Neo-tree mappings are set on startup and not dynamic
end

-- Auto-load Gallium layout on startup if it was enabled before
local function init_gallium()
  local should_enable = load_gallium_state()
  if should_enable then
    apply_gallium_mappings()
    _G.gallium_mode = true
  end
end

-- Initialize Gallium layout on startup
init_gallium()

-- Keybinding to toggle layout: <leader>tg
vim.keymap.set("n", "<leader>tg", ToggleGalliumLayout, { desc = "Toggle Gallium Layout" })

-- Gallium: <leader>s for substitute (s is used by flash.nvim)
-- These are set globally but only make sense when Gallium is active
vim.keymap.set("n", "<leader>s", "s", { desc = "Substitute character (Gallium)" })
vim.keymap.set("n", "<leader>S", "S", { desc = "Substitute line (Gallium)" })

-- Shortcut for quiting and saving (always active, even in Gallium)
-- Note: These override vim defaults:
--   Q = ex mode (we rarely use ex mode)
--   S = substitute line (use <leader>S in Gallium mode instead)
map("", "Q", ":q<cr>", {})
map("", "S", ":w<cr>", {})

-- Open file explorer with <leader>pv (Primeagen style)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open file explorer" })

-- Move selected lines in visual mode
-- J/K (capital) = move lines in QWERTY mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Gallium style: H and A for move lines in visual mode
-- H (Gallium down direction) = move selection down
-- A (Gallium up direction) = move selection up
vim.keymap.set("v", "H", ":m '>+1<CR>gv=gv", { desc = "Gallium: Move selection down" })
vim.keymap.set("v", "A", ":m '<-2<CR>gv=gv", { desc = "Gallium: Move selection up" })

-- Emergency keymap to kill ALL inlay hints immediately
vim.keymap.set("n", "<leader>uH", function()
  local bufnr = vim.api.nvim_get_current_buf()
  -- Try new API first (Neovim 0.10+)
  local ok = pcall(function()
    vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
  end)
  if not ok then
    -- Fallback to old API
    pcall(function()
      vim.lsp.inlay_hint.enable(bufnr, false)
    end)
  end
  -- Also try to clear virtual text
  vim.api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)
  vim.notify("All hints/virtual text cleared!", vim.log.levels.INFO)
end, { desc = "KILL All Inlay Hints (Emergency)" })

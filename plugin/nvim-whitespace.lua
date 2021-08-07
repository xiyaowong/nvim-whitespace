local fn = vim.fn

local function highlight()
  if
    fn.hlexists 'ExtraWhitespace' == 0
    or vim.api.nvim_exec('hi ExtraWhitespace', true):find 'cleared'
  then
    vim.cmd 'hi! ExtraWhitespace guifg=red'
  end
end

highlight()

local function toggle(mode)
  if vim.bo.filetype == '' or vim.bo.buftype ~= '' or not vim.bo.modifiable then
    return
  end
  local pattern = mode == 'i' and [[\s\+\%#\@<!$]] or [[\s\+$]]
  if vim.w.whitespace_match_id then
    fn.matchdelete(vim.w.whitespace_match_id)
    fn.matchadd('ExtraWhitespace', pattern, 10, vim.w.whitespace_match_id)
  else
    vim.w.whitespace_match_id = fn.matchadd('ExtraWhitespace', pattern)
  end
end

local function erase(line1, line2)
  local cursor = fn.getpos '.'
  vim.cmd(string.format([[silent! %d,%ds/\s\+$//e]], line1, line2))
  fn.setpos('.', cursor)
end

_G.___nvim_whitespace = { highlight = highlight, toggle = toggle, erase = erase }

vim.cmd [[augroup Whitespace]]
vim.cmd [[autocmd!]]
vim.cmd [[autocmd ColorScheme * lua ___nvim_whitespace.highlight()]]
vim.cmd [[autocmd BufEnter,FileType,InsertLeave * lua ___nvim_whitespace.toggle('n')]]
vim.cmd [[autocmd InsertEnter * lua ___nvim_whitespace.toggle('i')]]
vim.cmd [[augroup END]]

vim.cmd [[command! -range=% WhitespaceErase lua ___nvim_whitespace.erase(<line1>, <line2>)]]

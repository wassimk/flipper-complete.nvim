local flippers = require('flipper-complete.flippers')

local M = {}

--- Build LSP-format completion items for Flipper feature names.
---@param cursor_info { line_text: string, line_number: number, cursor_col: number }
---  line_number and cursor_col are 0-indexed
---@return lsp.CompletionItem[]|nil
function M.build_items(cursor_info)
  local line = cursor_info.line_text
  local col = cursor_info.cursor_col

  local before_cursor = line:sub(1, col)

  local method_prefix = before_cursor:match('([%w_.?]+)%(["\':]$')
  if not method_prefix then
    return nil
  end

  if not flippers.valid_prefix(method_prefix) then
    return nil
  end

  local len = #before_cursor
  local trigger_char = before_cursor:sub(len, len)

  local all_flippers = flippers.all(method_prefix)
  if not all_flippers or vim.tbl_isempty(all_flippers) then
    return nil
  end

  local items = {}
  for name, description in pairs(all_flippers) do
    table.insert(items, {
      filterText = trigger_char .. name,
      label = trigger_char .. name,
      documentation = description,
      textEdit = {
        newText = trigger_char .. name,
        range = {
          start = {
            line = cursor_info.line_number,
            character = len - 1,
          },
          ['end'] = {
            line = cursor_info.line_number,
            character = len,
          },
        },
      },
    })
  end

  return items
end

return M

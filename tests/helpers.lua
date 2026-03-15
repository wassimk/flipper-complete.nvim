local M = {}

local _originals = {}

M.test_yaml = table.concat({
  'ROLLOUT_enable_dark_mode: Allow users to toggle dark mode',
  'ROLLOUT_disable_legacy_ui: Phase out old interface',
  'ROLLOUT_test_feature_with_description: This should be excluded',
  'ROLLOUT_enable_notifications: Push notification support',
}, '\n')

M.test_yaml_lines = {
  'ROLLOUT_enable_dark_mode: Allow users to toggle dark mode',
  'ROLLOUT_disable_legacy_ui: Phase out old interface',
  'ROLLOUT_test_feature_with_description: This should be excluded',
  'ROLLOUT_enable_notifications: Push notification support',
  'ROLLOUT_enable_search: "Enables the new search feature"',
}

function M.setup_mocks()
  _originals = {
    filereadable = rawget(vim.fn, 'filereadable'),
    io_lines = io.lines,
  }

  M.file_exists = true

  vim.fn.filereadable = function(_)
    return M.file_exists and 1 or 0
  end

  io.lines = function(_)
    if not M.file_exists then
      error('No such file or directory')
    end

    local idx = 0
    return function()
      idx = idx + 1
      return M.test_yaml_lines[idx]
    end
  end
end

function M.teardown_mocks()
  rawset(vim.fn, 'filereadable', _originals.filereadable)
  io.lines = _originals.io_lines
  _originals = {}

  require('flipper-complete.flippers')._reset_cache()
  require('flipper-complete')._setup_called = false
  require('flipper-complete')._config = {
    features_path = './config/feature-descriptions.yml',
    prefixes = {
      'Features.enabled?',
      'Features.feature_enabled?',
      'featureEnabled',
      'feature_enabled?',
      'with_feature',
      'without_feature',
    },
  }

  M.file_exists = true
end

return M

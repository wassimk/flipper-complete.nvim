local helpers = require('helpers')
local items = require('flipper-complete.items')
local flipper_complete = require('flipper-complete')

describe('items', function()
  before_each(function()
    helpers.setup_mocks()
    flipper_complete.setup()
  end)

  after_each(function()
    helpers.teardown_mocks()
  end)

  it('returns items when line matches a flipper method with quote trigger', function()
    local result = items.build_items({
      line_text = 'Features.enabled?("',
      line_number = 3,
      cursor_col = 20,
    })

    assert.is_not_nil(result)
    assert.equals(4, #result)
  end)

  it('returns items when line matches with single quote trigger', function()
    local result = items.build_items({
      line_text = "Features.enabled?('",
      line_number = 0,
      cursor_col = 20,
    })

    assert.is_not_nil(result)
    assert.equals(4, #result)
  end)

  it('returns items when line matches with colon trigger', function()
    local result = items.build_items({
      line_text = 'Features.enabled?(:',
      line_number = 0,
      cursor_col = 20,
    })

    assert.is_not_nil(result)
    assert.equals(4, #result)
  end)

  it('returns nil when line is plain text', function()
    local result = items.build_items({
      line_text = 'some plain text',
      line_number = 0,
      cursor_col = 15,
    })

    assert.is_nil(result)
  end)

  it('returns nil when prefix is not a valid flipper method', function()
    local result = items.build_items({
      line_text = 'SomeOther.method("',
      line_number = 0,
      cursor_col = 19,
    })

    assert.is_nil(result)
  end)

  it('has correct filterText with trigger char and name', function()
    local result = items.build_items({
      line_text = 'Features.enabled?("',
      line_number = 0,
      cursor_col = 20,
    })

    assert.is_not_nil(result)
    local filter_texts = {}
    for _, item in ipairs(result) do
      filter_texts[item.filterText] = true
    end
    assert.is_true(filter_texts['"ROLLOUT_enable_dark_mode'])
    assert.is_true(filter_texts['"ROLLOUT_disable_legacy_ui'])
    assert.is_true(filter_texts['"ROLLOUT_enable_notifications'])
  end)

  it('has correct documentation from YAML description', function()
    local result = items.build_items({
      line_text = 'Features.enabled?("',
      line_number = 0,
      cursor_col = 20,
    })

    assert.is_not_nil(result)
    local docs = {}
    for _, item in ipairs(result) do
      docs[item.label] = item.documentation
    end
    assert.equals('Allow users to toggle dark mode', docs['"ROLLOUT_enable_dark_mode'])
  end)

  it('has correct textEdit range from trigger to cursor', function()
    local result = items.build_items({
      line_text = 'Features.enabled?("',
      line_number = 5,
      cursor_col = 20,
    })

    assert.is_not_nil(result)
    local item = result[1]
    assert.equals(5, item.textEdit.range.start.line)
    assert.equals(18, item.textEdit.range.start.character)
    assert.equals(5, item.textEdit.range['end'].line)
    assert.equals(19, item.textEdit.range['end'].character)
  end)

  it('works with featureEnabled prefix for JS camelCase', function()
    local result = items.build_items({
      line_text = 'featureEnabled("',
      line_number = 0,
      cursor_col = 16,
    })

    assert.is_not_nil(result)
    local filter_texts = {}
    for _, item in ipairs(result) do
      filter_texts[item.filterText] = true
    end
    assert.is_true(filter_texts['"dark_mode'])
    assert.is_true(filter_texts['"legacy_ui'])
    assert.is_true(filter_texts['"notifications'])
  end)

  it('works with with_feature prefix', function()
    local result = items.build_items({
      line_text = 'with_feature("',
      line_number = 0,
      cursor_col = 14,
    })

    assert.is_not_nil(result)
    assert.equals(4, #result)
  end)

  it('returns nil when features file is missing', function()
    helpers.file_exists = false
    require('flipper-complete.flippers')._reset_cache()
    flipper_complete.setup()

    local result = items.build_items({
      line_text = 'Features.enabled?("',
      line_number = 0,
      cursor_col = 20,
    })

    assert.is_nil(result)
  end)

  it('works with featureEnabled inside JS if-condition parentheses', function()
    local result = items.build_items({
      line_text = 'if (featureEnabled("',
      line_number = 0,
      cursor_col = 20,
    })

    assert.is_not_nil(result)
    local filter_texts = {}
    for _, item in ipairs(result) do
      filter_texts[item.filterText] = true
    end
    assert.is_true(filter_texts['"dark_mode'])
    assert.is_true(filter_texts['"legacy_ui'])
    assert.is_true(filter_texts['"notifications'])
  end)

  it('works with indented lines', function()
    local result = items.build_items({
      line_text = '    if Features.enabled?("',
      line_number = 0,
      cursor_col = 26,
    })

    assert.is_not_nil(result)
    assert.equals(4, #result)
  end)
end)

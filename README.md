# flipper-complete.nvim

Autocomplete [Flipper](https://github.com/jnunemaker/flipper) feature flag
names in Neovim. Reads feature names and descriptions from a YAML config file
and suggests them when typing flipper method calls.

## 📋 Requirements

- **Neovim 0.10+**
- [blink.cmp](https://github.com/Saghen/blink.cmp) or [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

## 🛠️ Installation

### blink.cmp

```lua
{
  'saghen/blink.cmp',
  dependencies = {
    { 'wassimk/flipper-complete.nvim' },
  },
  opts = {
    sources = {
      per_filetype = {
        ruby = { inherit_defaults = true, 'flipper_complete' },
      },
      providers = {
        flipper_complete = {
          name = 'flipper_complete',
          module = 'flipper-complete.blink',
          opts = {
            features_path = './config/feature-descriptions.yml', -- optional
          },
        },
      },
    },
  },
}
```

### nvim-cmp

The source auto-registers when nvim-cmp is detected:

```lua
{ 'wassimk/flipper-complete.nvim' }
```

Add `flipper_complete` to your nvim-cmp sources for the ruby filetype.

## 💻 Usage

The plugin reads feature names from `./config/feature-descriptions.yml` (relative
to your project root). This file should contain lines in the format:

```yaml
ROLLOUT_enable_dark_mode: Allow users to toggle dark mode
ROLLOUT_disable_legacy_ui: Phase out old interface
```

Completions trigger when typing flipper method calls such as:

- `Features.enabled?("`
- `Features.feature_enabled?("`
- `featureEnabled("`
- `feature_enabled?("`
- `with_feature("`
- `without_feature("`

The trigger characters are `"`, `'`, and `:` (for Ruby symbols).

When using the `featureEnabled` JavaScript prefix, feature names are
automatically transformed to camelCase format (stripping the `ROLLOUT_` prefix
and `enable_`/`disable_` prefixes).

## 🔧 Configuration

Pass options via blink.cmp's provider `opts` or `require('flipper-complete').setup()`:

```lua
-- blink.cmp provider opts
flipper_complete = {
  name = 'flipper_complete',
  module = 'flipper-complete.blink',
  opts = {
    features_path = './config/feature-descriptions.yml',
    prefixes = {
      'Features.enabled?',
      'Features.feature_enabled?',
      'featureEnabled',
      'feature_enabled?',
      'with_feature',
      'without_feature',
    },
  },
}

-- or standalone setup (nvim-cmp users)
require('flipper-complete').setup({
  features_path = './config/feature-descriptions.yml',
})
```

| Option | Default | Description |
| --- | --- | --- |
| `features_path` | `./config/feature-descriptions.yml` | Path to the YAML features file |
| `prefixes` | See above | List of method prefixes that trigger completion |

## 🔨 Development

Run tests and lint:

```shell
make test
make lint
```

Enable the local git hooks (one-time setup):

```shell
git config core.hooksPath .githooks
```

This activates a pre-commit hook that auto-generates `doc/flipper-complete.nvim.txt` from `README.md` whenever the README is staged. Requires [pandoc](https://pandoc.org/installing.html).

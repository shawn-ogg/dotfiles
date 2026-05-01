# Lean Neovim Config v2

Optimized for:
- Bash
- Python
- Markdown
- YAML / GitHub Actions
- fast shell vi-mode editing

## Key Optimization

LSP and Treesitter are loaded ONLY for real filetypes.

This keeps:
- shell `v` editing instant
- temp buffers fast
- commit editing lightweight

while still enabling full IDE features in projects.

## Install

```bash
mv ~/.config/nvim ~/.config/nvim-old
cp -r nvim-lean-v2 ~/.config/nvim
```

## Dependencies

```bash
brew install neovim ripgrep
brew install bash-language-server shellcheck
brew install pyright
brew install yaml-language-server
```

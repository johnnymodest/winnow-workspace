#!/bin/sh
set -euo pipefail

echo "==> Setting up Winnow dev environment..."

# --- npm global path ---
export PATH="/workspace/.npm-global/bin:$PATH"
echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> ~/.zshrc

echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# --- BMAD ---
echo "==> Installing BMAD..."
npm install -g bmad-method
echo "    BMAD: $(bmad --version 2>/dev/null || echo 'installed')"

# --- OpenCode ---
curl -fsSL https://opencode.ai/install | bash
sudo chown -R node:node ~/.local

# --- Ensure .npm-global exists ---
mkdir -p /workspace/.npm-global

echo ""
echo "==> Done."
echo "    Workspace : /workspace          (winnow-workspace, private)"
echo "    OSS skill : /projects/winnow   (winnow, public when ready)"
echo ""
echo "    Next: open winnow.code-workspace, then run BMAD against brief.md"

#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up Winnow dev environment..."

# --- npm global path ---
export PATH="/workspace/.npm-global/bin:$PATH"
echo 'export PATH="/workspace/.npm-global/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="/workspace/.npm-global/bin:$PATH"' >> ~/.zshrc

# --- BMAD ---
echo "==> Installing BMAD..."
npm install -g bmad-method
echo "    BMAD: $(bmad --version 2>/dev/null || echo 'installed')"

# --- OpenCode ---
# Verify at https://opencode.ai/docs if this fails
echo "==> Installing OpenCode..."
curl -fsSL https://opencode.ai/install | sh 2>/dev/null \
  || echo "    WARNING: OpenCode install failed — check https://opencode.ai/docs"

# --- Ensure .npm-global exists ---
mkdir -p /workspace/.npm-global

echo ""
echo "==> Done."
echo "    Workspace : /workspace          (winnow-workspace, private)"
echo "    OSS skill : /projects/winnow   (winnow, public when ready)"
echo ""
echo "    Next: open winnow.code-workspace, then run BMAD against brief.md"

#!/bin/bash
set -euo pipefail

echo -e "⏳ Installing xwaylandvideobridge package..."
yay -S --noconfirm --needed xwaylandvideobridge
echo -e "✅ xwaylandvideobridge package installed"

echo -e "✅ Xwayland extras configured\n"
sleep 3
clear
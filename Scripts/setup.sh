#!/bin/bash
set -e

if command -v dnf &> /dev/null; then
    PM=dnf
else
    PM=yum
fi

sudo $PM update -y
sudo $PM install -y docker
sudo systemctl enable docker
sudo systemctl start docker
echo "🔥 EC2 setup complete with Docker!"

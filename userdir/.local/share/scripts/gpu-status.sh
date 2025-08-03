#!/bin/zsh

echo "=== GPU Status ==="
echo "Intel GPU:"
glxinfo | grep "OpenGL renderer" | head -1

echo -e "\nNVIDIA GPU (with prime-run):"
prime-run glxinfo | grep "OpenGL renderer" | head -1

echo -e "\nActive GPU processes:"
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv 2>/dev/null || echo "No NVIDIA processes running"

echo -e "\nDRM devices:"
ls -la /dev/dri/

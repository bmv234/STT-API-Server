#!/bin/bash

# Stop on error
set -e

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: docker is not installed"
    exit 1
fi

# Check if nvidia-docker is installed
if ! docker info 2>/dev/null | grep -q "Runtimes.*nvidia"; then
    echo "Warning: nvidia-docker runtime not found. GPU support may not be available."
    echo "Install nvidia-docker2 for GPU support."
fi

# Check for required files
required_files=(
    "main.py"
    "main-ui.py"
    "templates/index.html"
    "requirements.txt"
)

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Error: Required file '$file' not found"
        exit 1
    fi
done

echo "Building Speech-to-Text Server Docker image..."
echo "Using CUDA 12.6.3 with development tools"

# Build the Docker image with progress output
docker build \
  --network=host \
  --progress=plain \
  --tag stt-server:latest \
  --tag stt-server:cuda12.6.3 \
  .

echo
echo "Build complete!"
echo
echo "You can run the server with:"
echo "docker run --gpus all -p 8000:8000 \\"
echo "  -v \$(pwd)/output:/app/output \\"
echo "  -v \$(pwd)/uploads:/app/uploads \\"
echo "  stt-server:latest"
echo
echo "To verify GPU support:"
echo "docker run --gpus all --rm stt-server:latest python -c 'import torch; print(f\"CUDA available: {torch.cuda.is_available()}\")'"
echo
echo "To check server health:"
echo "curl --insecure https://localhost:8000/health"
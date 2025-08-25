# Base ComfyUI Docker Image
FROM python:3.11-slim

# Build arguments
ARG COMFYUI_VERSION=v0.3.7

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    ffmpeg \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libglib2.0-0 \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /app

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git . && \
    git checkout ${COMFYUI_VERSION}

# Install Python dependencies
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && \
    pip install --no-cache-dir -r requirements.txt

# Create necessary directories
RUN mkdir -p models/checkpoints \
    models/clip \
    models/clip_vision \
    models/controlnet \
    models/diffusers \
    models/embeddings \
    models/gligen \
    models/hypernetworks \
    models/loras \
    models/style_models \
    models/unet \
    models/upscale_models \
    models/vae \
    output \
    input \
    temp

# Expose port
EXPOSE 8188

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8188/ || exit 1

# Run ComfyUI
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
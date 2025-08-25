# Extended ComfyUI Docker Image with Popular Plugins
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
    build-essential \
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
    temp \
    custom_nodes

# Install popular custom nodes
WORKDIR /app/custom_nodes

# ComfyUI-Manager - Essential plugin manager
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git

# ComfyUI-Impact-Pack - Advanced node pack
RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git && \
    cd ComfyUI-Impact-Pack && \
    git submodule update --init --recursive && \
    pip install --no-cache-dir -r requirements.txt || true

# ComfyUI-Inspire-Pack - Additional creative nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Inspire-Pack.git && \
    cd ComfyUI-Inspire-Pack && \
    pip install --no-cache-dir -r requirements.txt || true

# ComfyUI_IPAdapter_plus - IP-Adapter nodes
RUN git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git

# ComfyUI-Advanced-ControlNet - Advanced ControlNet nodes
RUN git clone https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git

# ComfyUI-AnimateDiff-Evolved - Animation nodes
RUN git clone https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git

# ComfyUI-VideoHelperSuite - Video processing nodes
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
    cd ComfyUI-VideoHelperSuite && \
    pip install --no-cache-dir -r requirements.txt || true

# ComfyUI_essentials - Essential utility nodes
RUN git clone https://github.com/cubiq/ComfyUI_essentials.git && \
    cd ComfyUI_essentials && \
    pip install --no-cache-dir -r requirements.txt || true

# ComfyUI-Custom-Scripts - UI enhancements
RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git

# WAS Node Suite - Comprehensive node collection
RUN git clone https://github.com/WASasquatch/was-node-suite-comfyui.git && \
    cd was-node-suite-comfyui && \
    pip install --no-cache-dir -r requirements.txt || true

# ComfyUI-KJNodes - Additional utility nodes
RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git && \
    cd ComfyUI-KJNodes && \
    pip install --no-cache-dir -r requirements.txt || true

# rgthree-comfy - Quality of life improvements
RUN git clone https://github.com/rgthree/rgthree-comfy.git

# ComfyUI_Comfyroll_CustomNodes - Workflow enhancement nodes
RUN git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git

# efficiency-nodes-comfyui - Performance optimization nodes
RUN git clone https://github.com/jags111/efficiency-nodes-comfyui.git && \
    cd efficiency-nodes-comfyui && \
    pip install --no-cache-dir -r requirements.txt || true

# Install additional commonly needed Python packages
RUN pip install --no-cache-dir \
    opencv-python \
    scikit-image \
    matplotlib \
    pandas \
    scipy \
    transformers \
    accelerate \
    onnxruntime \
    insightface \
    segment-anything

WORKDIR /app

# Copy plugins list for reference
COPY plugins.txt /app/plugins.txt

# Expose port
EXPOSE 8188

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8188/ || exit 1

# Run ComfyUI
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
# ---- Odin AI · Stable-Diffusion WebUI for RTX 5090 (Blackwell) ----
FROM nvidia/cuda:12.8.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/New_York \
    PYTHONUNBUFFERED=1 \
    CUDA_VISIBLE_DEVICES=0 \
    TORCH_CUDA_ARCH_LIST=12.0 \
    FORCE_CUDA=1 \
    CUDA_HOME=/usr/local/cuda

# --- OS prerequisites --------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y --no-install-recommends \
        python3.11 python3.11-venv python3.11-dev python3.11-distutils python3-pip git \
        build-essential ninja-build cmake pkg-config \
        libjpeg-dev libpng-dev ffmpeg && \
    rm -rf /var/lib/apt/lists/* && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# --- Core Python stack (PyTorch nightly cu128) -------------------------------
RUN python -m pip install --upgrade pip \
 && python -m pip install --pre torch torchvision torchaudio \
        --index-url https://download.pytorch.org/whl/nightly/cu128

# --- Build xFormers (no wheel yet for cu128) ---
RUN python -m pip install ninja cmake packaging wheel \
 && python -m pip install -v --no-build-isolation --no-cache-dir \
      git+https://github.com/facebookresearch/xformers.git@main#egg=xformers

# --- Build Flash-Attention 2 (needs packaging inside build venv) ---
RUN python -m pip install --no-cache-dir "packaging>=23.2" \
 && MAX_JOBS=4 python -m pip install -v --no-build-isolation --no-cache-dir \
      git+https://github.com/Dao-AILab/flash-attention.git@main#egg=flash-attn \
      --config-settings=--install-option="--sm=120"

# --- Remaining runtime deps ---
RUN python -m pip install --no-cache-dir \
      opencv-python-headless pillow scipy \
      "transformers>=4.42" huggingface_hub gradio_client \
      fastapi uvicorn[standard] pydantic orjson

# --- App user & WebUI ---
RUN groupadd -g 988 docker && useradd -m -s /bin/bash -u 1000 -g 988 odin
USER odin
WORKDIR /workspace
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git webui
WORKDIR /workspace/webui
RUN python launch.py --skip-install || true

EXPOSE 7860
CMD ["python","launch.py","--ckpt-dir","/opt/ai/models/stable-diffusion", \
     "--port","7860","--listen","--api", \
     "--xformers","--medvram","--opt-split-attention"]

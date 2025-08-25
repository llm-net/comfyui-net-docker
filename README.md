# ComfyUI Docker Images

自动构建和发布 [ComfyUI](https://github.com/comfyanonymous/ComfyUI) Docker 镜像的仓库。每当 ComfyUI 发布新版本时，自动创建对应的 Docker 镜像并发布到 Docker Hub。

## 特性

- 🚀 **自动化构建**: 每小时检查 ComfyUI 新版本，自动触发构建
- 📦 **双版本策略**: 提供基础版和扩展版两种镜像
- 🔌 **插件预装**: 扩展版包含常用插件和节点包
- 🌍 **多架构支持**: 支持 AMD64 和 ARM64 架构
- 🔄 **版本追踪**: 自动记录已构建版本，避免重复构建

## 镜像版本

### 基础版 (Base)
纯净的 ComfyUI 安装，仅包含核心功能。

```bash
docker pull llmnet/comfyui-net:latest
docker pull llmnet/comfyui-net:v0.3.7
```

### 扩展版 (Extend)
预装了常用插件和自定义节点的完整版本。

```bash
docker pull llmnet/comfyui-net:latest-extend
docker pull llmnet/comfyui-net:v0.3.7-extend
```

#### 扩展版包含的插件:
- ComfyUI-Manager - 插件管理器
- ComfyUI-Impact-Pack - 高级节点包
- ComfyUI-Inspire-Pack - 创意节点包
- ComfyUI_IPAdapter_plus - IP-Adapter 节点
- ComfyUI-Advanced-ControlNet - 高级 ControlNet
- ComfyUI-AnimateDiff-Evolved - 动画生成
- ComfyUI-VideoHelperSuite - 视频处理
- ComfyUI_essentials - 实用工具节点
- ComfyUI-Custom-Scripts - UI 增强
- WAS Node Suite - 综合节点集
- 更多...

完整列表见 [plugins.txt](dockerfiles/extend/plugins.txt)

## 快速开始

### 使用 Docker Run

基础版:
```bash
docker run -d \
  --name comfyui \
  --gpus all \
  -p 8188:8188 \
  -v ./models:/app/models \
  -v ./output:/app/output \
  -v ./input:/app/input \
  llmnet/comfyui-net:latest
```

扩展版:
```bash
docker run -d \
  --name comfyui-extend \
  --gpus all \
  -p 8188:8188 \
  -v ./models:/app/models \
  -v ./output:/app/output \
  -v ./input:/app/input \
  -v ./custom_nodes:/app/custom_nodes \
  llmnet/comfyui-net:latest-extend
```

### 使用 Docker Compose

1. 克隆仓库:
```bash
git clone https://github.com/llmnet/comfyui-docker.git
cd comfyui-docker
```

2. 配置环境变量 (可选):
```bash
export DOCKER_USERNAME=llmnet
export COMFYUI_VERSION=v0.3.7
```

3. 启动服务:
```bash
# 启动基础版
docker-compose up -d comfyui-base

# 启动扩展版
docker-compose up -d comfyui-extend

# 或同时启动两个版本
docker-compose up -d
```

4. 访问 ComfyUI:
- 基础版: http://localhost:8188
- 扩展版: http://localhost:8189

## 本地构建

### 前置要求
- Docker 和 Docker Buildx
- Python 3.11+
- Git

### 构建步骤

1. 克隆仓库:
```bash
git clone https://github.com/llmnet/comfyui-docker.git
cd comfyui-docker
```

2. 设置 Docker Hub 用户名:
```bash
export DOCKER_USERNAME=llmnet
```

3. 构建镜像:
```bash
# 构建基础版
./scripts/build.sh v0.3.7 base

# 构建扩展版
./scripts/build.sh v0.3.7 extend

# 构建所有版本
./scripts/build.sh v0.3.7 all
```

4. 推送到 Docker Hub (需要先登录):
```bash
docker login
./scripts/push.sh v0.3.7 all
```

## 目录结构

```
comfyui-docker/
├── dockerfiles/
│   ├── base/                    # 基础镜像 Dockerfile
│   └── extend/                  # 扩展镜像 Dockerfile
│       └── plugins.txt          # 插件列表文档
├── scripts/
│   ├── build.sh                 # 本地构建脚本
│   ├── push.sh                  # 推送脚本
│   ├── check-release.py         # 版本检查脚本
│   └── update_versions.py       # 版本更新脚本
├── configs/
│   ├── extra_model_paths.yaml   # 额外模型路径配置
│   └── config.yaml              # ComfyUI 配置示例
├── docker-compose.yml           # Docker Compose 配置
├── versions.json                # 版本追踪文件
└── README.md                    # 本文档
```

## 配置说明

### 模型路径配置
编辑 `configs/extra_model_paths.yaml` 可以配置额外的模型路径，例如共享 Stable Diffusion WebUI 的模型:

```yaml
stable-diffusion-webui:
  base_path: /data/stable-diffusion-webui/
  checkpoints: models/Stable-diffusion
  vae: models/VAE
  loras: models/Lora
```

### 环境变量
- `PYTHONUNBUFFERED=1` - Python 输出不缓冲
- `CUDA_VISIBLE_DEVICES=0` - 指定使用的 GPU
- `TZ=Asia/Shanghai` - 时区设置

## GitHub Actions 自动化

### 自动版本检查
- 每小时运行一次
- 检查 ComfyUI 新版本
- 发现新版本自动触发构建

### 手动触发构建
在 GitHub Actions 页面可以手动触发构建:
1. 进入 Actions 标签
2. 选择 "Manual Build and Push"
3. 点击 "Run workflow"
4. 输入版本号和构建类型

## 故障排除

### GPU 不可用
确保安装了 NVIDIA Docker 支持:
```bash
# Ubuntu/Debian
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update && sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

### 内存不足
调整 Docker 内存限制或使用 lowvram 模式:
```bash
docker run -d \
  --name comfyui \
  --gpus all \
  -p 8188:8188 \
  -v ./models:/app/models \
  llmnet/comfyui-net:latest \
  python main.py --listen 0.0.0.0 --lowvram
```

### 插件安装失败
扩展版已预装常用插件。如需安装其他插件:
1. 挂载 custom_nodes 目录
2. 使用 ComfyUI-Manager 在线安装
3. 或手动克隆到 custom_nodes 目录

## 贡献

欢迎提交 Issue 和 Pull Request！

### 添加新插件
1. 编辑 `dockerfiles/extend/Dockerfile`
2. 在适当位置添加插件安装命令
3. 更新 `dockerfiles/extend/plugins.txt` 文档
4. 提交 PR

## 许可证

本项目采用 Apache License 2.0 许可证。详见 [LICENSE](LICENSE) 文件。

## 相关链接

- [ComfyUI 官方仓库](https://github.com/comfyanonymous/ComfyUI)
- [ComfyUI Manager](https://github.com/ltdrdata/ComfyUI-Manager)
- [Docker Hub 镜像](https://hub.docker.com/r/llmnet/comfyui-net)

## 更新日志

查看 [versions.json](versions.json) 了解已构建的版本历史。

---


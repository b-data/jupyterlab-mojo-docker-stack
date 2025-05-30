# CUDA Version Matrix

Image tags = MAX versions

Topmost entry = Tag `latest`

| MAX    | Python  | CUDA   | Linux distro |
|:-------|:--------|:-------|:-------------|
| 25.3.0 | 3.12.10 | 12.8.1 | Ubuntu 22.04 |
| 25.2.0 | 3.12.10 | 12.8.1 | Ubuntu 22.04 |
| 25.1.0 | 3.12.9  | 12.8.1 | Ubuntu 22.04 |
| 24.6.0 | 3.12.9  | 12.8.0 | Ubuntu 22.04 |

## PyTorch compatibility

| Python | CUDA | PyTorch[^1]   |
|:-------|:-----|:--------------|
| 3.12   | 12.8 | version ≥ 2.4 |

[^1]: Ships with its own CUDA dependencies

## Recommended NVIDIA driver (Regular)

| CUDA   | Linux driver version | Windows driver version[^2] |
|:-------|:---------------------|:---------------------------|
| 12.8.1 | ≥ 570.124.06         | ≥ 572.61                   |
| 12.8.0 | ≥ 570.117            | ≥ 572.30                   |

[^2]: [GPU support in Docker Desktop | Docker Docs](https://docs.docker.com/desktop/gpu/),
[Nvidia GPU Support for Windows · Issue #19005 · containers/podman](https://github.com/containers/podman/issues/19005)

## Supported NVIDIA drivers (LTSB)

Only works with
[NVIDIA Data Center GPUs](https://resources.nvidia.com/l/en-us-gpu) or
[select NGC-Ready NVIDIA RTX boards](https://docs.nvidia.com/certification-programs/ngc-ready-systems/index.html).

| CUDA   | Driver version 535[^3] | Driver version 470[^4] |
|:-------|:----------------------:|:----------------------:|
| 12.8.1 | 🟢                      | 🔵                      |
| 12.8.0 | 🟢                      | 🔵                      |

🔵: Supported with the CUDA forward compat package only  
🟢: Supported due to minor-version compatibility[^5]  
🟡: Supported due to backward compatibility

[^3]: EOL: June 2026  
[^4]: EOL: July 2024
[^5]: or the CUDA forward compat package

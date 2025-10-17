# CUDA Version Matrix

Image tags = MAX versions

Topmost entry = Tag `latest`

| MAX    | Python  | CUDA   | Linux distro |
|:-------|:--------|:-------|:-------------|
| 25.6.0 | 3.13.9  | 13.0.1 | Ubuntu 24.04 |
| 25.5.0 | 3.13.7  | 13.0.1 | Ubuntu 24.04 |
| 25.4.0 | 3.12.11 | 12.9.0 | Ubuntu 22.04 |
| 25.3.0 | 3.12.11 | 12.9.0 | Ubuntu 22.04 |
| 25.2.0 | 3.12.10 | 12.8.1 | Ubuntu 22.04 |
| 25.1.0 | 3.12.9  | 12.8.1 | Ubuntu 22.04 |
| 24.6.0 | 3.12.9  | 12.8.0 | Ubuntu 22.04 |

## PyTorch compatibility

| Python | CUDA | PyTorch[^1]   |
|:-------|:-----|:--------------|
| 3.13   | 13.0 | version ≥ 2.9 |
| 3.12   | 12.9 | version ≥ 2.4 |
| 3.12   | 12.8 | version ≥ 2.4 |

[^1]: Ships with its own CUDA dependencies

## Recommended NVIDIA driver (Regular)

| CUDA   | Linux driver version | Windows driver version[^2] |
|:-------|:---------------------|:---------------------------|
| 13.0.1 | ≥ 580.82.07          | n/a                        |
| 12.9.0 | ≥ 575.51.03          | ≥ 576.02                   |
| 12.8.1 | ≥ 570.124.06         | ≥ 572.61                   |
| 12.8.0 | ≥ 570.117            | ≥ 572.30                   |

[^2]: [GPU support in Docker Desktop | Docker Docs](https://docs.docker.com/desktop/gpu/),
[Nvidia GPU Support for Windows · Issue #19005 · containers/podman](https://github.com/containers/podman/issues/19005)

## Supported NVIDIA drivers (LTSB)

Only works with
[NVIDIA Data Center GPUs](https://resources.nvidia.com/l/en-us-gpu) or
[select NGC-Ready NVIDIA RTX boards](https://docs.nvidia.com/certification-programs/ngc-ready-systems/index.html).

| CUDA   | Driver version 580[^3] | Driver version 535[^4] | Driver version 470[^5] |
|:-------|:----------------------:|:----------------------:|:----------------------:|
| 13.0.1 | 🟢                      | 🔵                      | 🔴                      |
| 12.9.0 | 🟡                      | 🟢                      | 🔵                      |
| 12.8.1 | 🟡                      | 🟢                      | 🔵                      |
| 12.8.0 | 🟡                      | 🟢                      | 🔵                      |

🔴: Not supported  
🔵: Supported with the CUDA forward compat package only  
🟢: Supported due to minor-version compatibility  
🟡: Supported due to backward compatibility

[^3]: EOL: August 2028  
[^4]: EOL: June 2026  
[^5]: EOL: July 2024

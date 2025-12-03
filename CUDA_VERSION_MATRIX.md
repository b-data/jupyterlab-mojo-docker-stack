# CUDA Version Matrix

Image tags = MAX versions

Topmost entry = Tag `latest`

| MAX    | Python  | CUDA   | Linux distro |
|:-------|:--------|:-------|:-------------|
| 25.7.0 | 3.13.10 | 13.0.2 | Ubuntu 24.04 |
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

## Recommended NVIDIA driver (PB)

| CUDA   | Linux driver version | Windows driver version[^2] |
|:-------|:---------------------|:---------------------------|
| 13.0.2 | ≥ 580.95.05          | n/a                        |
| 13.0.1 | ≥ 580.82.07          | n/a                        |
| 12.9.0 | ≥ 575.51.03          | ≥ 576.02                   |
| 12.8.1 | ≥ 570.124.06         | ≥ 572.61                   |
| 12.8.0 | ≥ 570.117            | ≥ 572.30                   |

[^2]: [GPU support in Docker Desktop | Docker Docs](https://docs.docker.com/desktop/gpu/),
[Nvidia GPU Support for Windows · Issue #19005 · containers/podman](https://github.com/containers/podman/issues/19005)

### GPU software requirements according to Modular

| MAX                   | Driver version |
|----------------------:|:---------------|
|                  25.7 | ≥ 580          |
| 25.7 > version ≥ 25.3 | ≥ 550          |
| 25.3 > version ≥ 25.1 | ≥ 555          |
|                  24.6 | ≥ ???          |

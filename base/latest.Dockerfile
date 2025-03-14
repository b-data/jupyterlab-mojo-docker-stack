ARG BASE_IMAGE=debian
ARG BASE_IMAGE_TAG=12
ARG BUILD_ON_IMAGE=glcr.b-data.ch/python/ver
ARG MOJO_VERSION
ARG MOJO_EXTENSION_VERSION=${MOJO_VERSION}
ARG PYTHON_VERSION
ARG CUDA_IMAGE_FLAVOR

ARG NB_USER=jovyan
ARG NB_UID=1000
ARG JUPYTERHUB_VERSION=5.2.1
ARG JUPYTERLAB_VERSION=4.3.5
ARG CODE_BUILTIN_EXTENSIONS_DIR=/opt/code-server/lib/vscode/extensions
ARG CODE_SERVER_VERSION=4.98.0
ARG NEOVIM_VERSION=0.10.4
ARG GIT_VERSION=2.48.1
ARG GIT_LFS_VERSION=3.6.1
ARG PANDOC_VERSION=3.4

ARG INSTALL_MAX
ARG BASE_SELECT=${INSTALL_MAX:+max}

FROM ${BUILD_ON_IMAGE}${PYTHON_VERSION:+:}${PYTHON_VERSION}${CUDA_IMAGE_FLAVOR:+-}${CUDA_IMAGE_FLAVOR} AS files

ARG NB_UID
ENV NB_GID=100

RUN mkdir /files

COPY assets /files
COPY conf/ipython /files
COPY conf/jupyter /files
COPY conf/jupyterlab /files
COPY conf/shell /files
COPY conf${CUDA_IMAGE:+/cuda}/shell /files
COPY conf/user /files
COPY scripts /files

  ## Copy content of skel directory to backup
RUN cp -a /files/etc/skel/. /files/var/backups/skel \
  && chown -R ${NB_UID}:${NB_GID} /files/var/backups/skel \
  ## Copy custom fonts
  && mkdir -p /files/usr/local/share/jupyter/lab/static/assets \
  && cp -a /files/opt/code-server/src/browser/media/css \
    /files/usr/local/share/jupyter/lab/static/assets \
  && cp -a /files/opt/code-server/src/browser/media/fonts \
    /files/usr/local/share/jupyter/lab/static/assets \
  && if [ -n "${CUDA_VERSION}" ]; then \
    ## Use entrypoint of CUDA image
    apt-get update; \
    apt-get -y install --no-install-recommends git; \
    git clone https://gitlab.com/nvidia/container-images/cuda.git \
      /opt/nvidia; \
    mv /opt/nvidia/entrypoint.d /opt/nvidia/nvidia_entrypoint.sh \
      /files/usr/local/bin; \
    mv /files/usr/local/bin/start.sh \
      /files/usr/local/bin/entrypoint.d/99-start.sh; \
    mv /files/usr/local/bin/nvidia_entrypoint.sh \
      /files/usr/local/bin/start.sh; \
  fi \
  ## Ensure file modes are correct when using CI
  ## Otherwise set to 777 in the target image
  && find /files -type d -exec chmod 755 {} \; \
  && find /files -type f -exec chmod 644 {} \; \
  && find /files/usr/local/bin -type f -exec chmod 755 {} \; \
  && find /files/etc/profile.d -type f -exec chmod 755 {} \;

FROM glcr.b-data.ch/neovim/nvsi:${NEOVIM_VERSION} AS nvsi
FROM glcr.b-data.ch/git/gsi/${GIT_VERSION}/${BASE_IMAGE}:${BASE_IMAGE_TAG} AS gsi
FROM glcr.b-data.ch/git-lfs/glfsi:${GIT_LFS_VERSION} AS glfsi

FROM ${BUILD_ON_IMAGE}${PYTHON_VERSION:+:}${PYTHON_VERSION}${CUDA_IMAGE_FLAVOR:+-}${CUDA_IMAGE_FLAVOR} AS base-max

## For use with the NVIDIA Container Runtime
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

FROM ${BUILD_ON_IMAGE}${PYTHON_VERSION:+:}${PYTHON_VERSION}${CUDA_IMAGE_FLAVOR:+-}${CUDA_IMAGE_FLAVOR} AS base-mojo

FROM base-${BASE_SELECT:-mojo} AS base

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_ON_IMAGE
ARG MOJO_VERSION
ARG CUDA_IMAGE_FLAVOR

ARG NB_USER
ARG NB_UID
ARG JUPYTERHUB_VERSION
ARG JUPYTERLAB_VERSION
ARG CODE_BUILTIN_EXTENSIONS_DIR
ARG CODE_SERVER_VERSION
ARG NEOVIM_VERSION
ARG GIT_VERSION
ARG GIT_LFS_VERSION
ARG PANDOC_VERSION

ARG CODE_WORKDIR

ARG CUDA_IMAGE_LICENSE=${CUDA_VERSION:+"NVIDIA Deep Learning Container License"}
ARG IMAGE_LICENSE=${CUDA_IMAGE_LICENSE:-"MIT"}
ARG IMAGE_SOURCE=https://gitlab.b-data.ch/jupyterlab/mojo/docker-stack
ARG IMAGE_VENDOR="b-data GmbH"
ARG IMAGE_AUTHORS="Olivier Benz <olivier.benz@b-data.ch>"

LABEL org.opencontainers.image.licenses="$IMAGE_LICENSE" \
      org.opencontainers.image.source="$IMAGE_SOURCE" \
      org.opencontainers.image.vendor="$IMAGE_VENDOR" \
      org.opencontainers.image.authors="$IMAGE_AUTHORS"

ENV PARENT_IMAGE=${BUILD_ON_IMAGE}${PYTHON_VERSION:+:}${PYTHON_VERSION}${CUDA_IMAGE_FLAVOR:+-}${CUDA_IMAGE_FLAVOR} \
    MODULAR_HOME=/opt/modular/share/max \
    MOJO_VERSION=${MOJO_VERSION%%-*} \
    NB_USER=${NB_USER} \
    NB_UID=${NB_UID} \
    JUPYTERHUB_VERSION=${JUPYTERHUB_VERSION} \
    JUPYTERLAB_VERSION=${JUPYTERLAB_VERSION} \
    CODE_SERVER_VERSION=${CODE_SERVER_VERSION} \
    NEOVIM_VERSION=${NEOVIM_VERSION} \
    GIT_VERSION=${GIT_VERSION} \
    GIT_LFS_VERSION=${GIT_LFS_VERSION} \
    PANDOC_VERSION=${PANDOC_VERSION}

ENV NB_GID=100

## Install Neovim
COPY --from=nvsi /usr/local /usr/local
## Install Git
COPY --from=gsi /usr/local /usr/local
## Install Git LFS
COPY --from=glfsi /usr/local /usr/local

USER root

RUN dpkgArch="$(dpkg --print-architecture)" \
  ## Unminimise if the system has been minimised
  && if [ $(command -v unminimize) ]; then \
    yes | unminimize; \
  fi \
  && apt-get update \
  && apt-get -y install --no-install-recommends \
    bash-completion \
    build-essential \
    curl \
    file \
    fontconfig \
    g++ \
    gcc \
    gfortran \
    gnupg \
    htop \
    info \
    jq \
    libclang-dev \
    man-db \
    nano \
    ncdu \
    procps \
    psmisc \
    screen \
    sudo \
    swig \
    tmux \
    vim-tiny \
    wget \
    zsh \
    ## Neovim: Additional runtime recommendations
    ripgrep \
    ## Git: Additional runtime dependencies
    libcurl3-gnutls \
    liberror-perl \
    ## Git: Additional runtime recommendations
    less \
    ssh-client \
    ## Python: For h5py wheels (arm64)
    libhdf5-dev \
  ## Python: Additional dev dependencies
  && if [ -z "${PYTHON_VERSION}" ]; then \
    apt-get -y install --no-install-recommends \
      python3-dev \
      ## Install Python package installer
      ## (dep: python3-distutils, python3-setuptools and python3-wheel)
      python3-pip \
      ## Install venv module for python3
      python3-venv; \
    ## make some useful symlinks that are expected to exist
    ## ("/usr/bin/python" and friends)
    for src in pydoc3 python3 python3-config; do \
      dst="$(echo "$src" | tr -d 3)"; \
      if [ -s "/usr/bin/$src" ] && [ ! -e "/usr/bin/$dst" ]; then \
        ln -svT "$src" "/usr/bin/$dst"; \
      fi \
    done; \
  else \
    ## Force update pip, setuptools and wheel
    pip install --upgrade --force-reinstall \
      pip \
      setuptools \
      wheel; \
  fi \
  ## MAX/Mojo: Additional runtime dependency
  && apt-get -y install --no-install-recommends libncurses-dev \
  ## mblack: Additional Python dependencies
  && export PIP_BREAK_SYSTEM_PACKAGES=1 \
  && pip install \
    click \
    mypy-extensions \
    packaging \
    pathspec \
    platformdirs \
  ## Install font MesloLGS NF
  && mkdir -p /usr/share/fonts/truetype/meslo \
  && curl -sL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -o "/usr/share/fonts/truetype/meslo/MesloLGS NF Regular.ttf" \
  && curl -sL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -o "/usr/share/fonts/truetype/meslo/MesloLGS NF Bold.ttf" \
  && curl -sL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf -o "/usr/share/fonts/truetype/meslo/MesloLGS NF Italic.ttf" \
  && curl -sL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf -o "/usr/share/fonts/truetype/meslo/MesloLGS NF Bold Italic.ttf" \
  && fc-cache -fsv \
  ## Git: Set default branch name to main
  && git config --system init.defaultBranch main \
  ## Git: Store passwords for one hour in memory
  && git config --system credential.helper "cache --timeout=3600" \
  ## Git: Merge the default branch from the default remote when "git pull" is run
  && git config --system pull.rebase false \
  ## Install pandoc
  && curl -sLO https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-${dpkgArch}.deb \
  && dpkg -i pandoc-${PANDOC_VERSION}-1-${dpkgArch}.deb \
  && rm pandoc-${PANDOC_VERSION}-1-${dpkgArch}.deb \
  ## Delete potential user with UID 1000
  && if grep -q 1000 /etc/passwd; then \
    userdel --remove $(id -un 1000); \
  fi \
  ## Do not set user limits for sudo/sudo-i
  && sed -i 's/.*pam_limits.so/#&/g' /etc/pam.d/sudo \
  && if [ -f "/etc/pam.d/sudo-i" ]; then \
    sed -i 's/.*pam_limits.so/#&/g' /etc/pam.d/sudo-i; \
  fi \
  ## Add user
  && useradd -l -m -s $(which zsh) -N -u ${NB_UID} ${NB_USER} \
  ## Mark home directory as populated
  && touch /home/${NB_USER}/.populated \
  && chown ${NB_UID}:${NB_GID} /home/${NB_USER}/.populated \
  && chmod go+w /home/${NB_USER}/.populated \
  ## Create backup directory for home directory
  && mkdir -p /var/backups/skel \
  && chown ${NB_UID}:${NB_GID} /var/backups/skel \
  ## Install Tini
  && curl -sL https://github.com/krallin/tini/releases/download/v0.19.0/tini-${dpkgArch} -o /usr/local/bin/tini \
  && chmod +x /usr/local/bin/tini \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/* \
    ${HOME}/.cache

FROM base AS modular

ARG NB_GID=100

ARG MOJO_VERSION
ARG INSTALL_MAX

  ## Install Magic
RUN export MODULAR_HOME="$HOME/.modular" \
  && curl -ssL https://magic.modular.com | bash \
  && mv ${HOME}/.modular/bin/magic /usr/local/bin \
  ## Clean up
  && rm -rf ${HOME}/.modular \
  && rm -rf /usr/local/lib/python${PYTHON_VERSION%.*}/site-packages/*

  ## Install MAX/Mojo
RUN cd /tmp \
  && if [ "${INSTALL_MAX}" = "1" ] || [ "${INSTALL_MAX}" = "true" ]; then \
    if [ "${MOJO_VERSION}" = "nightly" ]; then \
      magic init -c conda-forge -c https://conda.modular.com/max-nightly; \
      magic add max; \
    else \
      magic init -c conda-forge -c https://conda.modular.com/max; \
      magic add max==${MOJO_VERSION}; \
    fi \
  else \
    if [ "${MOJO_VERSION}" = "nightly" ]; then \
      magic init -c conda-forge -c https://conda.modular.com/max-nightly; \
      magic add mojo-jupyter; \
    else \
      magic init -c conda-forge -c https://conda.modular.com/max; \
      magic add mojo-jupyter==${MOJO_VERSION}; \
    fi \
  fi \
  ## Disable telemetry
  && magic telemetry --manifest-path pixi.toml --disable \
  ## Get rid of all the unnecessary stuff
  ## and move installation to /opt/modular
  && mkdir -p /opt/modular/bin \
  && mkdir -p /opt/modular/lib \
  && mkdir -p /opt/modular/share \
  && cd /tmp/.magic/envs \
  && if [ "${INSTALL_MAX}" = "1" ] || [ "${INSTALL_MAX}" = "true" ]; then \
    cp -a default/lib/libDevice* \
      default/lib/libGenericMLSupport* \
      default/lib/libmodular* \
      default/lib/libmof.so \
      default/lib/*MOGG* \
      default/lib/libmonnx.so \
      default/lib/libmtorch.so \
      default/lib/libStock* \
      default/lib/libTorch* \
      /opt/modular/lib; \
  fi \
  && if [ "${INSTALL_MAX}" = "1" ] || [ "${INSTALL_MAX}" = "true" ]; then \
    cp -a default/lib/python${PYTHON_VERSION%.*}/site-packages/max* \
      /usr/local/lib/python${PYTHON_VERSION%.*}/site-packages; \
  fi \
  && cp -a default/bin/lldb* \
    default/bin/mblack \
    default/bin/modular* \
    default/bin/mojo* \
    /opt/modular/bin \
  && cp -a default/lib/libAsyncRT* \
    default/lib/libATenRT.so \
    default/lib/libKGENCompilerRT* \
    default/lib/liblldb* \
    default/lib/libMGPRT.so \
    default/lib/libMojo* \
    default/lib/libMSupport* \
    default/lib/liborc_rt.a \
    default/lib/lldb* \
    default/lib/mojo* \
    /opt/modular/lib \
  && cp -a default/lib/python${PYTHON_VERSION%.*}/site-packages/*mblack* \
    default/lib/python${PYTHON_VERSION%.*}/site-packages/mblib* \
    /usr/local/lib/python${PYTHON_VERSION%.*}/site-packages \
  && cp -a default/share/max /opt/modular/share \
  && cp -a default/test /opt/modular \
  && mkdir ${MODULAR_HOME}/crashdb \
  && rm ${MODULAR_HOME}/firstActivation \
  ## Fix Modular home for Mojo
  && sed -i "s|/tmp/.magic/envs/default|/opt/modular|g" \
    ${MODULAR_HOME}/modular.cfg \
  ## Fix Python path for mblack
  && sed -i "s|/tmp/.magic/envs/default|/usr/local|g" \
    /opt/modular/bin/mblack \
  ## Fix permissions
  && chown -R root:${NB_GID} /opt/modular \
  && chmod -R g+w ${MODULAR_HOME}

## Install the Mojo kernel for Jupyter
RUN mkdir -p /usr/local/share/jupyter/kernels \
  && mv /tmp/.magic/envs/default/share/jupyter/kernels/mojo* \
    /usr/local/share/jupyter/kernels/ \
  ## Fix Modular home in the Mojo kernel for Jupyter
  && grep -rl /tmp/.magic/envs/default/share/jupyter /usr/local/share/jupyter/kernels/mojo* | \
    xargs sed -i "s|/tmp/.magic/envs/default|/usr/local|g" \
  && grep -rl /usr/local/share/max /usr/local/share/jupyter/kernels/mojo* | \
    xargs sed -i "s|/usr/local/share/max|/opt/modular/share/max|g" \
  ## Change display name in the Mojo kernel for Jupyter
  && sed -i "s|\"display_name\".*|\"display_name\": \"Mojo $MOJO_VERSION ${INSTALL_MAX:+(MAX)}\",|g" \
    /usr/local/share/jupyter/kernels/mojo*/kernel.json \
  && if [ "${MOJO_VERSION}" = "nightly" ]; then \
    cp -a /usr/local/share/jupyter/kernels/mojo*/nightly-logo-64x64.png \
      /usr/local/share/jupyter/kernels/mojo*/logo-64x64.png; \
    cp -a /usr/local/share/jupyter/kernels/mojo*/nightly-logo.svg \
      /usr/local/share/jupyter/kernels/mojo*/logo.svg; \
  fi

FROM base

ARG MOJO_EXTENSION_VERSION
ARG INSTALL_MAX

ENV PATH=/opt/code-server/bin:$PATH \
    CS_DISABLE_GETTING_STARTED_OVERRIDE=1

## Install code-server
RUN mkdir /opt/code-server \
  && cd /opt/code-server \
  && curl -sL https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-$(dpkg --print-architecture).tar.gz | tar zxf - --no-same-owner --strip-components=1 \
  ## Copy custom fonts
  && mkdir -p /opt/code-server/src/browser/media/fonts \
  && cp -a /usr/share/fonts/truetype/meslo/*.ttf /opt/code-server/src/browser/media/fonts \
  ## Include custom fonts
  && sed -i 's|</head>|	<link rel="preload" href="{{BASE}}/_static/src/browser/media/fonts/MesloLGS NF Regular.woff2" as="font" type="font/woff2" crossorigin="anonymous">\n	</head>|g' /opt/code-server/lib/vscode/out/vs/code/browser/workbench/workbench.html \
  && sed -i 's|</head>|	<link rel="preload" href="{{BASE}}/_static/src/browser/media/fonts/MesloLGS NF Italic.woff2" as="font" type="font/woff2" crossorigin="anonymous">\n	</head>|g' /opt/code-server/lib/vscode/out/vs/code/browser/workbench/workbench.html \
  && sed -i 's|</head>|	<link rel="preload" href="{{BASE}}/_static/src/browser/media/fonts/MesloLGS NF Bold.woff2" as="font" type="font/woff2" crossorigin="anonymous">\n	</head>|g' /opt/code-server/lib/vscode/out/vs/code/browser/workbench/workbench.html \
  && sed -i 's|</head>|	<link rel="preload" href="{{BASE}}/_static/src/browser/media/fonts/MesloLGS NF Bold Italic.woff2" as="font" type="font/woff2" crossorigin="anonymous">\n	</head>|g' /opt/code-server/lib/vscode/out/vs/code/browser/workbench/workbench.html \
  && sed -i 's|</head>|	<link rel="stylesheet" type="text/css" href="{{BASE}}/_static/src/browser/media/css/fonts.css">\n	</head>|g' /opt/code-server/lib/vscode/out/vs/code/browser/workbench/workbench.html \
  ## Install code-server extensions
  && cd /tmp \
  && curl -sLO https://dl.b-data.ch/vsix/piotrpalarz.vscode-gitignore-generator-1.0.3.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension piotrpalarz.vscode-gitignore-generator-1.0.3.vsix \
  && curl -sLO https://dl.b-data.ch/vsix/mutantdino.resourcemonitor-1.0.7.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension mutantdino.resourcemonitor-1.0.7.vsix \
  && curl -sLO https://dl.b-data.ch/vsix/modular-mojotools.vscode-mojo-${MOJO_EXTENSION_VERSION}.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension modular-mojotools.vscode-mojo-${MOJO_EXTENSION_VERSION}.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension alefragnani.project-manager \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension GitHub.vscode-pull-request-github \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension GitLab.gitlab-workflow \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension ms-python.python \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension ms-toolsai.jupyter \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension christian-kohler.path-intellisense \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension eamodio.gitlens@11.7.0 \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension mhutchie.git-graph \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension redhat.vscode-yaml \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension grapecity.gc-excelviewer \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension editorconfig.editorconfig@0.16.6 \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension DavidAnson.vscode-markdownlint \
  ## Fix permissions for Python Debugger extension
  && chown :${NB_GID} /opt/code-server/lib/vscode/extensions/ms-python.debugpy-* \
  && chmod g+w /opt/code-server/lib/vscode/extensions/ms-python.debugpy-* \
  ## Create folders temp and tmp for Jupyter extension
  && cd /opt/code-server/lib/vscode/extensions/ms-toolsai.jupyter-* \
  && mkdir -m 1777 temp \
  && mkdir -m 1777 tmp \
  ## Clean up
  && rm -rf /tmp/* \
    ${HOME}/.config \
    ${HOME}/.local

## Install JupyterLab
RUN export PIP_BREAK_SYSTEM_PACKAGES=1 \
  && pip install \
    jupyter-server-proxy \
    jupyterhub==${JUPYTERHUB_VERSION} \
    jupyterlab==${JUPYTERLAB_VERSION} \
    jupyterlab-git \
    jupyterlab-lsp \
    notebook \
    nbclassic \
    nbconvert \
    python-lsp-server[all] \
  ## Jupyter Server Proxy: Set maximum allowed HTTP body size to 10 GiB
  && sed -i 's/AsyncHTTPClient(/AsyncHTTPClient(max_body_size=10737418240, /g' \
    /usr/local/lib/python*/*-packages/jupyter_server_proxy/handlers.py \
  ## Jupyter Server Proxy: Set maximum allowed websocket message size to 1 GiB
  && sed -i 's/"_default_max_message_size",.*$/"_default_max_message_size", 1024 \* 1024 \* 1024/g' \
    /usr/local/lib/python*/*-packages/jupyter_server_proxy/websocket.py \
  && sed -i 's/_default_max_message_size =.*$/_default_max_message_size = 1024 \* 1024 \* 1024/g' \
    /usr/local/lib/python*/*-packages/tornado/websocket.py \
  ## Copy custom fonts
  && mkdir -p /usr/local/share/jupyter/lab/static/assets/fonts \
  && cp -a /usr/share/fonts/truetype/meslo/*.ttf /usr/local/share/jupyter/lab/static/assets/fonts \
  ## Include custom fonts
  && sed -i 's|</head>|<link rel="preload" href="{{page_config.fullStaticUrl}}/assets/fonts/MesloLGS NF Regular.woff2" as="font" type="font/woff2" crossorigin="anonymous"></head>|g' /usr/local/share/jupyter/lab/static/index.html \
  && sed -i 's|</head>|<link rel="preload" href="{{page_config.fullStaticUrl}}/assets/fonts/MesloLGS NF Italic.woff2" as="font" type="font/woff2" crossorigin="anonymous"></head>|g' /usr/local/share/jupyter/lab/static/index.html \
  && sed -i 's|</head>|<link rel="preload" href="{{page_config.fullStaticUrl}}/assets/fonts/MesloLGS NF Bold.woff2" as="font" type="font/woff2" crossorigin="anonymous"></head>|g' /usr/local/share/jupyter/lab/static/index.html \
  && sed -i 's|</head>|<link rel="preload" href="{{page_config.fullStaticUrl}}/assets/fonts/MesloLGS NF Bold Italic.woff2" as="font" type="font/woff2" crossorigin="anonymous"></head>|g' /usr/local/share/jupyter/lab/static/index.html \
  && sed -i 's|</head>|<link rel="stylesheet" type="text/css" href="{{page_config.fullStaticUrl}}/assets/css/fonts.css"></head>|g' /usr/local/share/jupyter/lab/static/index.html \
  ## Clean up
  && rm -rf /tmp/* \
    ${HOME}/.cache

ENV PATH=/opt/modular/bin:$PATH
ENV MAGIC_NO_PATH_UPDATE=1

## Install MAX/Mojo
COPY --from=modular /opt /opt
## Install the Mojo kernel for Jupyter
COPY --from=modular /usr/local/share/jupyter /usr/local/share/jupyter
## Install Python packages to the site library
COPY --from=modular /usr/local/lib/python${PYTHON_VERSION%.*}/site-packages \
  /usr/local/lib/python${PYTHON_VERSION%.*}/site-packages

RUN echo MODULAR_HOME=\"\$HOME/.modular\" > /tmp/magicenv \
  && curl -ssL https://magic.modular.com | grep '^BIN_DIR' >> /tmp/magicenv \
  && cp /tmp/magicenv /var/tmp/magicenv.bak \
  && cp /tmp/magicenv /tmp/magicenv.mod \
  && chown ${NB_UID}:${NB_GID} /tmp/magicenv /tmp/magicenv.mod \
  ## Create the user's modular bin dir
  && . /tmp/magicenv \
  && mkdir -p ${BIN_DIR} \
  ## Append the user's modular bin dir to PATH
  && sed -i 's/\$HOME/\\$HOME/g' /tmp/magicenv.mod \
  && . /tmp/magicenv.mod \
  && echo "\n# Append the user's modular bin dir to PATH\nif [[ \"\$PATH\" != *\"${BIN_DIR}\"* ]] ; then\n    PATH=\"\$PATH:${BIN_DIR}\"\nfi" | tee -a ${HOME}/.bashrc \
    /etc/skel/.bashrc \
  ## Create the user's modular bin dir in the skeleton directory
  && HOME=/etc/skel . /tmp/magicenv \
  && mkdir -p ${BIN_DIR} \
  ## MAX/Mojo: Install Python dependencies
  && export PIP_BREAK_SYSTEM_PACKAGES=1 \
  && if [ "${INSTALL_MAX}" = "1" ] || [ "${INSTALL_MAX}" = "true" ]; then \
    if [ -z "${CUDA_VERSION}" ]; then \
      ## MAX: Install CPU-only version of PyTorch in regular images
      export PIP_EXTRA_INDEX_URL="https://download.pytorch.org/whl/cpu"; \
    fi; \
    packages=$(grep "Requires-Dist:" \
      /usr/local/lib/python${PYTHON_VERSION%.*}/site-packages/max*.dist-info/METADATA | \
      sed "s|Requires-Dist: \(.*\)|\1|" | \
      tr -d "[:blank:]"); \
    pip install $packages; \
  else \
    pip install numpy; \
  fi \
  ## Clean up
  && rm -rf ${HOME}/.cache

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}

ENV HOME=/home/${NB_USER} \
    CODE_WORKDIR=${CODE_WORKDIR:-/home/${NB_USER}/projects} \
    SHELL=/usr/bin/zsh \
    TERM=xterm-256color

WORKDIR ${HOME}

## Install Oh My Zsh with Powerlevel10k theme
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
  && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${HOME}/.oh-my-zsh/custom/themes/powerlevel10k \
  && ${HOME}/.oh-my-zsh/custom/themes/powerlevel10k/gitstatus/install -f \
  && sed -i 's/ZSH="\/home\/jovyan\/.oh-my-zsh"/ZSH="$HOME\/.oh-my-zsh"/g' ${HOME}/.zshrc \
  && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ${HOME}/.zshrc \
  ## Create the user's modular bin dir
  && . /tmp/magicenv \
  && mkdir -p ${BIN_DIR} \
  ## Append the user's modular bin dir to PATH
  && . /tmp/magicenv.mod \
  && echo "\n# Append the user's modular bin dir to PATH\nif [[ \"\$PATH\" != *\"${BIN_DIR}\"* ]] ; then\n    PATH=\"\$PATH:${BIN_DIR}\"\nfi" | tee -a ${HOME}/.bashrc ${HOME}/.zshrc \
  ## Clean up
  && rm -rf /tmp/magicenv \
    /tmp/magicenv.mod \
  ## Customise the bash/zsh run commands
  && echo "\n# set PATH so it includes user's private bin if it exists\nif [ -d \"\$HOME/bin\" ] && [[ \"\$PATH\" != *\"\$HOME/bin\"* ]] ; then\n    PATH=\"\$HOME/bin:\$PATH\"\nfi" | tee -a ${HOME}/.bashrc ${HOME}/.zshrc \
  && echo "\n# set PATH so it includes user's private bin if it exists\nif [ -d \"\$HOME/.local/bin\" ] && [[ \"\$PATH\" != *\"\$HOME/.local/bin\"* ]] ; then\n    PATH=\"\$HOME/.local/bin:\$PATH\"\nfi" | tee -a ${HOME}/.bashrc ${HOME}/.zshrc \
  && echo "\n# Update last-activity timestamps while in screen/tmux session\nif [ ! -z \"\$TMUX\" -o ! -z \"\$STY\" ] ; then\n    busy &\nfi" >> ${HOME}/.bashrc \
  && echo "\n# Update last-activity timestamps while in screen/tmux session\nif [ ! -z \"\$TMUX\" -o ! -z \"\$STY\" ] ; then\n    setopt nocheckjobs\n    busy &\nfi" >> ${HOME}/.zshrc \
  && echo "\n# To customize prompt, run \`p10k configure\` or edit ~/.p10k.zsh." >> ${HOME}/.zshrc \
  && echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> ${HOME}/.zshrc \
  ## Create user's private bin
  && mkdir -p ${HOME}/.local/bin \
  ## Record population timestamp
  && date -uIseconds > ${HOME}/.populated \
  ## Create backup of home directory
  && cp -a ${HOME}/. /var/backups/skel

## Copy files as late as possible to avoid cache busting
COPY --from=files /files /
COPY --from=files /files/var/backups/skel ${HOME}

ARG JUPYTER_PORT=8888
ENV JUPYTER_PORT=${JUPYTER_PORT}

EXPOSE $JUPYTER_PORT

## Configure container startup
ENTRYPOINT ["tini", "-g", "--", "start.sh"]
CMD ["start-notebook.sh"]

ARG BUILD_START

ENV BUILD_DATE=${BUILD_START}

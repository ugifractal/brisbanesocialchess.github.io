FROM ubuntu:24.04

ENV GO_VERSION=1.24.5
ENV NODE_VERSION=22.18.0
ENV PYENV_ROOT="/root/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:${PATH}"
ENV NVM_DIR=/usr/local/nvm
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends \
    curl \
    git \
    bash \
    build-essential \
    ca-certificates \
    tar \
    xz-utils \
    zlib1g-dev \
    libssl-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    liblzma-dev \
    tk-dev \
    libffi-dev \
    libgdbm-dev \
    libnss3-dev \
    uuid-dev \
    libstdc++6 && \
    rm -rf /var/lib/apt/lists/*

RUN curl -LO https://mirrors.aliyun.com/golang/go${GO_VERSION}.linux-arm64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-arm64.tar.gz && \
    rm go${GO_VERSION}.linux-arm64.tar.gz

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y \
    && . "$HOME/.cargo/env" \
    && rustup install stable \
    && rustup default stable

ENV PATH="/root/.cargo/bin:${PATH}"
RUN cargo install oxipng --locked

ENV PATH="/usr/local/go/bin:${PATH}"

RUN git clone https://github.com/pyenv/pyenv.git /root/.pyenv

RUN pyenv install 3.11 && pyenv local 3.11 && pip install pre-commit pylint
RUN pyenv install 3.12 && pyenv local 3.12 && pip install pre-commit pylint
RUN pyenv install 3.13 && pyenv local 3.13 && pip install pre-commit pylint



RUN mkdir $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash && \
    . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

RUN go version && pip --version && . $NVM_DIR/nvm.sh && node -v && npm -v

WORKDIR /app
COPY . .

RUN . $NVM_DIR/nvm.sh && \
    npm install && \
    npm run tailwindcss:build && \
    npm run build

CMD ["/bin/bash", "-c", ". $NVM_DIR/nvm.sh && pyenv local 3.13 && pre-commit run --all-files"]

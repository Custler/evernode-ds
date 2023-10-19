ARG RUST_VERSION=1.70.0
ARG UBUNTU_VERSION=22.04

# Build stage
FROM ubuntu:${UBUNTU_VERSION} as build

ARG RUST_VERSION

ENV TZ=Europe/Moscow
ENV PATH="/root/.cargo/bin:${PATH}"
ENV ZSTD_LIB_DIR=/usr/lib/x86_64-linux-gnu

COPY ever-node /tonlabs/ever-node/
COPY ever-node-tools /tonlabs/ton-labs-node-tools/

# Install dependencies and build
RUN apt-get update && \
    apt-get install -y \
    apt-utils \
    curl \
    wget \
    gnupg2 \
    gpg \
    tar \
    cmake \
    build-essential \
    pkg-config \
    libssl-dev \
    libtool \
    m4 \
    automake \
    clang \
    git \
    libzstd-dev \
    libgoogle-perftools-dev  && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain ${RUST_VERSION} -y

# rdkafka from confluent's repo
# curl https://packages.confluent.io/deb/5.5/archive.key | apt-key add;
# wget -qO - https://packages.confluent.io/deb/7.5/archive.key | sudo apt-key add -
RUN wget -qO - https://packages.confluent.io/deb/7.5/archive.key | sudo apt-key add -; \
    echo "deb [arch=amd64] https://packages.confluent.io/deb/7.5 stable main" >> /etc/apt/sources.list;\
    apt-get update;\
    apt-get install -y librdkafka-dev;

WORKDIR /tonlabs/ever-node
RUN cargo update && cargo clean && RUSTFLAGS="-C target-cpu=native" cargo build --release --features "external_db,statsd"
WORKDIR /tonlabs/ton-labs-node-tools
RUN cargo update && cargo clean && RUSTFLAGS="-C target-cpu=native" cargo build --release

# Another build stage
FROM ubuntu:${UBUNTU_VERSION} as build2

ARG RUST_VERSION

ENV TZ=Europe/Moscow
ENV ZSTD_LIB_DIR=/usr/lib/x86_64-linux-gnu

# Install remaining dependencies
RUN apt-get update && \
    apt-get install -y \
    apt-utils \
    curl \
    wget \
    gnupg2 \
    librdkafka1 \
    build-essential \
    cmake \
    cron \
    git \
    gdb \
    gpg \
    jq \
    mc \
    tar \
    vim \
    tcpdump \
    netcat \
    python3 \
    python3-pip \
    wget \
    libzstd-dev \
    libgoogle-perftools-dev && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain ${RUST_VERSION} -y

COPY --from=build /tonlabs/ever-node/target/release/ton_node /ever-node/
COPY --from=build /tonlabs/ton-labs-node-tools/target/release/console /ever-node/tools/
COPY --from=build /tonlabs/ton-labs-node-tools/target/release/keygen /ever-node/tools/

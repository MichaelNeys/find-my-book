# Development image for the Rust services (`backend` and `wasm` in compose.yaml).
# Source code is bind-mounted at /app; nothing is copied in.
FROM rust:1.100-trixie

RUN rustup component add rustfmt clippy \
 && rustup target add wasm32-unknown-unknown \
 && cargo install --locked cargo-watch wasm-pack \
 && rm -rf /usr/local/cargo/registry

# Run as the host user, so files written into the bind mount (e.g. the wasm
# package in frontend/src/lib/wasm) are not owned by root. Every directory a
# named volume is mounted on must exist here and belong to that user, because
# Docker copies the ownership into the volume when it is first created.
ARG UID=1000
ARG GID=1000
RUN groupadd --gid "$GID" dev \
 && useradd --create-home --uid "$UID" --gid "$GID" dev \
 && mkdir -p /target /home/dev/.cache /usr/local/cargo/registry \
 && chown -R dev:dev /usr/local/cargo /target /home/dev/.cache

USER dev
WORKDIR /app
# Build output lives outside the bind mount, in a named volume.
ENV CARGO_TARGET_DIR=/target

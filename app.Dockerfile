# syntax=docker/dockerfile:1

ARG REPO_NAME
ARG APP_NAME
ARG TRUNK_HTML=
ARG DIST_DIR=/src/dist/web
ARG USE_XTASK=false
ARG EXTRA_STATIC=

# ── Stage 1: build ────────────────────────────────────────────────────────────
FROM rust:1-slim-bookworm AS builder

ARG REPO_NAME
ARG APP_NAME
ARG TRUNK_HTML
ARG DIST_DIR
ARG USE_XTASK
ARG EXTRA_STATIC

RUN apt-get update && apt-get install -y --no-install-recommends \
        git ca-certificates pkg-config curl \
    && rm -rf /var/lib/apt/lists/*

# binaryen 119 — apt ships v108 which breaks wasm externref/reference-types
RUN curl -fsSL "https://github.com/WebAssembly/binaryen/releases/download/version_119/binaryen-version_119-x86_64-linux.tar.gz" \
    | tar -xz --strip-components=2 -C /usr/local/bin "binaryen-version_119/bin/wasm-opt" \
    && wasm-opt --version

RUN rustup target add wasm32-unknown-unknown

# Install trunk (used by most apps)
RUN --mount=type=cache,target=/root/.cargo/registry \
    --mount=type=cache,target=/root/.cargo/git \
    cargo install trunk --locked

# Install wasm-bindgen-cli (used by xtask apps — lightcraft, effectcraft)
# Version must match exactly what the repo expects
RUN --mount=type=cache,target=/root/.cargo/registry \
    --mount=type=cache,target=/root/.cargo/git \
    cargo install wasm-bindgen-cli --version 0.2.129 --locked

RUN git clone --depth 1 https://github.com/storytold/${REPO_NAME} /src

WORKDIR /src/apps/${APP_NAME}

# Build — either cargo xtask web (lightcraft, effectcraft) or trunk (everyone else)
    RUN --mount=type=cache,target=/root/.cargo/registry \
        --mount=type=cache,target=/root/.cargo/git \
        if [ "$USE_XTASK" = "true" ]; then \
            cd /src && cargo xtask web; \
        else \
            trunk build ${TRUNK_HTML} --release; \
        fi

# Copy any extra static files into dist (e.g. lightcraft's worker.js)
RUN if [ -n "$EXTRA_STATIC" ]; then \
        cp /src/apps/${APP_NAME}/${EXTRA_STATIC} ${DIST_DIR}/; \
    fi

# ── Stage 2: serve ────────────────────────────────────────────────────────────
FROM busybox:stable

ARG DIST_DIR

COPY --from=builder ${DIST_DIR} /srv

# MIME types — busybox doesn't know application/wasm without this
RUN echo "application/wasm      wasm"    >  /etc/mime.types \
 && echo "text/javascript        js mjs" >> /etc/mime.types \
 && echo "text/html              html"   >> /etc/mime.types \
 && echo "text/css               css"    >> /etc/mime.types

WORKDIR /srv
EXPOSE 80
CMD ["busybox", "httpd", "-f", "-v", "-p", "80", "-h", "/srv"]
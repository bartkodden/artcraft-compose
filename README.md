# ArtCraft Self-Hosted Stack

A Docker Compose stack that builds and self-hosts all seven
[ArtCraft Crafting Apps](https://getartcraft.com/apps) as web apps, served
behind your own Caddy reverse proxy.

> ⚠️ **Important disclaimer — please read**
>
> This repository contains **no original application code whatsoever**.
> It is purely a deployment wrapper — a `Dockerfile`, a `docker-compose.yml`,
> a Caddy config snippet, and a launcher page — that builds and serves the
> Crafting Apps from their original upstream sources.
>
> All application code, assets, designs, and intellectual property belong
> entirely to the [ArtCraft / Storytold team](https://github.com/storytold)
> and their contributors. This repo does not modify, fork, redistribute or
> claim any part of their work. It simply automates what their own
> documentation describes: building and self-hosting the WASM web builds.
>
> If you enjoy these apps, please ⭐ the original repositories and
> join the [ArtCraft Discord](https://discord.gg/artcraft).

---

## What this is

A single `docker compose build && docker compose up -d` workflow that:

1. Clones each upstream repo from GitHub at build time
2. Compiles the Rust/WASM web app using each repo's own build tooling
3. Serves the resulting static files from a minimal busybox container
4. Exposes a simple launcher page linking to all the apps

Everything runs in your browser after the initial page load. No data is
sent to any server — these are pure client-side WASM applications.

---

## Original repositories

All credit goes to the original authors:

| App | Repository |
|-----|-----------|
| PhotoCraft | [storytold/photocraft](https://github.com/storytold/photocraft) |
| VectorCraft | [storytold/vectorcraft](https://github.com/storytold/vectorcraft) |
| FilmCraft | [storytold/filmcraft](https://github.com/storytold/filmcraft) |
| LightCraft | [storytold/lightcraft](https://github.com/storytold/lightcraft) |
| PrintCraft | [storytold/printcraft](https://github.com/storytold/printcraft) |
| EffectCraft | [storytold/effectcraft](https://github.com/storytold/effectcraft) |
| DesignCraft | [storytold/designcraft](https://github.com/storytold/designcraft) |

---

## Requirements

- Docker with BuildKit enabled
- Caddy (or any reverse proxy) for HTTPS and header handling
- 30–60 GB of disk during build (build cache), ~200 MB when running
- 4–8 GB RAM per app during build — **build one at a time**
- Each app takes 30–60 min to build on first run

---

## File structure

```
storytold/
├── app.Dockerfile          # Parameterised multi-stage build for all apps
├── compose.yaml            # Docker Compose stack definition
├── launcher/
│   ├── Dockerfile          # Tiny busybox static server
│   └── index.html          # Launcher page linking to all apps
└── README.md               # This file
```

---

## Setup

### 1 — Clone this repo

```bash
git clone https://github.com/bartkodden/artcraft-compose.git
cd artcraft-compose
```

### 2 — Build each app one at a time

```bash
docker compose build --no-cache photocraft
docker compose build --no-cache vectorcraft
docker compose build --no-cache lightcraft
docker compose build --no-cache printcraft
docker compose build --no-cache effectcraft
docker compose build --no-cache designcraft
docker compose build --no-cache filmcraft
docker compose build launcher
```

### 3 — Add to your Caddy config

Copy `storytold.caddyfile` into your Caddy config directory and add
this line to your main `Caddyfile`:

```caddyfile
import /etc/caddy/storytold.caddyfile
```

Replace `{$domain}` with your domain or set it as an environment variable.

### 4 — Start the stack

```bash
docker compose up -d
```

---

## Caddy config

The required COOP/COEP isolation headers for `SharedArrayBuffer` (needed
by WASM threads) are set in `storytold.caddyfile`. Copy it to your Caddy
config directory alongside your main `Caddyfile`.

---

## Updating an app

To update a single app to the latest upstream commit:

```bash
docker compose build --no-cache photocraft
docker compose up -d photocraft
```

---

## License

The deployment files in this repository (Dockerfiles, compose config,
launcher HTML) are released under [MIT](LICENSE).

The applications themselves are licensed by their respective authors —
see each upstream repository for details. All are dual-licensed MIT /
Apache-2.0.

---

## Credits

- [ArtCraft team and contributors](https://github.com/storytold) — for building all seven apps
- [getartcraft.com](https://getartcraft.com) — project home
- [discord.gg/artcraft](https://discord.gg/artcraft) — community Discord


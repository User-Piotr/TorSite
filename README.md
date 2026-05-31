# TorSite

[![Build](https://github.com/User-Piotr/TorSite/actions/workflows/deploy.yml/badge.svg)](https://github.com/User-Piotr/TorSite/actions/workflows/deploy.yml)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

Self-hosted Tor hidden service — OnionBalance, Gluetun (WireGuard), nginx + Hugo static site, Uptime Kuma monitoring. Hardened Docker stack with Vanguard.

![Logo](images/logo.jpg)

## Architecture

```
                         ┌───────────────┐
                         │  Tor Network  │
                         └───────┬───────┘
                                 │
                         ┌───────▼───────┐
                         │  obfs4 Bridge │  ← HIGH-THREAT mode (optional)
                         └───────┬───────┘
                                 │
                         ┌───────▼───────┐
                         │    gluetun    │
                         │  (WireGuard)  │
                         └──┬────┬────┬──┘
                            │    │    │
               ┌────────────┘    │    └───────────┐
               │                 │                │
       ┌───────▼────────┐ ┌──────▼──────┐ ┌───────▼────────┐
       │  tor-frontend  │ │ tor-backend │ │  tor-backend   │
       │ (OnionBalance) │ │      1      │ │       2        │
       └────────────────┘ └──────┬──────┘ └────────┬───────┘
                                 └────────┬────────┘
                                          │ Unix socket
                                   ┌──────▼──────┐
                                   │    nginx    │
                                   │ (Hugo site) │
                                   └─────────────┘
```

## Prerequisites

- Docker
- Docker Compose v2
- Python 3
- Make

## Quick Start

**1. Generate .onion domain**
```bash
docker run --volume ./domain:/root/mkp224o \
  ghcr.io/vansergen/mkp224o -B -S 5 -t 5 -n 1 <prefix>
```

**2. Configure**
```bash
cp .env.example .env   # edit PROJECT_NAME, REPLICAS, ONION_ADDRESS, Mullvad keys
make install           # set up Python venv
```

**3. Start**
```bash
sudo ./startup.sh
```

## Profiles

| Profile | Services | Command |
|---|---|---|
| `app` | gluetun, tor-backend, tor-frontend, nginx | `docker compose --profile app up -d` |
| `monitoring` | tor-proxy, kuma, docker-socket-proxy | `docker compose --profile monitoring up -d` |
| `app` + `monitoring` | full stack | `docker compose --profile app --profile monitoring up -d` |

## Configuration

All config is generated via `config_generator.py` from Jinja2 templates:

```bash
python3 scripts/config_generator.py all \
  --master_onion_address http://your.onion \
  --domains backend1.onion backend2.onion \
  --log_level notice \
  --log_location /var/log/tor/onionbalance.log \
  --key_path /hs_keys/<onion-dir>/hs_ed25519_secret_key
```

## HIGH-THREAT Mode

To enable VPN + obfs4 bridges on top of the default VPN-only setup,
uncomment the `HIGH-THREAT` block in `conf/torrc-backend` and `conf/torrc-frontend`, then redeploy:

```bash
# uncomment HIGH-THREAT block in conf/torrc-backend and conf/torrc-frontend
sudo ./startup.sh
```

Flow: `Real IP → Mullvad WireGuard → obfs4 Bridge → Tor Guard → Tor Network`

## Tools

**OnionScan**
```bash
./onionscan/startup.sh <domain>
```

**Nyx (Tor monitor)**
```bash
./nyx.sh
```

## Security

See [SECURITY.md](SECURITY.md).

## License

Apache 2.0

# TorSite

[![Build](https://github.com/User-Piotr/TorSite/actions/workflows/deploy.yml/badge.svg)](https://github.com/User-Piotr/TorSite/actions/workflows/deploy.yml)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

Dockerized Tor hidden service with high-availability via OnionBalance, nginx reverse proxy, obfs4 bridge transport, and Uptime Kuma monitoring.

![Logo](images/logo.jpg)

## Architecture

```
                    ┌─────────────────┐
                    │  OnionBalance   │  ← tor-frontend
                    │  (HA frontend)  │
                    └────────┬────────┘
                             │
                   ┌─────────┴─────────┐
                   │                   │
            ┌──────▼─────┐      ┌──────▼─────┐
            │ tor-backend│      │ tor-backend│  ← N replicas
            └──────┬─────┘      └──────┬─────┘
                   └─────────┬─────────┘
                             │ Unix socket
                      ┌──────▼──────┐
                      │    nginx    │  ← static site (Hugo)
                      └─────────────┘
```

## Stack

| Component | Role |
|---|---|
| tor-frontend | OnionBalance HA coordinator |
| tor-backend | Hidden service + vanguards |
| nginx | Reverse proxy, Hugo static site |
| tor-proxy | SOCKS5 proxy for monitoring |
| kuma | Uptime monitoring |

**Transport:** obfs4 via lyrebird  
**Vanguards:** bandguards, rendguards, circuit close-on-attack enabled  
**CI/CD:** GitHub Actions → GHCR

## Quick Start

**1. Generate .onion domain**
```bash
docker run --volume ./domain:/root/mkp224o \
  ghcr.io/vansergen/mkp224o -B -S 5 -t 5 -n 1 <prefix>
```

**2. Configure**
```bash
cp .env.example .env   # edit PROJECT_NAME, REPLICAS, DIRECTORY
make install           # set up Python venv
```

**3. Start**
```bash
sudo ./startup.sh
```

## Profiles

| Profile | Services | Command |
|---|---|---|
| `app` | tor-backend, tor-frontend, nginx | `docker compose --profile app up -d` |
| `monitoring` | tor-proxy, kuma, socket-proxy | `docker compose --profile monitoring up -d` |
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

- `cap_drop: ALL` on all containers
- Read-only filesystems with tmpfs for mutable paths
- `no-new-privileges`, non-root users throughout
- Docker socket exposed only via read-only filtering proxy
- nginx: CSP, `Referrer-Policy: no-referrer`, `Permissions-Policy`, `X-Frame-Options: DENY`
- obfs4 bridges on all Tor nodes

## License

Apache 2.0

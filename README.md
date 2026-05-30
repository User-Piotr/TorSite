# TorSite

[![Build](https://github.com/User-Piotr/TorSite/actions/workflows/deploy.yml/badge.svg)](https://github.com/User-Piotr/TorSite/actions/workflows/deploy.yml)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

Dockerized Tor hidden service with high-availability via OnionBalance, Mullvad WireGuard VPN, nginx reverse proxy, and Uptime Kuma monitoring.

![Logo](images/logo.jpg)

## Architecture

Each Tor container connects independently through Gluetun to the Tor network.

```
                         ┌───────────────┐
                         │  Tor Network  │
                         └───────┬───────┘
                                 │
                         ┌───────▼───────┐
                         │  obfs4 /      │  ← optional: HIGH-THREAT mode
                         │  Snowflake    │
                         │  Bridge       │
                         └───────┬───────┘
                                 │
                         ┌───────▼───────┐
                         │    gluetun    │
                         │  Mullvad VPN  │
                         │  (WireGuard)  │
                         └──┬────┬────┬──┘
                            │    │    │
               ┌────────────┘    │    └────────────┐
               │                 │                 │
       ┌───────▼────────┐ ┌──────▼──────┐ ┌───────▼────────┐
       │  tor-frontend  │ │ tor-backend │ │  tor-backend   │
       │ (OnionBalance) │ │      1      │ │       2        │
       └────────────────┘ └──────┬──────┘ └───────┬────────┘
                                 └────────┬────────┘
                                          │ Unix socket
                                   ┌──────▼──────┐
                                   │    nginx    │  ← static site (Hugo)
                                   └─────────────┘
```

## Stack

| Component | Role |
|---|---|
| tor-frontend | OnionBalance HA coordinator + vanguards |
| tor-backend | Hidden service + vanguards, N replicas |
| nginx | Reverse proxy, Hugo static site |
| gluetun | Mullvad WireGuard VPN — HTTP CONNECT proxy for all Tor containers |
| tor-proxy | SOCKS5 proxy for monitoring (direct Tor, no VPN) |
| kuma | Uptime monitoring |
| docker-socket-proxy | Read-only Docker socket filter for kuma |

**VPN:** Mullvad WireGuard via gluetun — all outbound Tor traffic tunneled  
**Transport:** obfs4 (lyrebird) available — disabled by default, enable via HIGH-THREAT block in torrc  
**Vanguards:** bandguards, rendguards, circuit close-on-attack enabled  
**Supervisord:** manages Tor + onionbalance + vanguards — auto-restarts on crash  
**CI/CD:** GitHub Actions → GHCR

## Prerequisites

- Docker
- Docker Compose v2
- Python 3 + pip
- Make
- Root access (HS key permissions)
- Mullvad account (WireGuard keys)

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

To enable VPN + obfs4 + Snowflake bridges on top of the default VPN-only setup,
uncomment the `HIGH-THREAT` block in `conf/torrc-backend` and `conf/torrc-frontend`, then rebuild:

```bash
# uncomment HIGH-THREAT block in conf/torrc-backend and conf/torrc-frontend
docker compose build tor-backend tor-frontend
sudo ./startup.sh
```

Flow: `Real IP → Mullvad WireGuard → obfs4/Snowflake Bridge → Tor Guard → Tor Network`

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

- `cap_drop: ALL` on all containers, read-only filesystems, `no-new-privileges`
- Non-root users throughout (`tor`, `nginx`)
- All Tor traffic tunneled through Mullvad WireGuard — server IP never reaches Tor nodes
- tmpfs for all mutable paths (`/var/lib/tor`, `/var/log/tor`, `/tmp`) with `noexec,nosuid,nodev`
- Unix socket between nginx and Tor — no network exposure for app traffic
- nginx: `network_mode: none` — fully isolated, no internet access
- Docker socket exposed only via read-only filtering proxy (CONTAINERS=1, POST=0)
- nginx headers: CSP, `Referrer-Policy: no-referrer`, `Permissions-Policy`, `X-Frame-Options: DENY`
- Vanguards: bandguards + rendguards + circuit close on suspected attack
- ControlPort: Unix socket only, `CookieAuthentication 1`, cookie on tmpfs
- CI: HS keys scrubbed from runner on `if: always()`

## License

Apache 2.0

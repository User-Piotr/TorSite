# Security

## Container Hardening

- `cap_drop: ALL` on all containers, read-only rootfs where possible, `no-new-privileges`, pids limits per-service
- Non-root users throughout (`tor`, `nginx`), tmpfs for all mutable paths (`noexec,nosuid,nodev`)

## Network

- All Tor traffic tunneled via Gluetun WireGuard, real IP never reaches Tor nodes
- nginx: `network_mode: none`, Unix socket to Tor, there is no direct network exposure

## Tor

- Vanguards: bandguards + rendguards + circuit close on suspected attack
- ControlPort: Unix socket only, `CookieAuthentication 1`
- `ExitRelay 0`, `ExitPolicy reject *:*` on all torrc files

## Application

- nginx: `Server: hidden`, CSP, `X-Frame-Options: DENY`, `Referrer-Policy: no-referrer`, `Permissions-Policy`
- Docker socket: read-only proxy (`CONTAINERS=1`, `POST=0`)

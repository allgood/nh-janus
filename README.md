# Janus WebRTC to SIP Bridge (Docker)

This project builds a Docker container running **Janus Gateway** configured to:

- accept WebRTC clients over HTTP/WebSocket APIs;
- bridge media/signaling through the **Janus SIP plugin** to an upstream SIP server;
- keep runtime configuration environment-driven (no manual config edits in container).

The container is prepared with broad codec library support during Janus build, including common audio/video stacks used in WebRTC/SIP interop.

## What is included

- `Dockerfile`: builds Janus from source with SIP plugin and codec-related dependencies.
- `docker/entrypoint.sh`: generates Janus config files from environment variables at startup.
- `docker-compose.yml`: service definition with ports, healthcheck, and env loading.
- `.env.example`: full environment template.

## Quick start

1. Create your runtime env file:

```bash
cp .env.example .env
```

2. Edit `.env` and set at least:

- `SIP_PROXY`
- `SIP_REGISTRAR`
- `SIP_LOCAL_IP` (public or reachable IP for SIP side)
- `JANUS_NAT_1_1_MAPPING` (public IP when behind NAT)

3. Build and run:

```bash
docker compose up -d --build
```

4. Check health:

```bash
curl http://127.0.0.1:${JANUS_HTTP_PORT:-8088}${JANUS_HTTP_BASE_PATH:-/janus}/info
```

## Exposed ports

- `8088/tcp` Janus HTTP API (default)
- `8089/tcp` Janus HTTPS API (optional)
- `8188/tcp` Janus WebSocket API (default)
- `8989/tcp` Janus Secure WebSocket API (optional)
- `5060/udp` local SIP bind for Janus SIP plugin
- `10000-20000/udp` RTP/RTCP media range

All can be changed via `.env`.

## Environment-first configuration

`docker/entrypoint.sh` renders these files at runtime:

- `/opt/janus/etc/janus/janus.jcfg`
- `/opt/janus/etc/janus/janus.transport.http.jcfg`
- `/opt/janus/etc/janus/janus.transport.websockets.jcfg`
- `/opt/janus/etc/janus/janus.plugin.sip.jcfg`

That means your deployment workflow is:

- change `.env`
- restart container
- no hand-edited static config required

## SIP registration model

The SIP plugin supports two patterns:

- Dynamic registrations via Janus API (recommended for multi-user/browser apps)
- Single helper account in config (for quick tests), via:
  - `SIP_ACCOUNT_USERNAME`
  - `SIP_ACCOUNT_AUTHUSER`
  - `SIP_ACCOUNT_SECRET`
  - `SIP_PROXY`
  - `SIP_REGISTRAR`

## Codec support notes

The image compiles Janus with dependencies commonly required for broad codec compatibility:

- Audio: Opus, G.711 (PCMU/PCMA), G.722 and related WebRTC/SIP interoperable formats
- Video: VP8, VP9, H.264, H.265, AV1-capable library chain

Final negotiated codec set depends on:

- browser/WebRTC endpoint capabilities;
- SIP server/SBC capabilities;
- SDP offer/answer negotiation.

## Production recommendations

- Set `JANUS_NAT_1_1_MAPPING` when container is behind NAT.
- Use valid certs and enable `JANUS_HTTPS_ENABLED=true` and/or `JANUS_WSS_ENABLED=true` for internet-facing deployments.
- Restrict exposed admin interfaces (`JANUS_ADMIN_*`) unless needed.
- Keep RTP UDP range open on firewall/security group.

## JsSIP client note

For browser apps, Janus SIP bridging is typically consumed through Janus API clients (e.g., Janus JS integration). If your frontend is strict SIP-over-WebSocket only, add a SIP WS edge/proxy and route SIP signaling accordingly, while keeping Janus for WebRTC media/SIP bridging workflows.

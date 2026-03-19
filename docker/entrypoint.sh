#!/usr/bin/env bash
set -euo pipefail

JANUS_HOME="/opt/janus"
JANUS_ETC="${JANUS_HOME}/etc/janus"

mkdir -p "${JANUS_ETC}"

# General Janus
cat >"${JANUS_ETC}/janus.jcfg" <<EOF
general: {
  configs_folder = "${JANUS_ETC}"
  plugins_folder = "${JANUS_HOME}/lib/janus/plugins"
  transports_folder = "${JANUS_HOME}/lib/janus/transports"
  events_folder = "${JANUS_HOME}/lib/janus/events"
  loggers_folder = "${JANUS_HOME}/lib/janus/loggers"
  debug_level = ${JANUS_DEBUG_LEVEL:-4}
  debug_timestamps = ${JANUS_DEBUG_TIMESTAMPS:-true}
  debug_colors = ${JANUS_DEBUG_COLORS:-false}
}

nat: {
  stun_server = "${JANUS_STUN_SERVER:-stun.l.google.com}"
  stun_port = ${JANUS_STUN_PORT:-19302}
  nice_debug = ${JANUS_NICE_DEBUG:-false}
  full_trickle = ${JANUS_FULL_TRICKLE:-true}
  nat_1_1_mapping = "${JANUS_NAT_1_1_MAPPING:-}"
}

media: {
  ipv6 = ${JANUS_IPV6:-false}
  rtp_port_range = "${JANUS_RTP_PORT_RANGE:-10000-20000}"
  dtls_mtu = ${JANUS_DTLS_MTU:-1200}
}
EOF

# HTTP transport
cat >"${JANUS_ETC}/janus.transport.http.jcfg" <<EOF
general: {
  json = "compact"
  base_path = "${JANUS_HTTP_BASE_PATH:-/janus}"
  http = ${JANUS_HTTP_ENABLED:-true}
  port = ${JANUS_HTTP_PORT:-8088}
  https = ${JANUS_HTTPS_ENABLED:-false}
  secure_port = ${JANUS_HTTPS_PORT:-8089}
}

admin: {
  admin_base_path = "${JANUS_ADMIN_BASE_PATH:-/admin}"
  admin_http = ${JANUS_ADMIN_HTTP_ENABLED:-false}
  admin_port = ${JANUS_ADMIN_HTTP_PORT:-7088}
  admin_https = ${JANUS_ADMIN_HTTPS_ENABLED:-false}
  admin_secure_port = ${JANUS_ADMIN_HTTPS_PORT:-7889}
}

certificates: {
  cert_pem = "${JANUS_CERT_PEM:-/opt/janus/share/janus/certs/mycert.pem}"
  cert_key = "${JANUS_CERT_KEY:-/opt/janus/share/janus/certs/mycert.key}"
}
EOF

# WebSockets transport
cat >"${JANUS_ETC}/janus.transport.websockets.jcfg" <<EOF
general: {
  json = "compact"
  events = ${JANUS_WS_EVENTS:-false}
}

admin: {
  admin_ws = ${JANUS_ADMIN_WS_ENABLED:-false}
  admin_ws_port = ${JANUS_ADMIN_WS_PORT:-7188}
  admin_wss = ${JANUS_ADMIN_WSS_ENABLED:-false}
  admin_wss_port = ${JANUS_ADMIN_WSS_PORT:-7989}
}

certificates: {
  cert_pem = "${JANUS_CERT_PEM:-/opt/janus/share/janus/certs/mycert.pem}"
  cert_key = "${JANUS_CERT_KEY:-/opt/janus/share/janus/certs/mycert.key}"
}

webserver: {
  ws = ${JANUS_WS_ENABLED:-true}
  ws_port = ${JANUS_WS_PORT:-8188}
  wss = ${JANUS_WSS_ENABLED:-false}
  wss_port = ${JANUS_WSS_PORT:-8989}
}
EOF

# SIP plugin
cat >"${JANUS_ETC}/janus.plugin.sip.jcfg" <<EOF
general: {
  local_ip = "${SIP_LOCAL_IP:-127.0.0.1}"
  sip_port = ${SIP_LOCAL_PORT:-5060}
  behind_nat = ${SIP_BEHIND_NAT:-false}
  user_agent = "${SIP_USER_AGENT:-Janus WebRTC SIP Bridge}"
  register_ttl = ${SIP_REGISTER_TTL:-3600}
  keepalive_interval = ${SIP_KEEPALIVE_INTERVAL:-120}
}

# Optional helper account for quick tests.
# In production, many deployments register users dynamically via Janus API.
account: {
  username = "${SIP_ACCOUNT_USERNAME:-}"
  authuser = "${SIP_ACCOUNT_AUTHUSER:-}"
  secret = "${SIP_ACCOUNT_SECRET:-}"
  proxy = "${SIP_PROXY:-}"
  registrar = "${SIP_REGISTRAR:-}"
  display_name = "${SIP_ACCOUNT_DISPLAY_NAME:-}"
}
EOF

exec "${JANUS_HOME}/bin/janus" -F "${JANUS_ETC}" ${JANUS_EXTRA_ARGS:-}

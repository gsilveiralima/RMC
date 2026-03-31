#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-}"
if [[ -z "$DOMAIN" ]]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

TIMESTAMP="$(date -u +%Y%m%d_%H%M%S)"
WORKDIR="output/recon_${DOMAIN}_${TIMESTAMP}"
mkdir -p "$WORKDIR"

log() { printf '[%s] %s\n' "$(date -u +%H:%M:%S)" "$*"; }

log "Starting recon for ${DOMAIN}"

echo "Domain: ${DOMAIN}" > "$WORKDIR/summary.txt"
echo "Timestamp (UTC): ${TIMESTAMP}" >> "$WORKDIR/summary.txt"

{
  echo "===== whois ====="
  whois "$DOMAIN"
} > "$WORKDIR/whois.txt" 2>&1 || true

{
  echo "===== dig A ====="
  dig +short A "$DOMAIN"
  echo
  echo "===== dig AAAA ====="
  dig +short AAAA "$DOMAIN"
  echo
  echo "===== dig NS ====="
  dig +short NS "$DOMAIN"
  echo
  echo "===== dig MX ====="
  dig +short MX "$DOMAIN"
} > "$WORKDIR/dns.txt" 2>&1 || true

{
  echo "===== curl headers ====="
  curl -k -I --max-time 20 "https://${DOMAIN}" || true
  echo
  curl -I --max-time 20 "http://${DOMAIN}" || true
} > "$WORKDIR/http_headers.txt" 2>&1

{
  echo "===== openssl s_client ====="
  echo | openssl s_client -connect "${DOMAIN}:443" -servername "$DOMAIN" 2>/dev/null
} > "$WORKDIR/tls.txt" || true

{
  echo "===== nmap top ports ====="
  nmap -Pn --top-ports 100 "$DOMAIN"
} > "$WORKDIR/nmap_top100.txt" 2>&1 || true

TAR_PATH="output/recon_${DOMAIN}_${TIMESTAMP}.tar.gz"
tar -czf "$TAR_PATH" -C output "recon_${DOMAIN}_${TIMESTAMP}"

log "Recon complete: ${TAR_PATH}"

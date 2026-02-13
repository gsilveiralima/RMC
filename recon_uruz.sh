#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-}"
if [[ -z "$DOMAIN" ]]; then
  echo "Usage: $0 <domain>" >&2
  exit 1
fi

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
OUTDIR="output/${DOMAIN}_${TIMESTAMP}"
mkdir -p "$OUTDIR"

log() {
  printf '[%s] %s\n' "$(date +%H:%M:%S)" "$1"
}

safe_run() {
  local title="$1"
  local outfile="$2"
  shift 2

  {
    echo "### ${title}"
    echo
    "$@"
  } >"$outfile" 2>&1 || {
    {
      echo "### ${title}"
      echo
      echo "Command failed: $*"
    } >"$outfile"
  }
}

log "Starting recon for ${DOMAIN}"

safe_run "WHOIS" "${OUTDIR}/whois.txt" whois "$DOMAIN"
safe_run "DNS A" "${OUTDIR}/dns_a.txt" dig +short "$DOMAIN" A
safe_run "DNS NS" "${OUTDIR}/dns_ns.txt" dig +short "$DOMAIN" NS
safe_run "DNS MX" "${OUTDIR}/dns_mx.txt" dig +short "$DOMAIN" MX
safe_run "DNS TXT" "${OUTDIR}/dns_txt.txt" dig +short "$DOMAIN" TXT
safe_run "TLS certificate" "${OUTDIR}/tls_cert.txt" bash -c "echo | openssl s_client -servername '$DOMAIN' -connect '$DOMAIN:443' 2>/dev/null | openssl x509 -noout -issuer -subject -dates"
safe_run "HTTP headers" "${OUTDIR}/http_headers.txt" curl -sSI "https://${DOMAIN}"
safe_run "Nmap top ports" "${OUTDIR}/nmap_top_1000.txt" nmap -Pn --top-ports 1000 "$DOMAIN"

TARBALL="output/recon_${DOMAIN}_${TIMESTAMP}.tar.gz"
tar -czf "$TARBALL" -C output "${DOMAIN}_${TIMESTAMP}"

log "Recon finished"
log "Results: ${TARBALL}"

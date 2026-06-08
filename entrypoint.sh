#!/bin/sh
# lokyy-runner — baut die Forgejo-Runner-Konfiguration aus drei Umgebungs-
# variablen und startet den Daemon. Liegt IM Repo (nicht im Terminal getippt),
# darum keine Paste-/Heredoc-Fallen. Labels gehören laut Forgejo-Doku in die
# config.yml unter runner.labels — nicht an --label.
set -eu

: "${FORGEJO_URL:?FORGEJO_URL fehlt (z. B. https://forgejo.example.de/)}"
: "${RUNNER_UUID:?RUNNER_UUID fehlt (aus Forgejo: Actions -> Runners -> Neuen Runner erstellen)}"
: "${RUNNER_TOKEN:?RUNNER_TOKEN fehlt (derselbe Dialog)}"

# Kommagetrennte Labels, überschreibbar; Default deckt docker + GitHub-kompatibles Ubuntu ab.
LABELS="${RUNNER_LABELS:-docker:docker://node:20-bookworm,ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-22.04}"

{
  echo "log:"
  echo "  level: info"
  echo "runner:"
  echo "  labels:"
  OLDIFS="$IFS"; IFS=','
  for l in $LABELS; do echo "    - $l"; done
  IFS="$OLDIFS"
  echo "server:"
  echo "  connections:"
  echo "    forgejo:"
  echo "      url: ${FORGEJO_URL}"
  echo "      uuid: ${RUNNER_UUID}"
  echo "      token: ${RUNNER_TOKEN}"
} > /tmp/config.yml

echo "lokyy-runner: config.yml geschrieben, starte Daemon gegen ${FORGEJO_URL}"
exec forgejo-runner daemon --config /tmp/config.yml

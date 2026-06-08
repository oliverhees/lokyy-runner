# Backt das entrypoint-Skript fest ins Image — kein Bind-Mount nötig, läuft
# bei jedem Coolify-Git-Deploy identisch.
FROM data.forgejo.org/forgejo/runner:12.10.2
USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]

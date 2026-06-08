# lokyy-runner

Ein **Forgejo-Actions-Runner zum Deployen** — gedacht für Coolify, ohne eine
einzige Terminal-Bastelei. Der Kursteilnehmer wählt dieses Repo, setzt drei
Werte, klickt Deploy. Fertig.

## Warum es dieses Repo gibt

Den Runner von Hand einzurichten (Token in Dateien schreiben, Skripte mounten,
config.yml zusammenbauen) ist nichts, was ein Kursteilnehmer reproduzieren
kann. Deshalb steckt die ganze Logik **versioniert im Repo**: das
`entrypoint.sh` baut die `config.yml` aus drei Umgebungsvariablen, der Daemon
liest sie. Labels gehören laut Forgejo-Doku in `runner.labels` der config.yml,
nicht an `--label` — genau das macht das Skript.

## So deployt ein Teilnehmer (Coolify)

1. **Runner in Forgejo anlegen:** *Einstellungen → Actions → Runners →
   „Neuen Runner erstellen"*. Forgejo zeigt **UUID** und **Token** (Token nur
   einmal sichtbar — kopieren).
2. **In Coolify:** *New Resource → Docker Compose → From Git Repository* → die
   Adresse dieses Repos eintragen.
3. **Environment Variables** in Coolify setzen:
   - `FORGEJO_URL` — die Adresse der Forgejo-Instanz, mit Slash am Ende
     (z. B. `https://forgejo.deinedomain.de/`). Muss exakt der ROOT_URL
     entsprechen.
   - `RUNNER_UUID` — die UUID aus Schritt 1
   - `RUNNER_TOKEN` — der Token aus Schritt 1
   - `RUNNER_LABELS` *(optional)* — kommagetrennt; Default deckt `docker` und
     `ubuntu-latest` ab.
4. **Deploy.** Nach ein paar Sekunden steht der Runner in Forgejo unter
   *Actions → Runners* auf **online/idle**, mit den Labels.

## Was drin ist

- `docker-compose.yml` — zwei Container: `docker-in-docker` (führt die Jobs aus)
  und `runner` (der Forgejo-Runner). Beide mit Healthcheck, damit Coolify grün
  statt „degraded" zeigt.
- `entrypoint.sh` — schreibt `config.yml` aus den Env-Variablen und startet den
  Daemon (`forgejo-runner daemon --config`).
- `.env.example` — Vorlage für die drei Werte (nie committen).

## Hart erkaufte Stolperfallen (Stand 2026-06)

- **Forgejo-Version:** Mit Forgejo `:8` (alt) bricht der moderne Runner. Forgejo
  muss aktuell sein (LTS `:15`).
- **Image-Pfad:** `data.forgejo.org/forgejo/runner` (nicht `code.forgejo.org`).
- **Registrierung (Forgejo 15):** UUID + Token vorab im UI, kein interaktives
  `register` mehr.
- **Labels:** nur über `config.yml` (`runner.labels`), nicht über `--label`.
- **BusyBox:** das Runner-Image ist BusyBox-basiert — `sleep infinity` gibt es
  dort nicht.
- **dind:** braucht `privileged: true`, sonst startet `dockerd` nicht.

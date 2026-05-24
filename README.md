# Band Director

Hermes Agent deployment for financial market research via Discord.

## Prerequisites

- Docker 20.10+ with Compose v2 (`docker compose`)
- Git
- SSH key pair (for VPS deployment)

## Quick Start

### 1. Clone and configure

```bash
git clone https://github.com/larrylegendrr/hermes-fleet.git
cd hermes-fleet
cp .env.example .env
# Edit .env with your API keys
```

### 2. Create required directories

```bash
mkdir -p config skills
```

### 3. Local development

```bash
# This starts Hermes + self-hosted Firecrawl (Redis, Postgres, Playwright)
docker compose up -d
docker compose logs -f hermes
```

### 4. VPS deployment

```bash
# One-time server setup
curl -fsSL https://raw.githubusercontent.com/larrylegendrr/hermes-fleet/main/scripts/install.sh | sudo bash

# Clone repo on VPS
cd /opt/hermes-fleet
git clone https://github.com/larrylegendrr/hermes-fleet.git .
cp .env.example .env
# Edit .env with production secrets (no Firecrawl API key needed - it's self-hosted!)

# Start services
docker compose up -d
```

## Configuration

Create a `.env` file with the following variables:

| Variable | Required | Description |
|----------|----------|-------------|
| `KIMI_API_KEY` | Yes | [Moonshot AI](https://platform.moonshot.cn/) API key |
| `DISCORD_TOKEN` | Yes | [Discord Developer Portal](https://discord.com/developers/applications) bot token |
| `ENVIRONMENT` | No | `production` or `development` (default: production) |
| `LOG_LEVEL` | No | `DEBUG`, `INFO`, `WARNING`, `ERROR` (default: INFO) |

**Note:** Firecrawl is now self-hosted - no API key needed! It runs as part of the Docker Compose stack.

### For CI/CD Deployment

| Variable | Required | Description |
|----------|----------|-------------|
| `VPS_HOST` | Yes | VPS IP address or hostname |
| `VPS_USER` | Yes | SSH username |
| `VPS_PASSWORD` | Yes | SSH password |

### GitHub Secrets Setup

For automated deployment via GitHub Actions, add these secrets to your repo:

1. Go to **Settings → Secrets and variables → Actions**
2. Add the following repository secrets:
   - `VPS_HOST` - Your VPS IP (e.g., `204.12.253.215`)
   - `VPS_USER` - SSH username (e.g., `administrator`)
   - `VPS_PASSWORD` - SSH password
   - `KIMI_API_KEY` - Your Moonshot AI API key
   - `DISCORD_TOKEN` - Your Discord bot token

Push to `main` branch triggers automatic deployment.

## Skills

- **market-research** - Ticker search, price lookups, news (see `skills/market-research/`)
- **technical-analysis** - RSI, SMA, trend analysis (see `skills/technical-analysis/`)
- **web-scraping** - Firecrawl and Playwright integration (see `skills/web-scraping/`)

## Discord Commands

In Discord, mention the bot:

```
@Band Director What's the latest on AAPL?
@Band Director Research Bitcoin technicals
@Band Director Set up a daily SPY summary at 9am
```

## Backup (VPS)

```bash
# Run on VPS
/opt/hermes-fleet/scripts/backup.sh
```

Backups are stored in `/opt/backups/hermes/` with 7-day retention.

## Documentation

- [Design Spec](docs/superpowers/specs/2025-05-24-hermes-fleet-design.md)
- [Implementation Plan](docs/superpowers/plans/2025-05-24-band-director-implementation.md)

## License

MIT

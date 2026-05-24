# Band Director

Hermes Agent deployment for financial market research via Discord.

## Quick Start

### 1. Clone and configure

```bash
git clone <your-repo> hermes-fleet
cd hermes-fleet
cp .env.example .env
# Edit .env with your keys
```

### 2. Local development

```bash
docker compose up -d
docker compose logs -f hermes
```

### 3. VPS deployment

```bash
# One-time server setup
curl -fsSL https://raw.githubusercontent.com/your-org/hermes-fleet/main/scripts/install.sh | sudo bash

# Then deploy via GitHub Actions (push to main)
```

## Configuration

| Variable | Description |
|----------|-------------|
| `KIMI_API_KEY` | Moonshot AI API key |
| `DISCORD_TOKEN` | Discord bot token |
| `VPS_HOST` | Deployment target IP/hostname |
| `VPS_USER` | SSH username |
| `VPS_SSH_KEY_PATH` | Path to SSH private key |

## Skills

- **market-research** - Ticker search, price lookups, news
- **technical-analysis** - RSI, SMA, trend analysis
- **web-scraping** - Firecrawl and Playwright integration

## Commands

In Discord, mention the bot or use the prefix:

```
@Band Director What's the latest on AAPL?
@Band Director Research Bitcoin technicals
@Band Director Set up a daily SPY summary at 9am
```

## Backup

```bash
/opt/hermes-fleet/scripts/backup.sh
```

## License

MIT

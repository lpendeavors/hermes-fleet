# Hermes Financial Research Fleet - Design Document

## Overview

Infrastructure-as-Code (IaC) repository for deploying a Hermes Agent instance configured for financial market research via Discord. The agent uses Kimi (Moonshot AI) as its LLM provider and has access to tools for web scraping, technical analysis, and market data retrieval.

## Architecture

### Repository Structure
```
hermes-fleet/
├── docker-compose.yml          # Hermes + MCP servers orchestration
├── .github/
│   └── workflows/
│       └── deploy.yml          # SSH-based CI/CD pipeline
├── config/
│   ├── hermes.yml              # Core Hermes configuration (LLM, memory, personality)
│   ├── discord.yml             # Discord gateway settings
│   └── mcp-servers.yml         # MCP server definitions
├── skills/
│   ├── market-research/        # Custom financial research skills
│   ├── technical-analysis/
│   └── web-scraping/
├── scripts/
│   ├── install.sh              # VPS bootstrap script
│   └── backup.sh               # Data volume backup
└── docs/
    └── runbooks/
```

### Docker Architecture
- **Hermes Agent container** (`nousresearch/hermes-agent:latest`)
  - Main orchestrator with Discord gateway enabled
  - Mounts config directory and skills directory as volumes
  - Exposes no external ports (communicates via Discord API)
  
- **MCP Servers** (sidecar containers or inline)
  - **Firecrawl MCP**: Web scraping and extraction
  - **Playwright MCP**: Browser automation for JavaScript-heavy sites
  - Connected to Hermes via stdio or HTTP transport

- **Persistent volumes**
  - `hermes-data`: Memory database, skill storage, logs
  - Survives container restarts and updates

### Hermes Configuration

#### LLM Provider
- **Provider**: Kimi (Moonshot AI)
- **API Key**: Injected via `KIMI_API_KEY` environment variable
- **Model**: Configurable (default to `kimi-latest`)

#### Gateway
- **Platform**: Discord
- **Token**: Injected via `DISCORD_TOKEN` environment variable
- **Intents**: Message content, guild messages, DM messages

#### Personality
- **SOUL.md**: Configured as a financial research analyst
- **Context files**: Market research templates and guidelines

#### Memory & Learning
- **FTS5**: Enabled for cross-session recall
- **Periodic nudges**: Enabled for autonomous skill improvement
- **Honcho integration**: User modeling across sessions

#### Skills System
- **Path**: `./skills/` mounted into container
- **Auto-discovery**: Hermes loads all skills on startup
- **Custom skills**:
  - `market-research`: Query market data APIs, summarize news
  - `technical-analysis`: Chart pattern recognition, indicator calculation
  - `web-scraping`: Firecrawl/Playwright wrapper for financial sites

### CI/CD Pipeline

#### Trigger
- Push to `main` branch
- Manual workflow dispatch

#### Steps
1. Checkout repository
2. Configure SSH agent with VPS private key
3. SSH to VPS and execute:
   ```bash
   cd /opt/hermes-fleet
   git pull origin main
   docker compose up -d --build
   docker compose ps
   ```
4. Health check: Verify Discord bot comes online within 60 seconds

#### Rollback
- Previous container image retained
- Manual rollback: `docker compose down && docker compose up -d` with previous git ref

### Secrets Management

| Secret | Source | Usage |
|--------|--------|-------|
| `KIMI_API_KEY` | GitHub Secret | LLM inference |
| `DISCORD_TOKEN` | GitHub Secret | Discord bot auth |
| `VPS_HOST` | GitHub Secret | Deployment target |
| `VPS_USER` | GitHub Secret | SSH username |
| `VPS_SSH_KEY` | GitHub Secret | SSH authentication |

**Rule**: No secrets committed to repository. All injected via environment variables.

### VPS Setup

#### Requirements
- Docker 24.0+
- Docker Compose v2
- Git
- 2 vCPU, 4GB RAM minimum
- 20GB storage

#### Bootstrap
```bash
# Run once on new VPS
curl -fsSL https://raw.githubusercontent.com/your-org/hermes-fleet/main/scripts/install.sh | bash
```

### Data Persistence & Backup

#### Persistent Data
- Hermes memory database (SQLite)
- Created skills
- Conversation logs

#### Backup Strategy
- Daily automated backup via `backup.sh`
- Backup target: VPS-local tar.gz + optional S3/rsync
- Retention: 7 daily backups

## Security Considerations

1. **Container isolation**: Hermes runs as non-root user
2. **Network**: No exposed ports; all communication outbound-only
3. **Secrets**: Environment variables only, never in image layers
4. **MCP sandbox**: Untrusted MCP tools run in isolated containers
5. **Command approval**: Enabled for destructive operations

## Monitoring & Observability

1. **Container logs**: `docker compose logs -f hermes`
2. **Discord status**: Bot presence indicator
3. **Health endpoint**: Optional HTTP health check on `/health`
4. **Alerts**: Discord webhook notification on deployment failures

## Future Extensions

1. **Multi-agent swarm**: Separate agents for crypto/equities/forex
2. **Database integration**: PostgreSQL for structured market data
3. **Alerting system**: Price alerts via scheduled cron jobs
4. **Backtesting engine**: Strategy validation skills

## Success Criteria

1. Agent responds to Discord messages within 5 seconds
2. Can research stocks/crypto via natural language queries
3. Can set up cron jobs for recurring research tasks
4. Deploys automatically on push to main
5. Survives VPS reboot without data loss

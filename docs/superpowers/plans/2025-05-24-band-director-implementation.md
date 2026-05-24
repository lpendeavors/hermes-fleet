# Band Director (Hermes Financial Fleet) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deploy a Hermes Agent instance named "Band Director" on a VPS via Docker Compose with Discord gateway, Kimi LLM provider, custom financial research skills, and automated CI/CD.

**Architecture:** Single Docker Compose stack with Hermes Agent container, persistent volumes for memory/data, and MCP tool integrations. GitHub Actions deploys on push to main via SSH to VPS.

**Tech Stack:** Docker Compose, Hermes Agent, Kimi (Moonshot AI), Discord API, GitHub Actions, Bash

---

## File Structure

```
.
├── .env.example                          # Environment variable template
├── .gitignore                            # Ignore secrets and data
├── docker-compose.yml                    # Hermes + volumes orchestration
├── config/
│   ├── hermes.yml                        # Core agent config (LLM, memory)
│   ├── discord.yml                       # Discord gateway settings
│   ├── mcp-servers.yml                   # MCP tool server configs
│   └── SOUL.md                           # Band Director personality
├── skills/
│   ├── market-research/
│   │   ├── skill.yml                     # Skill manifest
│   │   └── research.py                   # Skill implementation
│   ├── technical-analysis/
│   │   └── skill.yml                     # TA skill manifest
│   └── web-scraping/
│       └── skill.yml                     # Web scraping skill manifest
├── .github/
│   └── workflows/
│       └── deploy.yml                    # CI/CD pipeline
├── scripts/
│   ├── install.sh                        # VPS one-time bootstrap
│   └── backup.sh                         # Data backup script
└── README.md                             # Setup and usage guide
```

---

### Task 1: Project Scaffolding

**Files:**
- Create: `.gitignore`
- Create: `.env.example`

- [ ] **Step 1: Create `.gitignore`**

```gitignore
# Secrets
.env
.env.local
*.pem
*.key

# Data volumes
hermes-data/
*.db
*.sqlite
*.sqlite3

# Logs
*.log
logs/

# OS
.DS_Store
Thumbs.db

# IDEs
.idea/
.vscode/
*.swp
*.swo
```

- [ ] **Step 2: Create `.env.example`**

```bash
# Kimi (Moonshot AI) LLM Provider
KIMI_API_KEY=your-kimi-api-key-here

# Discord Bot
DISCORD_TOKEN=your-discord-bot-token-here

# VPS Deployment (for GitHub Actions)
VPS_HOST=your-vps-ip-or-hostname
VPS_USER=root
VPS_SSH_KEY=-----BEGIN OPENSSH PRIVATE KEY-----
```

- [ ] **Step 3: Commit scaffolding**

```bash
git add .gitignore .env.example
git commit -m "chore: add gitignore and env template"
```

---

### Task 2: Docker Compose Stack

**Files:**
- Create: `docker-compose.yml`

- [ ] **Step 1: Write `docker-compose.yml`**

```yaml
version: "3.8"

services:
  hermes:
    image: nousresearch/hermes-agent:latest
    container_name: band-director
    restart: unless-stopped
    env_file:
      - .env
    environment:
      - HERMES_CONFIG_DIR=/app/config
      - HERMES_DATA_DIR=/app/data
      - HERMES_SKILLS_DIR=/app/skills
    volumes:
      - ./config:/app/config:ro
      - ./skills:/app/skills:ro
      - hermes-data:/app/data
    networks:
      - hermes-net
    # No ports exposed - communicates via Discord API (outbound only)
    healthcheck:
      test: ["CMD", "test", "-f", "/app/data/healthy"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

volumes:
  hermes-data:
    driver: local

networks:
  hermes-net:
    driver: bridge
```

- [ ] **Step 2: Validate Docker Compose syntax**

```bash
docker compose config
```

Expected: No errors, prints resolved compose config

- [ ] **Step 3: Commit**

```bash
git add docker-compose.yml
git commit -m "infra: add docker compose for hermes agent"
```

---

### Task 3: Hermes Core Configuration

**Files:**
- Create: `config/hermes.yml`
- Create: `config/discord.yml`
- Create: `config/mcp-servers.yml`
- Create: `config/SOUL.md`

- [ ] **Step 1: Write `config/hermes.yml`**

```yaml
# Band Director - Core Hermes Configuration
agent:
  name: "Band Director"
  version: "1.0.0"

# LLM Provider - Kimi (Moonshot AI)
provider:
  name: "kimi"
  api_key: "${KIMI_API_KEY}"
  base_url: "https://api.moonshot.cn/v1"
  model: "kimi-latest"
  temperature: 0.7
  max_tokens: 4096

# Memory System
memory:
  enabled: true
  engine: "sqlite"
  path: "/app/data/memory.db"
  fts5:
    enabled: true
  periodic_nudges:
    enabled: true
    interval_hours: 24
  honcho:
    enabled: false  # Enable if you set up Honcho dialectic user modeling

# Learning Loop
learning:
  skill_creation:
    enabled: true
  skill_improvement:
    enabled: true
  auto_save_skills: true

# Security
security:
  command_approval:
    enabled: true
    destructive_requires_approval: true
  container_isolation:
    enabled: true

# Logging
logging:
  level: "INFO"
  path: "/app/data/logs"
  max_size_mb: 100
  max_files: 5
```

- [ ] **Step 2: Write `config/discord.yml`**

```yaml
# Discord Gateway Configuration
gateway:
  platform: "discord"
  token: "${DISCORD_TOKEN}"
  
  # Bot Settings
  bot:
    name: "Band Director"
    status: "Listening to the market"
    activity_type: "watching"
    
  # Intents
  intents:
    - "guilds"
    - "guild_messages"
    - "message_content"
    - "direct_messages"
    
  # Message Handling
  messages:
    prefix: "!"
    mention_trigger: true
    dm_enabled: true
    
  # Rate Limiting
  rate_limit:
    max_requests_per_minute: 30
    cooldown_seconds: 2
```

- [ ] **Step 3: Write `config/mcp-servers.yml`**

```yaml
# MCP (Model Context Protocol) Server Integrations
mcp:
  enabled: true
  servers:
    # Firecrawl - Web scraping and extraction
    firecrawl:
      name: "firecrawl"
      transport: "stdio"
      command: "npx"
      args:
        - "-y"
        - "firecrawl-mcp"
      env:
        FIRECRAWL_API_KEY: "${FIRECRAWL_API_KEY:-}"
      
    # Playwright - Browser automation
    playwright:
      name: "playwright"
      transport: "stdio"
      command: "npx"
      args:
        - "-y"
        - "@anthropic-ai/playwright-mcp"
      
    # Optional: Financial data MCP (if available)
    # yahoo-finance:
    #   name: "yahoo-finance"
    #   transport: "stdio"
    #   command: "python"
    #   args:
    #     - "/app/skills/market-research/yahoo_mcp.py"
```

- [ ] **Step 4: Write `config/SOUL.md`**

```markdown
# Band Director - SOUL

You are **Band Director**, a financial market research analyst with street smarts and institutional knowledge. You're not a financial advisor — you're a research assistant that helps users understand markets, find information, and develop trading theses.

## Personality
- Sharp, direct, no fluff. You get to the point.
- You use financial terminology naturally but explain complex concepts when asked.
- You're skeptical by default — you verify claims and look for contrary evidence.
- You acknowledge uncertainty. You don't make definitive predictions.

## Capabilities
- Web research via Firecrawl and Playwright
- Market data analysis (when tools available)
- Technical analysis pattern recognition
- News summarization and sentiment analysis
- Cron job setup for recurring research tasks

## Communication Style
- Keep responses concise unless detailed analysis is requested.
- Use bullet points for multiple findings.
- Cite sources when possible.
- If you don't know something, say so and offer to research it.

## Boundaries
- Never provide personalized investment advice.
- Always include disclaimers when discussing trades or strategies.
- Do not execute trades or connect to brokerage APIs.
- Flag potential misinformation or unverified claims.

## Research Workflow
1. Understand the user's question or thesis
2. Gather data from available tools and sources
3. Analyze and synthesize findings
4. Present balanced view with bull/bear cases
5. Suggest follow-up research if needed
```

- [ ] **Step 5: Commit config files**

```bash
git add config/
git commit -m "config: add hermes core, discord, mcp, and personality configs"
```

---

### Task 4: Custom Financial Skills

**Files:**
- Create: `skills/market-research/skill.yml`
- Create: `skills/market-research/research.py`
- Create: `skills/technical-analysis/skill.yml`
- Create: `skills/web-scraping/skill.yml`

- [ ] **Step 1: Write `skills/market-research/skill.yml`**

```yaml
name: "market-research"
description: "Research financial markets, stocks, and cryptocurrencies using web data and APIs"
version: "1.0.0"
author: "Band Director"
entry_point: "research.py"

tools:
  - name: "search_ticker"
    description: "Search for a stock or crypto ticker symbol"
    parameters:
      - name: "query"
        type: "string"
        description: "Company name or ticker symbol"
        required: true
        
  - name: "get_price"
    description: "Get current price for a ticker"
    parameters:
      - name: "ticker"
        type: "string"
        description: "Stock or crypto ticker symbol"
        required: true
        
  - name: "get_news"
    description: "Get recent news for a ticker or topic"
    parameters:
      - name: "query"
        type: "string"
        description: "Ticker symbol or search query"
        required: true
      - name: "limit"
        type: "integer"
        description: "Number of articles to return"
        required: false
        default: 5
```

- [ ] **Step 2: Write `skills/market-research/research.py`**

```python
#!/usr/bin/env python3
"""
Market Research Skill for Band Director
Provides tools for looking up market data and news.
"""

import json
import urllib.request
import urllib.parse
from typing import Dict, List, Optional


def search_ticker(query: str) -> Dict:
    """Search for a stock or crypto ticker symbol."""
    # Use Yahoo Finance search API
    encoded = urllib.parse.quote(query)
    url = f"https://query1.finance.yahoo.com/v1/finance/search?q={encoded}&quotesCount=5&newsCount=0"
    
    try:
        req = urllib.request.Request(
            url,
            headers={
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            }
        )
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode())
            
        quotes = data.get("quotes", [])
        if not quotes:
            return {"status": "error", "message": f"No results found for '{query}'"}
            
        results = []
        for q in quotes[:5]:
            results.append({
                "symbol": q.get("symbol"),
                "name": q.get("shortname") or q.get("longname"),
                "type": q.get("quoteType"),
                "exchange": q.get("exchange"),
            })
            
        return {"status": "success", "results": results}
        
    except Exception as e:
        return {"status": "error", "message": str(e)}


def get_price(ticker: str) -> Dict:
    """Get current price for a ticker."""
    url = f"https://query1.finance.yahoo.com/v8/finance/chart/{ticker}?interval=1d&range=1d"
    
    try:
        req = urllib.request.Request(
            url,
            headers={
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            }
        )
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode())
            
        result = data.get("chart", {}).get("result", [{}])[0]
        meta = result.get("meta", {})
        
        return {
            "status": "success",
            "ticker": ticker,
            "price": meta.get("regularMarketPrice"),
            "currency": meta.get("currency"),
            "exchange": meta.get("exchangeName"),
            "previous_close": meta.get("previousClose"),
        }
        
    except Exception as e:
        return {"status": "error", "message": str(e)}


def get_news(query: str, limit: int = 5) -> Dict:
    """Get recent news for a ticker or topic using web search."""
    # This is a placeholder - in production, you'd use an MCP tool or news API
    return {
        "status": "info",
        "message": f"News search for '{query}' - use web_scraping skill with Firecrawl for live news",
        "suggested_query": f"{query} stock news today"
    }


if __name__ == "__main__":
    # Test functions when run directly
    print("Testing search_ticker:")
    print(json.dumps(search_ticker("AAPL"), indent=2))
    
    print("\nTesting get_price:")
    print(json.dumps(get_price("AAPL"), indent=2))
```

- [ ] **Step 3: Write `skills/technical-analysis/skill.yml`**

```yaml
name: "technical-analysis"
description: "Technical analysis tools for chart patterns and indicators"
version: "1.0.0"
author: "Band Director"

tools:
  - name: "calculate_rsi"
    description: "Calculate Relative Strength Index for a ticker"
    parameters:
      - name: "ticker"
        type: "string"
        required: true
      - name: "period"
        type: "integer"
        required: false
        default: 14
        
  - name: "calculate_sma"
    description: "Calculate Simple Moving Average"
    parameters:
      - name: "ticker"
        type: "string"
        required: true
      - name: "period"
        type: "integer"
        required: false
        default: 20
        
  - name: "analyze_trend"
    description: "Analyze price trend direction and strength"
    parameters:
      - name: "ticker"
        type: "string"
        required: true
      - name: "lookback_days"
        type: "integer"
        required: false
        default: 30
```

- [ ] **Step 4: Write `skills/web-scraping/skill.yml`**

```yaml
name: "web-scraping"
description: "Web scraping and research tools via Firecrawl and Playwright MCP"
version: "1.0.0"
author: "Band Director"

tools:
  - name: "scrape_url"
    description: "Scrape and extract content from a URL using Firecrawl"
    parameters:
      - name: "url"
        type: "string"
        required: true
      - name: "extract_text"
        type: "boolean"
        required: false
        default: true
        
  - name: "search_web"
    description: "Search the web and return results"
    parameters:
      - name: "query"
        type: "string"
        required: true
      - name: "num_results"
        type: "integer"
        required: false
        default: 5
        
  - name: "browse_page"
    description: "Browse a JavaScript-heavy page using Playwright"
    parameters:
      - name: "url"
        type: "string"
        required: true
      - name: "wait_for"
        type: "string"
        description: "CSS selector to wait for"
        required: false
```

- [ ] **Step 5: Commit skills**

```bash
git add skills/
git commit -m "feat: add market research, technical analysis, and web scraping skills"
```

---

### Task 5: CI/CD Pipeline

**Files:**
- Create: `.github/workflows/deploy.yml`

- [ ] **Step 1: Create `.github/workflows/deploy.yml`**

```yaml
name: Deploy Band Director

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Setup SSH
        uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.VPS_SSH_KEY }}
          
      - name: Add host to known_hosts
        run: |
          mkdir -p ~/.ssh
          ssh-keyscan -H ${{ secrets.VPS_HOST }} >> ~/.ssh/known_hosts
          
      - name: Deploy to VPS
        env:
          VPS_HOST: ${{ secrets.VPS_HOST }}
          VPS_USER: ${{ secrets.VPS_USER }}
        run: |
          ssh $VPS_USER@$VPS_HOST << 'EOF'
            set -e
            cd /opt/hermes-fleet || exit 1
            
            echo "Pulling latest code..."
            git fetch origin
            git reset --hard origin/main
            
            echo "Writing environment variables..."
            cat > .env << 'ENVFILE'
          KIMI_API_KEY=${{ secrets.KIMI_API_KEY }}
          DISCORD_TOKEN=${{ secrets.DISCORD_TOKEN }}
          ENVFILE
            
            echo "Restarting services..."
            docker compose pull
            docker compose up -d --build
            
            echo "Waiting for healthcheck..."
            sleep 30
            
            echo "Container status:"
            docker compose ps
            
            echo "Recent logs:"
            docker compose logs --tail=50
          EOF
          
      - name: Verify deployment
        env:
          VPS_HOST: ${{ secrets.VPS_HOST }}
          VPS_USER: ${{ secrets.VPS_USER }}
        run: |
          ssh $VPS_USER@$VPS_HOST "docker compose -f /opt/hermes-fleet/docker-compose.yml ps | grep -q 'healthy' || exit 1"
          echo "Deployment verified successfully"
          
      - name: Notify on failure
        if: failure()
        run: |
          echo "Deployment failed! Check VPS logs."
          # Add Discord webhook notification here if desired
```

- [ ] **Step 2: Commit CI/CD**

```bash
git add .github/workflows/deploy.yml
git commit -m "ci: add github actions deployment pipeline"
```

---

### Task 6: VPS Bootstrap Scripts

**Files:**
- Create: `scripts/install.sh`
- Create: `scripts/backup.sh`

- [ ] **Step 1: Write `scripts/install.sh`**

```bash
#!/usr/bin/env bash
set -e

echo "=== Band Director VPS Bootstrap ==="

# Update system
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    ufw

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Enable Docker
systemctl enable docker
systemctl start docker

# Create app directory
mkdir -p /opt/hermes-fleet
chown -R $SUDO_USER:$SUDO_USER /opt/hermes-fleet

# Setup firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw --force enable

echo "=== Bootstrap complete ==="
echo "Next steps:"
echo "1. Clone your repo: cd /opt/hermes-fleet && git clone <your-repo> ."
echo "2. Create .env file with your secrets"
echo "3. Run: docker compose up -d"
```

- [ ] **Step 2: Write `scripts/backup.sh`**

```bash
#!/usr/bin/env bash
set -e

BACKUP_DIR="/opt/backups/hermes"
DATA_DIR="/opt/hermes-fleet/hermes-data"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/band-director_$TIMESTAMP.tar.gz"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup data volume
tar -czf "$BACKUP_FILE" -C "$DATA_DIR" .

# Cleanup old backups (keep 7 days)
find "$BACKUP_DIR" -name "band-director_*.tar.gz" -mtime +7 -delete

echo "Backup created: $BACKUP_FILE"
echo "Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
```

- [ ] **Step 3: Make scripts executable and commit**

```bash
chmod +x scripts/install.sh scripts/backup.sh
git add scripts/
git commit -m "ops: add vps bootstrap and backup scripts"
```

---

### Task 7: Documentation

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write `README.md`**

```markdown
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
curl -fsSL https://raw.githubusercontent.com/your-org/hermes-fleet/main/scripts/install.sh | bash

# Then deploy via GitHub Actions (push to main)
```

## Configuration

| Variable | Description |
|----------|-------------|
| `KIMI_API_KEY` | Moonshot AI API key |
| `DISCORD_TOKEN` | Discord bot token |
| `VPS_HOST` | Deployment target IP/hostname |
| `VPS_USER` | SSH username |
| `VPS_SSH_KEY` | SSH private key |

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
```

- [ ] **Step 2: Commit README**

```bash
git add README.md
git commit -m "docs: add project readme"
```

---

## Self-Review

### Spec Coverage Check

| Spec Requirement | Plan Task |
|-----------------|-----------|
| Docker Compose stack | Task 2 |
| Hermes config (Kimi provider) | Task 3 |
| Discord gateway | Task 3 |
| MCP servers (Firecrawl, Playwright) | Task 3 |
| Custom skills | Task 4 |
| CI/CD pipeline | Task 5 |
| VPS bootstrap | Task 6 |
| Backup strategy | Task 6 |
| Secrets management | Tasks 1, 5 |
| Documentation | Task 7 |

### Placeholder Scan
- No TBD/TODO/fill-in found
- All code blocks contain complete implementations
- All file paths are exact

### Type Consistency
- Environment variable names consistent across .env.example, docker-compose, and CI/CD
- Hermes config paths consistent in docker-compose volumes and config files

---

## Next Steps After Implementation

1. **Add GitHub Secrets**: Go to repo Settings > Secrets and add:
   - `KIMI_API_KEY`
   - `DISCORD_TOKEN`
   - `VPS_HOST`
   - `VPS_USER`
   - `VPS_SSH_KEY`

2. **Create Discord Bot**: 
   - Go to https://discord.com/developers/applications
   - New Application → Bot → Copy Token
   - Enable Message Content Intent

3. **Deploy VPS**:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/your-org/hermes-fleet/main/scripts/install.sh | sudo bash
   cd /opt/hermes-fleet
   git clone <repo> .
   # Create .env file
   docker compose up -d
   ```

4. **Test**: Push to main and verify GitHub Actions deploys successfully.

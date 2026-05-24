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

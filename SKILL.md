---
name: chrome-cdp
description: Interact with local Chrome browser session (only on explicit user approval after being asked to inspect, debug, or interact with a page open in Chrome)
---

# Chrome CDP

Lightweight Chrome DevTools Protocol CLI. Connects directly via WebSocket — no Puppeteer, works with 100+ tabs, instant connection.

## Prerequisites

- Chrome with remote debugging enabled: open `chrome://inspect/#remote-debugging` and toggle the switch
- Node.js 22+ (uses built-in WebSocket)

## Commands

All commands use `scripts/cdp.mjs`. The `<target>` is a **unique** targetId prefix from `list`; copy the full prefix shown in the `list` output (for example `6BE827FA`). The CLI rejects ambiguous prefixes.

### List open pages

```bash
scripts/cdp.mjs list
```

`list` shows enough targetId characters to disambiguate the currently open tabs.

### Take a screenshot

```bash
scripts/cdp.mjs shot <target>                    # saves to /tmp/screenshot.png
scripts/cdp.mjs shot <target> /tmp/myshot.png    # custom path
```

### Accessibility tree snapshot

```bash
scripts/cdp.mjs snap <target>
```

Returns a text representation of the page's accessibility tree — useful for understanding page structure without rendering.

### Evaluate JavaScript

```bash
scripts/cdp.mjs eval <target> document.title
scripts/cdp.mjs eval <target> "JSON.stringify([...document.querySelectorAll('h1')].map(e => e.textContent))"
```

Expressions are evaluated in the page context. Return values must be JSON-serializable.

### Get HTML

```bash
scripts/cdp.mjs html <target>                    # full page HTML
scripts/cdp.mjs html <target> ".sidebar"        # specific CSS selector
```

### Navigate

```bash
scripts/cdp.mjs nav <target> https://example.com
```

Waits for the navigation to finish loading and reports CDP navigation errors.

### Network performance entries

```bash
scripts/cdp.mjs net <target>
```

Shows resource timing entries (duration, transfer size, initiator type).

### Stop daemons

```bash
scripts/cdp.mjs stop           # stop all tab daemons
scripts/cdp.mjs stop <target>  # stop daemon for specific tab
```

## Tips

- Use `list` to find which page to target. Copy the full prefix shown in the list output.
- For large pages, prefer `snap` over `html` — it's more compact and gives semantic structure.
- Use `eval` for targeted data extraction rather than pulling full HTML.
- Screenshots are useful for visual state verification — use the `read` tool to view the saved PNG.
- Chrome shows an "Allow debugging" modal once per tab on first access. A background daemon keeps the session alive so subsequent commands to the same tab need no further approval. Daemons auto-exit after 20 minutes of inactivity.

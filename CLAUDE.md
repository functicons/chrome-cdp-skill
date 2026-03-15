# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A lightweight Chrome DevTools Protocol (CDP) CLI tool packaged as a "pi skill". It connects directly to a user's running Chrome instance via CDP WebSocket — no Puppeteer, no separate browser. Distributed as an npm package (`pi-chrome-cdp`).

## Architecture

The entire tool is a single file: `skills/chrome-cdp/scripts/cdp.mjs` (~840 lines, Node.js 22+, zero npm dependencies — uses built-in `WebSocket`).

**Key design:** Per-tab persistent daemon architecture. When a command targets a tab, a background daemon process is spawned that holds the CDP session open via a Unix socket (`/tmp/cdp-<targetId>.sock`). This avoids Chrome's "Allow debugging" modal firing repeatedly. Daemons auto-exit after 20 minutes idle.

**Flow:** CLI → resolves target prefix → connects to (or spawns) tab daemon via Unix socket → daemon forwards command over CDP WebSocket → result returned via NDJSON over the socket.

**Key classes/functions:**
- `CDP` class: Raw WebSocket CDP client with send/event/waitForEvent
- `runDaemon()`: Per-tab daemon that holds CDP session and serves commands over Unix socket
- `main()`: CLI entry point, handles target resolution and daemon lifecycle
- Command functions (`snapStr`, `evalStr`, `shotStr`, etc.): Each implements one CLI command

## Running and Testing

```bash
# Run directly (no build step, no npm install needed)
node skills/chrome-cdp/scripts/cdp.mjs list
node skills/chrome-cdp/scripts/cdp.mjs shot <target>

# Prerequisites: Chrome with remote debugging enabled at chrome://inspect/#remote-debugging
```

There is no build system, no linter config, and no test suite. The project has no dependencies (`package.json` has no `dependencies` or `devDependencies`).

## Packaging

`SKILL.md` is the pi skill manifest (name, description, instructions for AI agents). The npm package includes only `skills/` and `README.md` (see `files` in `package.json`).

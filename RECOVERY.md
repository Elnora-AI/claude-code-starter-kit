# RECOVERY.md — Common Failures and Fixes

If something went wrong during install, find your symptom below. Each fix
takes 1–5 minutes. If your problem isn't listed, ask Claude or email
`~/claude-starter-install.log` to whoever is supporting you.

---

## 1. "Claude says I need a Pro/Max plan to use it"

**Symptom:** `claude` runs but says "subscription required" or similar after
browser login.

**Fix:** the workshop and this kit assume you have an active **Claude Pro or
Max subscription**. Visit `https://claude.com/upgrade`, subscribe, then run
`claude` again to log back in. Once `claude` opens normally, re-run the install
one-liner — it'll pick up where it left off (already-installed tools are
skipped).

---

## 2. "Xcode dialog popped up and I closed it" (macOS)

**Symptom:** the install script paused on a step like "Installing Git" and
then errored with `xcode-select: error: command line tools are missing`.

**Fix:** trigger the install again and click **Install** when the system
dialog appears. It takes 5–10 minutes.

```
xcode-select --install
```

When it finishes, re-run the install one-liner.

---

## 3. "Nothing downloads / network seems blocked"

**Symptom:** the install hangs or errors with `Could not resolve host` /
`SSL handshake failed` / `407 Proxy Authentication`.

**Fix:** something between you and the internet is blocking the install — a
corporate firewall, a Wi-Fi captive portal, or VPN. Try in this order:

1. Open a browser and confirm you can reach `https://claude.ai`,
   `https://github.com`, and `https://platform.elnora.ai`. If any are blocked,
   that's your problem — switch to a personal Wi-Fi or hotspot.
2. If you're behind a corporate proxy and you know the URL, tell your shell:
   ```
   export HTTPS_PROXY=http://your-proxy:port
   export HTTP_PROXY=http://your-proxy:port
   ```
   On Windows PowerShell:
   ```
   $env:HTTPS_PROXY = "http://your-proxy:port"
   $env:HTTP_PROXY  = "http://your-proxy:port"
   ```
   Then re-run the install one-liner.
3. If you're at a workshop, ask the facilitator — they may have a hotspot.

---

## 4. "Elnora auth fails / `elnora whoami` returns an error"

**Symptom:** `elnora whoami` or `elnora doctor` returns `401 Unauthorized` or
`403 Forbidden`, or `elnora auth status` says you're not authenticated.

**Fix:** re-authenticate with a fresh key.

```
elnora auth status
```

If it reports "not authenticated" (or the wrong account), generate a new key
and log in again:

1. Visit `https://platform.elnora.ai/settings` → **API Keys** tab.
2. Click **Create key**, name it after your machine.
3. Copy the new key (it starts with `elnora_live_`).
4. Run `elnora auth login --api-key <paste-new-key>` — this saves the key to
   `~/.elnora/profiles.toml` so every shell picks it up.
5. Run `elnora whoami` again.

If it still fails with a real key, the network may be blocking
`https://platform.elnora.ai` — see #3.

---

## 5. "The setup script half-failed"

**Symptom:** the script finished but printed `⚠ N step(s) failed — remediation
below`. Some tools are installed, others aren't.

**Fix:** the install scripts are **idempotent** — re-running them only
re-attempts the failed steps and skips what's already installed. So:

1. Read the remediation hints the script printed for each failed step.
2. Fix the underlying issue (most often: a system dialog you missed, or a
   network timeout).
3. Re-run the install one-liner — same command you started with.

If the same step fails three times in a row, stop and ask for help. Email or
share `~/claude-starter-install.log` so someone can see what's going wrong.

---

## Still stuck?

Send `~/claude-starter-install.log` (Mac/Linux) or
`%USERPROFILE%\claude-starter-install.log` (Windows) to whoever is supporting
you. That file has the full transcript — what was attempted, what failed,
exit codes, and the order things happened.

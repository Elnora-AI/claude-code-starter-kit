# Plugin Marketplaces & Recommended Plugins

This guide shows you how to find, install, and manage Claude Code plugins.

---

## How to install plugins

1. Open Claude Code (in VS Code terminal or standalone)
2. Type `/plugins` and press Enter
3. You'll see the list of configured marketplaces
4. Browse a marketplace and select a plugin to install
5. Claude will download and activate it

That's it. Plugins add new skills, agents, and commands to Claude.

---

## Configured Marketplaces

These marketplaces are already configured in your `.claude/settings.json`:

### 1. Anthropic Official (`claude-code-plugins`)

**Source**: github.com/anthropics/claude-code
**Trust level**: Highest — maintained by Anthropic (the company that makes Claude)

| Plugin | What it gives you | Best for |
|--------|-------------------|----------|
| **commit-commands** | `/commit` and `/commit-push-pr` commands | Everyone — makes Git easier |
| **feature-dev** | Guided feature development workflow | Developers building features |
| **pr-review-toolkit** | PR review with multiple specialized reviewers | Teams doing code reviews |
| **code-review** | Code review command | Reviewing pull requests |
| **hookify** | Create rules to prevent unwanted behaviors | Advanced users |
| **plugin-dev** | Tools for creating your own plugins | Plugin developers |

### 2. Anthropic Skills (`anthropic-agent-skills`)

**Source**: github.com/anthropics/skills
**Trust level**: High — official Anthropic skills collection

| Plugin | What it gives you | Best for |
|--------|-------------------|----------|
| **document-skills** | Read/create PDFs, Word docs, Excel, PowerPoint, and more | **Everyone — install this first** |

What `document-skills` adds:
- `/pdf` — Extract text from PDFs, create new PDFs, merge/split documents
- `/docx` — Create and edit Word documents
- `/xlsx` — Create and edit Excel spreadsheets with formulas and charts
- `/pptx` — Create and edit PowerPoint presentations

### 3. Official Extras (`claude-plugins-official`)

**Source**: github.com/anthropics/claude-code
**Trust level**: High — official Anthropic extras

| Plugin | What it gives you | Best for |
|--------|-------------------|----------|
| **stripe** | Stripe payment integration helpers | Finance / billing teams |
| **frontend-design** | Production-quality UI/web design | Designers and frontend devs |

---

## Other Marketplaces (add later)

These are community-maintained. Quality is generally good but not Anthropic-verified.
You can add them via `/plugins` > "Add marketplace" when you're ready.

### Community Workflows (`claude-code-workflows`)

**Source**: github.com/wshobson/agents
**What's in it**: 15+ plugins covering backend development, Python, databases, security, testing, observability, and more. Best for development teams.

### Superpowers (`superpowers-marketplace`)

**Source**: github.com/obra/superpowers-marketplace
**What's in it**: Advanced workflow skills — brainstorming, TDD, systematic debugging, parallel agent dispatch. Best for power users.

---

## Recommended first installs

For most people, start with these two:

1. **document-skills** (from `anthropic-agent-skills`) — lets Claude work with PDFs, Word, Excel, PowerPoint
2. **commit-commands** (from `claude-code-plugins`) — makes Git commits easier with `/commit`

Then explore based on your role:

| Your role | Also consider |
|-----------|---------------|
| **Operations / Project Management** | commit-commands, code-review |
| **Research / Science** | document-skills covers most needs |
| **Business / Strategy** | document-skills, frontend-design |
| **Engineering / Development** | feature-dev, pr-review-toolkit, code-review |

---

## How to remove a plugin

```
/plugins
```

Select the plugin you want to remove and choose "Uninstall."

---

## How to add a new marketplace

1. Open `/plugins`
2. Select "Add marketplace"
3. Enter the marketplace name and GitHub URL
4. The marketplace will appear in your list

You can also edit `.claude/settings.json` directly — add an entry to the `pluginMarketplaces` array.

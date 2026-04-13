# Knowledge Base

This folder is your local knowledge base — a collection of markdown (`.md`) files that Claude can read, search, and reference when you ask questions.

## What is this?

Think of it as Claude's memory for your project. When you put information here as `.md` files, you can ask Claude to find and use that information. For example:

- Meeting notes
- Project plans
- Research summaries
- Policies and procedures
- Reference documents
- Anything you want Claude to be able to look up

## How to use it

### Adding files

Just create `.md` files in this folder or its subfolders. Use any text editor, VS Code, or Obsidian.

A basic file looks like this:

```markdown
# Meeting Notes — April 14, 2026

**Attendees**: Alice, Bob, Charlie
**Topic**: Q2 planning

## Key decisions
- Launch date moved to June 1
- Budget approved for new tooling

## Action items
- [ ] Alice: Draft the timeline by Friday
- [ ] Bob: Set up the new environment
```

### Querying from Claude Code

In Claude Code, just ask naturally:

- "What were the action items from the April 14 meeting?"
- "Search the knowledge base for anything about the Q2 launch"
- "Summarize all meeting notes from this month"

Claude will use the Read, Glob, and Grep tools to find relevant files.

### Using with Obsidian

[Obsidian](https://obsidian.md) is a free app for viewing and organizing markdown files. To use it:

1. Download Obsidian from https://obsidian.md
2. Open this `knowledge-base` folder as a vault in Obsidian
3. Now you can browse, edit, and organize your notes visually

Obsidian is optional — the knowledge base works with any text editor. But Obsidian makes it much nicer to navigate.

## Folder structure

Organize however makes sense to you. Some suggestions:

```
knowledge-base/
├── meetings/          # Meeting notes
├── projects/          # Project plans and briefs
├── research/          # Research summaries
├── reference/         # Policies, procedures, reference docs
└── personal/          # Your personal notes
```

## Tips

- **Use descriptive file names** — `meeting-notes-2026-04-14.md` is better than `notes.md`
- **Add dates** — Helps Claude find things chronologically
- **Use headings** — Claude can search within files, and headings help it find the right section
- **Keep files focused** — One topic per file is easier to search than one giant file

# Instructor `v1.0.0`

> Create complete, self-contained learning modules covering theory, practical applications, and a single end-to-end project for any topic.

## Overview

The **instructor** plugin provides an agent that turns any topic into a structured learning module a student can follow independently. The module always opens with prerequisites (knowledge and tools), walks through the theory, reinforces concepts with runnable examples, then guides the learner through one complete project from first line to working result.

Each module session follows a guided flow:

1. Identify the topic (or provide it in your opening message)
2. Choose the target learner level: Beginner, Intermediate, or Advanced
3. Confirm the module details
4. Receive a fully-generated Markdown module saved to a configurable directory

## Prerequisites

No additional installation is required. The plugin works with the VS Code Chat Plugin Marketplace out of the box.

To customise the output directory, set the `MODULE_DIR` environment variable before starting VS Code:

```sh
# Linux / macOS
export MODULE_DIR="$HOME/work/modules"

# Windows (PowerShell)
$env:MODULE_DIR = "C:\work\modules"
```

The hook reads `MODULE_DIR` at session start and injects it into the agent context as `INSTRUCTOR_MODULE_DIR`. If the variable is not set, modules are saved to `<workspace root>/modules/`.

## Installation

Install via the VS Code Chat Plugin Marketplace using the `dimpletz/prompts-collection` marketplace source and enable the **instructor** plugin.

## Hooks

| Event | Script | What it does |
|-------|--------|--------------|
| `SessionStart` | `inject-module-dir.ps1` / `.sh` | Reads `MODULE_DIR` and injects the value into the agent context as `INSTRUCTOR_MODULE_DIR`. If not set, the agent falls back to `<workspace root>/modules/`. |

## Usage

Open Copilot Chat, select the **Module Maker** agent, and tell it what you want to learn.

| Agent | Invoke when… |
|-------|--------------|
| **Module Maker** | You want a complete learning module — theory, examples, and an end-to-end project — for any topic. Automatically hands off to the Narration Script Writer after saving. |
| **Narration Script Writer** | You want a speaker-ready video narration script for an existing module file. Can be invoked independently or is called automatically by Module Maker. |

## Module Structure

Every generated module contains the following sections:

| Section | Purpose |
|---------|---------|
| **Introduction** | Overview of the topic and who the module is for |
| **Prerequisites** | Knowledge prerequisites and required tools/applications |
| **Module Objectives** | What the learner will be able to do after completing the module |
| **Theory** | Core concepts, principles, and terminology |
| **Practical Applications** | Two to four self-contained, runnable examples |
| **Project** | A single end-to-end project built step-by-step |
| **Summary** | Recap of what was learned and built |
| **Further Learning** | Curated resources for going deeper |

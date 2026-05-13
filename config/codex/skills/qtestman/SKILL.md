---
name: qtestman
description: Use this skill when working with QTestMan testing tool usage or QTestMan Script (QS) syntax. It provides the authoritative syntax reference and usage rules; do not assume any syntax beyond the documented files.
---

# QTestMan

## Overview

This skill guides correct usage of QTestMan and its QTestMan Script (QS) language using the official references in `references/`.

## Environment Assumption

- Treat NAS/SAN/QSANOS test targets as minimal Linux systems with BusyBox installed, so only basic `sh` syntax and BusyBox-provided utilities are available.
- QTestMan runs on a Windows host. You may use Windows PowerShell for more complex testing only when necessary; keep this as a low-priority option and avoid it unless required.

## When To Use

- The user asks about QTestMan tool usage, behavior, or workflows.
- The user asks about QTestMan Script syntax, commands, variables, macros, or examples.
- The user wants scripts or test plans written in QS.

## Workflow

1. Read only the reference files needed for the specific question.
2. Use only syntax, commands, and behaviors explicitly documented there.
3. If a requested feature or syntax is not documented, say it is not specified in the references and ask for clarification or additional documentation.

## Strict Syntax Rules

- Treat the files in `references/` as the sole source of truth.
- Do not infer, extend, or assume syntax or capabilities beyond what the references explicitly state.
- When providing examples, keep them within documented syntax only.

## References Map

Start with the smallest relevant file(s). Avoid loading `QTestMan_full.md` unless the user explicitly asks for the complete document or a cross-section scan.

- `references/overview.md`: High-level overview and I/O Engine.
- `references/qs_basics.md`: QTestMan Script (QS) overview and Test Plan.
- `references/qs_test_script_intro.md`: Test Script introduction.
- `references/commands_intro.md`: Command section introduction.
- `references/qs_macro.md`: Macro syntax.
- `references/qs_variable.md`: Variable syntax.
- `references/qs_control_flow.md`: Control flow (`if`, `repeat`, `break`).
- `references/commands_io.md`: I/O-related commands (`io_*`, `iocomp_nb`, `io_rate`).
- `references/commands_remote_exec.md`: Remote command/transfer/login (`cs`, `exec`, `scp`, `login`, `logout`).
- `references/commands_validation.md`: Data verification/injection (`verify`, `finject`).
- `references/commands_timing_poll.md`: Timing and polling (`delay`, `date`, `wait_until`, `poll`, `poll_boot`, `random`).
- `references/commands_ui.md`: UI interaction (`msgbox*`, `ui_recorder`, `sendkey`).
- `references/commands_flow_control.md`: Run control and reporting (`run`, `stop`, `end`, `fail`, `errstop`, `failstop`, `echo`, `report`, `chart_line`).
- `references/commands_storage_net.md`: Storage/network commands (`disk_*`, `nic_*`, `smb_*`, `nfs_*`, `iscsi_*`, `pd_*`).
- `references/QTestMan_full.md`: Full original document (use only when necessary).

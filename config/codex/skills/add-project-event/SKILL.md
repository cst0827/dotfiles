---
name: add-project-event
description: Add new event definitions and event-trigger wiring for projects that follow the QsanOS layout. Use this skill when a request asks to add event IDs, event.c message formats, multilingual eventlog JSON entries, or module-side event util/hooks in a module under a project root where only the root path may vary.
---

# Add Project Event

## Overview

Use this skill when a module needs new events added to the shared event system and the module code must trigger those events at the correct success path.

The project root may vary, but paths under the project root are fixed. Always resolve the current project root first, then work with fixed relative paths under that root.

## Resolve Project Root

Find the project root by locating all of these fixed paths under the same ancestor:

- `KernelApp/sansoft/common/include/event.h`
- `UserApp/manager/sansoft/event/lib/event.c`
- `UserApp/multilingual/eventlog/ENG.json`

If the current working directory is inside a project tree, walk upward and find the nearest ancestor that contains those paths.

## Required Shared Files

No matter which module needs new events, these files must be updated:

- `<project-root>/KernelApp/sansoft/common/include/event.h`
- `<project-root>/UserApp/manager/sansoft/event/lib/event.c`
- `<project-root>/UserApp/multilingual/eventlog/*.json`

These are the shared event definition files. Module-specific code changes depend on the request.

## JSON Rules

When adding new messages to `UserApp/multilingual/eventlog/*.json`, always follow these rules:

- Insert new entries in the top `New` section.
- Use English strings for every language file first.
- Keep the same keys and same English values across all language JSON files unless the user explicitly asks for translations.

## Module Workflow

1. Resolve the project root.
2. Inspect the target module for existing event helpers or wrappers.
3. Confirm whether the module already has its own event util.
4. If the module has no event util, add one in a suitable module-local file and use `event_logger`.
5. Add new event IDs to `event.h` near the correct module or event family.
6. Add matching message formats to `event.c`.
7. Add matching JSON entries to every file in `UserApp/multilingual/eventlog/`, in the top `New` section, with English strings.
8. Wire event triggering into the requested module functions, usually on the success path unless the request explicitly includes failure events.
9. Verify that event IDs, event names, and parameter counts match across module code, `event.h`, `event.c`, and JSON.

## Event Util Rules

Before adding module hooks, first check whether the module already has a reusable event helper.

Look for patterns like:

- wrapper functions around `event_logger.TriggerEvent(...)`
- module constants for event level or event type
- helper functions such as `<module>Event(...)`, `triggerEvent(...)`, or equivalent

If the module does not have one, add a small helper in an appropriate module-local file. Prefer existing log/helper files if they already centralize module logging.

The helper must use `event_logger`.

Preferred pattern:

```go
import "event_logger"

const (
    EVENT_TYPE    = event_logger.TYPE_SYSTEM
    EVENT_SUBTYPE = ""
)

func moduleEvent(level string, id string, data ...string) {
    if err := event_logger.TriggerEvent(EVENT_TYPE, EVENT_SUBTYPE, level, id, data...); err != nil {
        // log locally with the module's existing logger
    }
}
```

## event.h Placement

Add new event IDs without reusing existing values.

Choose placement by existing event family conventions:

- if the module already has related event IDs, extend that group
- otherwise place the new IDs in the most appropriate existing module section

Keep the naming consistent with the module and action, for example:

- `EVTID_<MODULE>_CREATE`
- `EVTID_<MODULE>_DELETE`
- `EVTID_<MODULE>_UPDATE`

## event.c Rules

Each new `EVTID_*` added to `event.h` must have one matching `event.c` entry with:

- the same event ID symbol
- the same event ID name string
- a short category string
- a message format whose placeholder count matches the triggered parameters exactly

If the message wording is specified by the user, follow that wording exactly.

## Hooking Rules

Add event triggering where the request needs it. Default to success-path hooks unless the request explicitly asks for failure or warning events.

Before triggering:

- confirm the needed event arguments are available
- if needed, add a tiny helper to fetch display names such as VD names
- avoid changing broader control flow just to emit an event

For delete-like flows where the input may point to a target object instead of the source object, inspect current module logic and choose the user-facing object name carefully.

## Verification Checklist

- every new event ID in `event.h` appears in `event.c`
- every new event key appears in all `eventlog/*.json` files
- JSON entries are in the top `New` section
- JSON entries all use English
- module event util exists or was added
- module event util uses `event_logger`
- trigger sites use the correct event ID and parameter count
- no formatting tool is run unless explicitly requested

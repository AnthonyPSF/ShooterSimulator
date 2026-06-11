# Godot AI — AI Agent Reference

> **Version:** 2.7.1  
> **Purpose:** Connect MCP-capable AI assistants (Claude Code, Cursor, Codex, etc.) to a live Godot editor over the Model Context Protocol (MCP).  
> **Transport:** WebSocket (command dispatch) + HTTP (server status/management) — Streamable HTTP transport.  
> **Python server:** Runs as a subprocess spawned by the plugin (`godot-ai` Python package, installed via `uvx` or dev `.venv`).

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────────┐
│  AI Agent (Claude Code / Cursor / Codex / etc.)                 │
│  └─ MCP Client ── HTTP/WS ──► Python MCP Server (godot-ai)     │
│                                  │                               │
│                                  │ WebSocket (port 9500)         │
│                                  ▼                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Godot Editor                                              │  │
│  │  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐  │  │
│  │  │ plugin.gd    │  │ dispatcher.gd│  │ handlers/*.gd    │  │  │
│  │  │ (lifecycle)  │──│ (routes cmds)│──│ (domain logic)   │  │  │
│  │  └─────────────┘  └──────────────┘  └──────────────────┘  │  │
│  │         │                                                    │  │
│  │         ▼                                                    │  │
│  │  ┌─────────────┐  ┌──────────────────────────────────────┐  │  │
│  │  │ connection.gd│  │ debugger/mcp_debugger_plugin.gd      │  │  │
│  │  │ (WebSocket)  │  │ (game-process bridge — framebuffer,  │  │  │
│  │  └─────────────┘  │  eval, commands)                      │  │  │
│  │                   └──────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                          │                                       │
│                          ▼                                       │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Game Process                                              │  │
│  │  ┌──────────────────┐  ┌────────────────────────────────┐ │  │
│  │  │ _mcp_game_helper  │  │ runtime/loggers/game_logger.gd │ │  │
│  │  │ (autoload)        │  │ (captures game-side errors)    │ │  │
│  │  └──────────────────┘  └────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

---

## How It Works (From an AI Agent's Perspective)

1. **Plugin starts** → spawns a Python MCP server subprocess (via `uvx` or dev `.venv`)
2. **Plugin connects** to the server via WebSocket on `ws://127.0.0.1:<ws_port>` (default 9500)
3. **AI agent connects** to the Python server via MCP (HTTP on port 8000 by default)
4. **AI agent sends tool calls** → server forwards them via WebSocket → plugin dispatches to handlers → handlers interact with the Godot Editor API → responses flow back

All **commands** (tool calls) are registered in `plugin.gd:_enter_tree()` via `_dispatcher.register("command_name", handler.method)`. Each handler returns a Dictionary with either `{"data": ...}` on success or `{"error": {...}}` on failure.

---

## Available MCP Tools (Commands)

### Editor & Scene Management

| Command | Handler | Description |
|---------|---------|-------------|
| `get_editor_state` | `editor_handler` | Current Godot version, project name, scene path, play state, readiness |
| `get_scene_tree` | `scene_handler` | Full scene hierarchy with node types, paths, child counts |
| `get_open_scenes` | `scene_handler` | List of all open scene paths + current scene |
| `find_nodes` | `scene_handler` | Search nodes by name, type, or group |
| `create_scene` | `scene_handler` | Create new scene with root node type, save to disk |
| `open_scene` | `scene_handler` | Open an existing scene by path |
| `save_scene` | `scene_handler` | Save current scene |
| `save_scene_as` | `scene_handler` | Save current scene to new path |
| `get_selection` | `editor_handler` | Currently selected node paths |
| `take_screenshot` | `editor_handler` | Capture viewport/game/cinematic screenshots (returns base64 PNG) |
| `get_performance_monitors` | `editor_handler` | FPS, memory, draw calls, physics stats |
| `get_logs` | `editor_handler` | Read logs: `source="plugin"`, `"game"`, `"editor"`, or `"all"` |
| `clear_logs` | `editor_handler` | Clear plugin logs; optionally clear Debugger Errors tab |
| `reload_plugin` | `editor_handler` | Disable/re-enable the Godot AI plugin |
| `quit_editor` | `editor_handler` | Quit the Godot editor |

### Node Operations (Undo/Redo Supported)

| Command | Handler | Description |
|---------|---------|-------------|
| `create_node` | `node_handler` | Create node by type (`type="Node3D"`) or instance scene (`scene_path`) |
| `delete_node` | `node_handler` | Delete a node from the scene |
| `reparent_node` | `node_handler` | Move node to a new parent |
| `set_property` | `node_handler` | Set any property on a node (supports Vector2/3, Color, resources, etc.) |
| `rename_node` | `node_handler` | Rename a node (cannot rename scene root) |
| `duplicate_node` | `node_handler` | Duplicate a node with optional new name |
| `move_node` | `node_handler` | Reorder node among siblings |
| `add_to_group` | `node_handler` | Add node to a group |
| `remove_from_group` | `node_handler` | Remove node from a group |
| `set_selection` | `node_handler` | Set editor selection by node paths |
| `get_node_properties` | `node_handler` | List all editor-visible properties of a node |
| `get_children` | `node_handler` | List children of a node |
| `get_groups` | `node_handler` | List groups a node belongs to |

### Project & Filesystem

| Command | Handler | Description |
|---------|---------|-------------|
| `get_project_setting` | `project_handler` | Read a project setting |
| `set_project_setting` | `project_handler` | Write a project setting |
| `run_project` | `project_handler` | Run the game |
| `stop_project` | `project_handler` | Stop the running game |
| `search_filesystem` | `project_handler` | Search project files by pattern |
| `read_file` | `filesystem_handler` | Read a file's contents |
| `write_file` | `filesystem_handler` | Write/create a file |
| `reimport` | `filesystem_handler` | Reimport a resource file |

### Scripts & Resources

| Command | Handler | Description |
|---------|---------|-------------|
| `create_script` | `script_handler` | Create a new GDScript file |
| `patch_script` | `script_handler` | Apply text patches to scripts |
| `read_script` | `script_handler` | Read script source code |
| `attach_script` | `script_handler` | Attach a script to a node |
| `detach_script` | `script_handler` | Detach script from a node |
| `find_symbols` | `script_handler` | Search for class names, functions, variables |
| `search_resources` | `resource_handler` | Search for resources by type/name |
| `load_resource` | `resource_handler` | Load a resource by path |
| `assign_resource` | `resource_handler` | Assign resource to a node's property |
| `create_resource` | `resource_handler` | Create new resource (e.g., `{"__class__": "BoxMesh", "size": {...}}`) |
| `get_resource_info` | `resource_handler` | Get resource metadata |

### Materials, Particles, Animation, Camera, Audio

These follow a consistent pattern of `create`, `set_*`, `get`, `list`, `apply_preset`, `delete`:

| Domain | Commands |
|--------|----------|
| **Material** | `material_create`, `material_set_param`, `material_set_shader_param`, `material_get`, `material_list`, `material_assign`, `material_apply_to_node`, `material_apply_preset` |
| **Particle** | `particle_create`, `particle_set_main`, `particle_set_process`, `particle_set_draw_pass`, `particle_restart`, `particle_get`, `particle_apply_preset` |
| **Animation** | `animation_player_create`, `animation_create`, `animation_add_property_track`, `animation_add_method_track`, `animation_set_autoplay`, `animation_play`, `animation_stop`, `animation_list`, `animation_get`, `animation_create_simple`, `animation_delete`, `animation_validate`, `animation_preset_fade`, `animation_preset_slide`, `animation_preset_shake`, `animation_preset_pulse` |
| **Camera** | `camera_create`, `camera_configure`, `camera_set_limits_2d`, `camera_set_damping_2d`, `camera_follow_2d`, `camera_get`, `camera_list`, `camera_apply_preset` |
| **Audio** | `audio_player_create`, `audio_player_set_stream`, `audio_player_set_playback`, `audio_play`, `audio_stop`, `audio_list` |

### UI, Theme, Signals, Input

| Command | Handler | Description |
|---------|---------|-------------|
| `set_anchor_preset` | `ui_handler` | Set Control anchor presets |
| `set_text` | `ui_handler` | Set text on Label/RichTextLabel/Button/etc. |
| `build_layout` | `ui_handler` | Build a UI layout from JSON description |
| `create_theme` | `theme_handler` | Create a new Theme resource |
| `theme_set_color` | `theme_handler` | Set theme color |
| `theme_set_constant` | `theme_handler` | Set theme constant |
| `theme_set_font_size` | `theme_handler` | Set theme font size |
| `theme_set_stylebox_flat` | `theme_handler` | Set flat stylebox |
| `apply_theme` | `theme_handler` | Apply theme to a Control node |
| `list_signals` | `signal_handler` | List signals of a node |
| `connect_signal` | `signal_handler` | Connect a signal to a method |
| `disconnect_signal` | `signal_handler` | Disconnect a signal |
| `list_actions` | `input_handler` | List InputMap actions |
| `add_action` | `input_handler` | Add a new input action |
| `remove_action` | `input_handler` | Remove an input action |
| `bind_event` | `input_handler` | Bind a key/button to an action |

### Game Interaction (Deferred — requires running game)

| Command | Handler | Description |
|---------|---------|-------------|
| `game_eval` | `editor_handler` | Execute GDScript expression in the running game process |
| `game_command` | `editor_handler` | Send commands to the running game (framebuffer capture, etc.) |

### Other

| Command | Handler | Description |
|---------|---------|-------------|
| `physics_shape_autofit` | `physics_shape_handler` | Auto-fit CollisionShape to mesh |
| `environment_create` | `environment_handler` | Create WorldEnvironment node with Environment resource |
| `gradient_texture_create` | `texture_handler` | Create GradientTexture1D/2D |
| `noise_texture_create` | `texture_handler` | Create NoiseTexture2D/3D |
| `curve_set_points` | `curve_handler` | Set points on a Curve resource |
| `control_draw_recipe` | `control_draw_recipe_handler` | Draw decorative elements on Control nodes |
| `list_autoloads` | `autoload_handler` | List project autoloads |
| `add_autoload` | `autoload_handler` | Add an autoload |
| `remove_autoload` | `autoload_handler` | Remove an autoload |
| `run_tests` | `test_handler` | Run GUT tests |
| `get_test_results` | `test_handler` | Get test results |
| `batch_execute` | `batch_handler` | Execute multiple commands in a single request |
| `configure_client` | `client_handler` | Configure an MCP client |
| `remove_client` | `client_handler` | Remove MCP client configuration |
| `check_client_status` | `client_handler` | Check if MCP client is configured |

---

## Key Concepts for AI Agents

### 1. Editor Readiness

The editor has four readiness states, returned in every response envelope as `readiness`:
- **`ready`** — Scene is open, not playing, not importing. Writes are safe.
- **`playing`** — Game is running. Most write tools will fail.
- **`importing`** — Filesystem is scanning. Writes may race with import.
- **`no_scene`** — No scene is open. Most operations require a scene.

**Always check `readiness`** before attempting writes. If it's not `ready`, explain to the user and wait.

### 2. Node Paths

All node paths are relative to the scene root using Godot's `NodePath` syntax:
- `"."` — Scene root
- `"Player"` — Direct child named "Player"
- `"Player/Camera3D"` — Nested path
- Always use paths returned by `get_scene_tree` or `find_nodes` — don't guess.

### 3. Property Set Patterns

When setting properties via `set_property`:

**Simple types** — send native JSON values:
```json
{"path": "Player", "property": "position", "value": {"x": 0, "y": 0, "z": 0}}
```

**Colors** — send hex string or dict:
```json
{"path": "Light", "property": "light_color", "value": "#ff4444"}
{"path": "Light", "property": "light_color", "value": {"r": 1.0, "g": 0.3, "b": 0.3, "a": 1.0}}
```

**Resources** — send a path or inline `{"__class__": "..."}`:
```json
{"path": "Mesh", "property": "mesh", "value": "res://assets/cube.tres"}
{"path": "Mesh", "property": "mesh", "value": {"__class__": "BoxMesh", "size": {"x": 2, "y": 1, "z": 2}}}
```

**Clearing a resource** — send empty string:
```json
{"path": "Mesh", "property": "material_override", "value": ""}
```

### 4. Scene Management

- Use `get_scene_tree` to inspect hierarchy before making changes
- `create_scene` takes `root_type` (e.g., `"Node3D"`, `"Node2D"`, `"Control"`), `path`, and optional `root_name`
- `create_node` takes `type` (ClassDB name) or `scene_path` (to instance a subscene), `parent_path`, and optional `name`
- Most node operations support undo/redo (return `"undoable": true`)

### 5. Taking Screenshots

Three screenshot sources:
- **`viewport`** — Captures the 3D editor viewport (use `view_target` to frame specific nodes)
- **`cinematic`** — Renders through the scene's active Camera3D (no gizmos, clean output)
- **`game`** — Captures the running game's framebuffer (requires game to be running)

The `coverage=true` parameter returns multiple angles of the target automatically.

### 6. Reading Logs

```json
{"source": "plugin", "count": 50, "offset": 0}
{"source": "game", "count": 50, "offset": 0}
{"source": "editor", "count": 50, "offset": 0, "include_details": true}
{"source": "all"}
```

- **plugin** — WebSocket recv/send traffic (most useful for debugging tool calls)
- **game** — Runtime errors from the game process
- **editor** — Editor script errors, parse errors, push_error calls (requires Godot 4.5+)

### 7. Running Game Commands

`game_eval` executes GDScript in the running game and returns the result:
```json
{"code": "get_tree().current_scene.name"}
```

These return a **deferred response** — the dispatcher registers a timeout and the game process sends the result back asynchronously.

### 8. Batch Execution

Send multiple commands in one request:
```json
{
  "commands": [
    {"command": "create_node", "params": {...}},
    {"command": "set_property", "params": {...}},
    {"command": "create_node", "params": {...}}
  ]
}
```

Results are returned in the same order. Unknown commands get suggestions of similar names.

---

## Response Format

Every command response has this structure:

```json
{
  "request_id": "...",
  "status": "ok",
  "data": { ... },
  "readiness": "ready"
}
```

Error responses:
```json
{
  "request_id": "...",
  "status": "error",
  "error": {
    "code": "NODE_NOT_FOUND",
    "message": "Node not found at path 'Foo' under root 'Node3D'",
    "data": {}
  },
  "readiness": "ready"
}
```

**Common error codes:** `MISSING_REQUIRED_PARAM`, `NODE_NOT_FOUND`, `RESOURCE_NOT_FOUND`, `PROPERTY_NOT_ON_CLASS`, `WRONG_TYPE`, `VALUE_OUT_OF_RANGE`, `INVALID_PARAMS`, `EDITOR_NOT_READY`, `INTERNAL_ERROR`, `UNKNOWN_COMMAND`.

---

## Client Configuration

Supported MCP clients (in `clients/`):

| Client ID | Display Name | Config Type |
|-----------|-------------|-------------|
| `claude_code` | Claude Code | CLI (JSON fallback) |
| `claude_desktop` | Claude Desktop | JSON (uvx bridge) |
| `cursor` | Cursor | JSON |
| `vscode` | VS Code | JSON |
| `vscode_insiders` | VS Code Insiders | JSON |
| `codex` | Codex (OpenAI) | TOML |
| `antigravity` | Antigravity | JSON |
| `windsurf` | Windsurf | JSON |
| `cline` | Cline (VS Code ext) | JSON |
| `roo_code` | Roo Code | JSON |
| `kilo_code` | Kilo Code | JSON |
| `kimi_code` | Kimi Code | JSON |
| `qwen_code` | Qwen Code | JSON |
| `opencode` | OpenCode | JSON |
| `gemini_cli` | Gemini CLI | CLI |
| `kiro` | Kiro | JSON |
| `cherry_studio` | Cherry Studio | JSON |
| `trae` | Trae | JSON |
| `zed` | Zed | JSON |

---

## Server Lifecycle

The plugin manages a Python server process with these states:
- **SPAWNING** — Server is being started
- **READY** — Server is running and compatible
- **CRASHED** — Server process exited unexpectedly
- **FOREIGN_PORT** — Another process is on the port (may be a compatible server from another editor session)
- **INCOMPATIBLE_SERVER** — A server is running but version doesn't match

The server tier is auto-detected:
1. **Dev venv** — `.venv/bin/python -m godot_ai` (when `src/godot_ai/` exists nearby)
2. **uvx** — `uvx --from godot-ai==<version> godot-ai` (user install, version-pinned)
3. **System** — `godot-ai` on PATH (pip/pipx install)

---

## Key Files Reference

| File | Role |
|------|------|
| `addons/godot_ai/plugin.gd` | EditorPlugin entry point — lifecycle, handler registration, server management |
| `addons/godot_ai/plugin.cfg` | Plugin metadata (version 2.7.1, Godot 4.3+) |
| `addons/godot_ai/dispatcher.gd` | Routes MCP commands to handlers, manages command queue per frame budget |
| `addons/godot_ai/connection.gd` | WebSocket transport — connect, reconnect, send, receive, backpressure |
| `addons/godot_ai/client_configurator.gd` | Client configure/remove/status, server command discovery, port management |
| `addons/godot_ai/tool_catalog.gd` | Tool domain definitions (mirrors Python-side `domains.py`) |
| `addons/godot_ai/telemetry.gd` | Anonymous usage telemetry |
| `addons/godot_ai/mcp_dock.gd` | Editor dock panel UI |
| `addons/godot_ai/handlers/` | Domain handlers (one per tool category) |
| `addons/godot_ai/clients/` | MCP client descriptors (data-only, no Callables) |
| `addons/godot_ai/utils/error_codes.gd` | Error code constants |
| `addons/godot_ai/utils/settings.gd` | EditorSettings keys |
| `addons/godot_ai/utils/log_buffer.gd` | Ring buffer for plugin logs |
| `addons/godot_ai/utils/scene_path.gd` | NodePath resolution and formatting |
| `addons/godot_ai/utils/path_validator.gd` | File path validation (`res://` checks) |
| `addons/godot_ai/utils/node_validator.gd` | Node resolution and validation |
| `addons/godot_ai/utils/port_resolver.gd` | Port discovery, PID management |
| `addons/godot_ai/utils/server_lifecycle.gd` | Server state machine, spawn/stop/adopt |
| `addons/godot_ai/runtime/game_helper.gd` | Autoload in game process — handles framebuffer capture, eval, commands |
| `addons/godot_ai/runtime/loggers/` | Game and editor loggers (Godot 4.5+ Logger subclass) |
| `addons/godot_ai/debugger/mcp_debugger_plugin.gd` | Editor↔Game bridge via EngineDebugger messages |

---

## Requirements

- **Godot 4.3+** (4.4+ recommended; editor log capture requires 4.5+)
- **[uv](https://docs.astral.sh/uv/)** — Python package manager (used to install/run the MCP server)
- An **MCP client** (Claude Code, Cursor, VS Code, Codex, etc.)

---

## Project-Specific Notes (GardenWay)

When working on this Godot project, remember:
- The `addons/godot_ai/` directory is the full plugin source — do NOT edit it unless intentionally modifying the plugin
- The plugin auto-starts when the editor opens (through Project Settings > Plugins)
- All MCP tool calls go through the Python server → WebSocket → dispatcher → handler chain
- Undo/redo is supported for most node operations — the AI should mention this to the user
- Changes made via MCP tools are applied directly to the open editor scene — the user sees them immediately

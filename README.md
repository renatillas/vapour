# Vapour

Type-safe Gleam bindings for [steamworks-ffi-node](https://github.com/ArtyProf/steamworks-ffi-node) - bringing Steam platform features to your Gleam applications.

## Features

Vapour provides 1:1 bindings to the steamworks-ffi-node library with type-safe Gleam wrappers for:

- **Core API** - Initialization and lifecycle management
- **Achievements** - Unlock, check, and manage Steam achievements
- **Local Player** - Get player name and set Rich Presence
- **Cloud** - Save files to Steam Cloud and sync across devices
- **Overlay** - Control the Steam overlay and open dialogs

## Installation

Add vapour to your `gleam.toml`:

```toml
[dependencies]
vapour = { git = "https://github.com/renatillas/vapour.git", tag = "v0.1.0" }
```

Add the steamworks-ffi-node dependency to your `package.json`:

```json
{
  "dependencies": {
    "steamworks-ffi-node": "^0.5.3"
  }
}
```

## Quick Start

```gleam
import gleam/io
import gleam/option
import vapour
import vapour/localplayer
import vapour/achievement

pub fn main() {
  // Initialize with your Steam app ID
  let assert Ok(client) = vapour.init(option.Some(480))

  // Run callbacks regularly (e.g., each frame)
  vapour.run_callbacks(client)

  // Get player info
  let name = localplayer.get_name(client)
  io.println("Hello, " <> name <> "!")

  // Unlock an achievement
  case achievement.activate(client, "MY_ACHIEVEMENT") {
    True -> io.println("Achievement unlocked!")
    False -> io.println("Failed to unlock achievement")
  }
}
```

## Architecture

Vapour follows Tiramisu's layered FFI architecture:

```
┌─────────────────────────────────────┐
│   Your Gleam Game Logic             │
├─────────────────────────────────────┤
│   Vapour Gleam Modules              │  ← Type-safe wrappers
│   (achievement, localplayer, etc.)  │
├─────────────────────────────────────┤
│   steamworks.ffi.mjs                │  ← Pure 1:1 bindings
│   (No logic, just thin wrappers)   │
├─────────────────────────────────────┤
│   steamworks-ffi-node Library       │  ← Native Steam API
└─────────────────────────────────────┘
```

### Design Principles

- **Pure FFI Layer**: `steamworks.ffi.mjs` contains only 1:1 bindings to steamworks-ffi-node
- **Type-Safe Wrappers**: Gleam modules provide validation and ergonomic APIs
- **Opaque Types**: Internal Steam objects are wrapped in opaque Gleam types
- **No Business Logic in FFI**: All logic lives in Gleam for testability

## API Modules

### Core (`vapour`)

Initialize and manage the Steamworks connection:

```gleam
import vapour
import gleam/option

// Initialize with app ID
let assert Ok(client) = vapour.init(option.Some(480))

// Or read from steam_appid.txt
let assert Ok(client) = vapour.init(option.None)

// Run callbacks each frame
vapour.run_callbacks(client)
```

### Achievement (`vapour/achievement`)

Manage Steam achievements:

```gleam
import vapour
import vapour/achievement
import gleam/option

let assert Ok(client) = vapour.init(option.Some(480))

// Unlock an achievement
achievement.activate(client, "WIN_GAME")

// Check if unlocked
let unlocked = achievement.is_activated(client, "WIN_GAME")

// Get all achievement names
let all_achievements = achievement.names(client)
```

### Local Player (`vapour/localplayer`)

Access local player information:

```gleam
import vapour
import vapour/localplayer
import gleam/option

let assert Ok(client) = vapour.init(option.Some(480))

// Get player name
let name = localplayer.get_name(client)

// Set Rich Presence
localplayer.set_rich_presence(client, "status", option.Some("In Menu"))

// Clear Rich Presence
localplayer.set_rich_presence(client, "status", option.None)
```

### Overlay (`vapour/overlay`)

Control the Steam overlay:

```gleam
import vapour
import vapour/overlay
import gleam/option

let assert Ok(client) = vapour.init(option.Some(480))

// Show achievements
overlay.activate_dialog(client, "Achievements")

// Show friends list
overlay.activate_dialog(client, "Friends")

// Open user profile
overlay.activate_dialog_to_user(client, "steamid", "76561197960287930")

// Open web page
overlay.activate_web_page(client, "https://example.com")

// Open store page for DLC
overlay.activate_store(client, 12345)
```

### Cloud (`vapour/cloud`)

Save files to Steam Cloud:

```gleam
import vapour
import vapour/cloud
import gleam/option

let assert Ok(client) = vapour.init(option.Some(480))

// Write a save file
cloud.write_file(client, "save.json", "{\"level\": 5}")

// Read a save file
let save_data = cloud.read_file(client, "save.json")

// Check if file exists
let has_save = cloud.file_exists(client, "save.json")

// List all files
let files = cloud.list_files(client)

// Delete a file
cloud.delete_file(client, "save.json")
```

## Running the Example

The `examples` directory contains a demo project showcasing all features:

```bash
cd examples
gleam build
gleam run
```

**Note**: You'll need Steam running and the Spacewar app (AppID 480) to test. Spacewar is Steam's free test application available to all developers.

The example demonstrates:
- Initializing the Steam client
- Getting player information
- Setting/clearing Rich Presence
- Listing achievements
- Reading/writing to Steam Cloud
- Overlay functionality (commented out by default)

## Requirements

- Gleam >= 1.0.0
- Node.js >= 18.0.0 (for JavaScript target)
- Steam running on your machine
- steamworks-ffi-node ^0.5.3

## Development

```bash
# Build the library
gleam build

# Run tests
gleam test

# Format code
gleam format

# Build and run example
cd examples
gleam build
gleam run
```

## Future Modules

Vapour currently implements the APIs available in steamworks-ffi-node. Future additions as steamworks-ffi-node expands may include:

- **Stats** - User statistics and leaderboards
- **Friends** - Friends list and social features
- **Input** - Steam Input (controllers)
- **Matchmaking** - Lobby and matchmaking
- **Networking** - P2P networking
- **Workshop** - Steam Workshop integration

## License

MIT License - see [LICENSE](LICENSE) file for details.

Vapour uses the same MIT license as its underlying dependency [steamworks-ffi-node](https://github.com/ArtyProf/steamworks-ffi-node).

**Note**: While Vapour and steamworks-ffi-node are MIT licensed, using the Steamworks SDK requires compliance with the [Steamworks SDK License Agreement](https://partner.steamgames.com/doc/sdk/api). You must be a registered Steam developer to use the Steamworks API in production.

## Credits

- Built with [Gleam](https://gleam.run)
- Bindings for [steamworks-ffi-node](https://github.com/ArtyProf/steamworks-ffi-node)
- Inspired by [Tiramisu](https://github.com/renatillas/tiramisu) game engine architecture

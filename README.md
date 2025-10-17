# Vapour

Type-safe Gleam bindings for [Steamworks.js](https://github.com/ceifa/steamworks.js) - bringing Steam platform features to your Gleam applications.

## Features

Vapour provides 1:1 bindings to the Steamworks.js library with type-safe Gleam wrappers for:

- **Core API** - Initialization and lifecycle management
- **Achievements** - Unlock, check, and manage Steam achievements
- **Local Player** - Get player information (name, level, country, Steam ID)
- **Apps** - Query app and DLC installation, subscription status
- **Cloud** - Save files to Steam Cloud and sync across devices

## Installation

Add vapour to your `gleam.toml`:

```toml
[dependencies]
vapour = { git = "https://github.com/renatillas/vapour.git", tag = "v0.1.0" }
```

Add the steamworks.js dependency to your `package.json`:

```json
{
  "dependencies": {
    "steamworks.js": "^0.4.0"
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
  // Check if we need to restart through Steam
  case vapour.restart_app_if_necessary(480) {
    True -> io.println("Restarting through Steam...")
    False -> {
      // Initialize with your Steam app ID
      let assert Ok(_client) = vapour.init(option.Some(480))

      // Run callbacks regularly (e.g., each frame)
      vapour.run_callbacks()

      // Get player info
      let name = localplayer.get_name()
      io.println("Hello, " <> name <> "!")

      // Unlock an achievement
      case achievement.activate("MY_ACHIEVEMENT") {
        True -> io.println("Achievement unlocked!")
        False -> io.println("Failed to unlock achievement")
      }
    }
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
│   Steamworks.js Library             │  ← Native Steam API
└─────────────────────────────────────┘
```

### Design Principles

- **Pure FFI Layer**: `steamworks.ffi.mjs` contains only 1:1 bindings to Steamworks.js
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
vapour.run_callbacks()
```

### Achievement (`vapour/achievement`)

Manage Steam achievements:

```gleam
import vapour/achievement

// Unlock an achievement
achievement.activate("WIN_GAME")

// Check if unlocked
let unlocked = achievement.is_activated("WIN_GAME")

// Get all achievement names
let all_achievements = achievement.names()
```

### Local Player (`vapour/localplayer`)

Access local player information:

```gleam
import vapour/localplayer

// Get player name
let name = localplayer.get_name()

// Get Steam ID
let steam_id = localplayer.get_steam_id()
io.println("Steam ID 64: " <> steam_id.steam_id_64)

// Get player level
let level = localplayer.get_level()

// Set Rich Presence
localplayer.set_rich_presence("status", option.Some("In Menu"))
```

### Apps (`vapour/apps`)

Query app and DLC information:

```gleam
import vapour/apps

// Check if user owns this app
let subscribed = apps.is_subscribed()

// Check DLC installation
let has_dlc = apps.is_dlc_installed(480)

// Get current language
let language = apps.current_game_language()

// Get app owner (detects Family Sharing)
let owner = apps.app_owner()
```

### Cloud (`vapour/cloud`)

Save files to Steam Cloud:

```gleam
import vapour/cloud

// Write a save file
cloud.write_file("save.json", "{\"level\": 5}")

// Read a save file
let save_data = cloud.read_file("save.json")

// Check if file exists
let has_save = cloud.file_exists("save.json")

// List all files
let files = cloud.list_files()

// Delete a file
cloud.delete_file("save.json")
```

## Running the Example

The `vapour_example` project demonstrates all features:

```bash
cd vapour_example
gleam build
gleam run
```

**Note**: You'll need Steam running and the Spacewar app (AppID 480) to test. Spacewar is Steam's free test application available to all developers.

## Requirements

- Gleam >= 1.0.0
- Node.js (for JavaScript target)
- Steam running on your machine
- steamworks.js ^0.4.0

## Development

```bash
# Build the library
gleam build

# Run tests
gleam test

# Format code
gleam format

# Build and run example
cd vapour_example
gleam build
gleam run
```

## Future Modules

Vapour currently implements the most commonly used Steam APIs. Future additions may include:

- **Input** - Steam Input (controllers)
- **Matchmaking** - Lobby and matchmaking
- **Networking** - P2P networking
- **Overlay** - Steam overlay control
- **Workshop** - Steam Workshop integration

## License

MIT

## Credits

- Built with [Gleam](https://gleam.run)
- Bindings for [Steamworks.js](https://github.com/ceifa/steamworks.js)
- Inspired by [Tiramisu](https://github.com/renatillas/tiramisu) game engine architecture

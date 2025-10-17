# Vapour

Type-safe Gleam bindings for the [Steamworks SDK](https://partner.steamgames.com/doc/sdk/api) via [steamworks-ffi-node](https://github.com/ArtyProf/steamworks-ffi-node).

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- **Core API** - Initialize Steamworks, manage callbacks, check connection status
- **Achievements** - Unlock/lock achievements, list all achievements (async with Promises)
- **Cloud Storage** - Save/load files to Steam Cloud, manage cloud settings
- **Rich Presence** - Set player status visible to friends
- **Overlay** - Open Steam overlay dialogs (friends, achievements, store, web pages)
- **Stats** - Track player statistics, get/set int and float stats, global stats, user stats, average rate stats (async with Promises)
- **Friends** - Get friends list, check online status, view friend info, relationship status, coplay features
- **Leaderboards** - Find leaderboards, upload scores, download entries (async with Promises)

## Installation

Add to your `gleam.toml`:

```toml
[dependencies]
vapour = { git = "https://github.com/renatillas/vapour.git", tag = "v0.1.0" }
gleam_javascript = "~> 1.0"
```

Add to your `package.json`:

```json
{
  "dependencies": {
    "steamworks-ffi-node": "^0.5.3"
  }
}
```

## Quick Start

```gleam
import gleam/javascript/promise
import gleam/option
import vapour

pub fn main() {
  // Initialize with your Steam App ID (or use 480 for testing with Spacewar)
  let assert Ok(client) = vapour.init(option.Some(480))

  // Run callbacks regularly to keep the connection alive
  vapour.run_callbacks(client)

  // Get player name
  let name = vapour.display_name(client)
  io.println("Welcome, " <> name <> "!")

  // Set rich presence
  vapour.set_rich_presence(client, "status", "In Main Menu")

  // Save to cloud
  case vapour.write_file(client, "save.dat", "game data") {
    True -> io.println("Saved to cloud!")
    False -> io.println("Failed to save")
  }

  // Unlock achievement (async)
  vapour.unlock_achievement(client, "ACH_WIN_ONE_GAME")
  |> promise.await(fn(success) {
    case success {
      True -> io.println("Achievement unlocked!")
      False -> io.println("Failed to unlock")
    }
    promise.resolve(Nil)
  })
}
```

## Key Concepts

### Callbacks
Call `vapour.run_callbacks(client)` regularly (every frame or every 100ms) to process Steam events.

### Achievements are Async
Achievement functions return Promises. Use `gleam/javascript/promise` to handle them:

```gleam
use success <- promise.await(vapour.unlock_achievement(client, "MY_ACHIEVEMENT"))
io.println("Result: " <> bool.to_string(success))
promise.resolve(Nil)
```

### Cloud Storage
Steam Cloud must be enabled for your app and the user's account. Check with:

```gleam
let enabled = vapour.is_cloud_enabled_for_account(client)
```

## Documentation

All functions are fully documented with examples. Use your editor's autocomplete or see the [source code](./src/vapour.gleam) for detailed documentation.

## Example Project

See the [`examples`](./examples) directory for a complete demo that tests all functionality:

```bash
cd examples
gleam build
gleam run
```

**Note**: You need Steam running and the Spacewar app (AppID 480) for testing.

## Requirements

- Gleam >= 1.0.0
- Node.js >= 18.0.0
- Steam running on your machine
- steamworks-ffi-node ^0.5.3

## API Coverage

Currently implemented (from steamworks-ffi-node):

| Feature | Functions | Status |
|---------|-----------|--------|
| Core API | 5 | ✅ Complete |
| Achievements | 4 | ✅ Complete |
| Cloud Storage | 7 | ✅ Complete |
| Rich Presence | 3 | ✅ Complete |
| Overlay | 4 | ✅ Complete |
| Stats | 12 | ✅ Complete |
| Friends | 13 | ✅ Complete |
| Leaderboards | 4 | ✅ Complete |

**Total: 52 functions** across 8 feature areas!

## License

MIT License - see [LICENSE](./LICENSE) for details.

**Important**: While Vapour is MIT licensed, using the Steamworks SDK requires compliance with the [Steamworks SDK License Agreement](https://partner.steamgames.com/doc/sdk/api). You must be a registered Steam developer to use Steamworks in production.

## Credits

- Built with [Gleam](https://gleam.run)
- Bindings for [steamworks-ffi-node](https://github.com/ArtyProf/steamworks-ffi-node) by Artur Khutak
- Inspired by [Tiramisu](https://github.com/renatillas/tiramisu) architecture

---

Made with ✨ by [Renata Amutio](https://github.com/renatillas)

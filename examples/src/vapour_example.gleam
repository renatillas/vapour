import gleam/io
import gleam/int
import gleam/option
import vapour
import vapour/achievement
import vapour/localplayer
import vapour/apps
import vapour/cloud

pub fn main() -> Nil {
  io.println("=== Vapour - Steamworks.js Example ===\n")

  // Check if we need to restart through Steam
  case vapour.restart_app_if_necessary(480) {
    True -> {
      io.println("App not launched through Steam, restarting...")
      Nil
    }
    False -> {
      io.println("✓ App launched through Steam\n")

      // Initialize Steamworks with Spacewar (480) - Steam's test app
      let assert Ok(_client) = vapour.init(option.Some(480))
      io.println("✓ Steamworks initialized\n")

      // Run callbacks once
      vapour.run_callbacks()

      // Demonstrate local player API
      demo_localplayer()

      // Demonstrate apps API
      demo_apps()

      // Demonstrate achievement API
      demo_achievements()

      // Demonstrate cloud API
      demo_cloud()

      io.println("\n=== Demo Complete ===")
    }
  }
}

fn demo_localplayer() -> Nil {
  io.println("--- Local Player ---")

  let name = localplayer.get_name()
  io.println("Player name: " <> name)

  let level = localplayer.get_level()
  io.println("Steam level: " <> int.to_string(level))

  let country = localplayer.get_ip_country()
  io.println("Country: " <> country)

  let steam_id = localplayer.get_steam_id()
  io.println("Steam ID 64: " <> steam_id.steam_id_64)
  io.println("Steam ID 32: " <> steam_id.steam_id_32)
  io.println("Account ID: " <> int.to_string(steam_id.account_id))

  // Set rich presence
  localplayer.set_rich_presence("status", option.Some("Testing Vapour"))
  io.println("✓ Rich presence set\n")
}

fn demo_apps() -> Nil {
  io.println("--- Apps ---")

  let subscribed = apps.is_subscribed()
  io.println("Subscribed to app: " <> bool_to_string(subscribed))

  let language = apps.current_game_language()
  io.println("Current language: " <> language)

  let build_id = apps.app_build_id()
  io.println("Build ID: " <> int.to_string(build_id))

  case apps.current_beta_name() {
    option.Some(beta) -> io.println("Beta branch: " <> beta)
    option.None -> io.println("Not in beta branch")
  }

  io.println("")
}

fn demo_achievements() -> Nil {
  io.println("--- Achievements ---")

  let achievement_list = achievement.names()
  io.println(
    "Total achievements: " <> int.to_string(list_length(achievement_list)),
  )

  // Check if a specific achievement is activated
  // Note: Replace with actual achievement IDs from your app
  case achievement_list {
    [first, ..] -> {
      io.println("Checking achievement: " <> first)
      let activated = achievement.is_activated(first)
      io.println("Activated: " <> bool_to_string(activated))
    }
    [] -> io.println("No achievements configured")
  }

  io.println("")
}

fn demo_cloud() -> Nil {
  io.println("--- Cloud ---")

  let enabled_account = cloud.is_enabled_for_account()
  io.println("Cloud enabled for account: " <> bool_to_string(enabled_account))

  let enabled_app = cloud.is_enabled_for_app()
  io.println("Cloud enabled for app: " <> bool_to_string(enabled_app))

  // Try to write and read a test file
  let test_file = "vapour_test.txt"
  let test_content = "Hello from Vapour!"

  case cloud.write_file(test_file, test_content) {
    True -> {
      io.println("✓ Test file written to cloud")

      case cloud.file_exists(test_file) {
        True -> {
          let content = cloud.read_file(test_file)
          io.println("✓ Test file read from cloud: " <> content)

          // Clean up
          case cloud.delete_file(test_file) {
            True -> io.println("✓ Test file deleted from cloud")
            False -> io.println("✗ Failed to delete test file")
          }
        }
        False -> io.println("✗ Test file not found in cloud")
      }
    }
    False -> io.println("✗ Failed to write test file")
  }

  // List all cloud files
  let files = cloud.list_files()
  io.println("Total cloud files: " <> int.to_string(list_length(files)))

  io.println("")
}

fn bool_to_string(value: Bool) -> String {
  case value {
    True -> "true"
    False -> "false"
  }
}

fn list_length(list: List(a)) -> Int {
  case list {
    [] -> 0
    [_, ..rest] -> 1 + list_length(rest)
  }
}

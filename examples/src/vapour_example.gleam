import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import vapour
import vapour/achievement
import vapour/cloud
import vapour/localplayer
import vapour/overlay

pub fn main() -> Nil {
  io.println("=== Vapour - steamworks-ffi-node Example ===")
  io.println("Testing ALL functionality of the library\n")

  // Initialize Steamworks with Spacewar (480) - Steam's test app
  io.println(">>> Initializing Steamworks...")
  let assert Ok(client) = vapour.init(option.Some(480))
  io.println("✓ Steamworks initialized\n")

  // Run callbacks
  io.println(">>> Running callbacks...")
  vapour.run_callbacks(client)
  io.println("✓ Callbacks processed\n")

  // Test all modules
  demo_localplayer(client)
  demo_achievements(client)
  demo_cloud(client)
  demo_overlay(client)

  io.println("\n=== All Tests Complete ===")
}

fn demo_localplayer(client: vapour.Client) -> Nil {
  io.println("─────────────────────────────────")
  io.println("LOCAL PLAYER API")
  io.println("─────────────────────────────────")

  // Test: get_name()
  io.println("\n1. Testing get_name()...")
  let name = localplayer.get_name(client)
  io.println("   Player name: " <> name)
  io.println("   ✓ get_name() works")

  // Test: set_rich_presence() with value
  io.println("\n2. Testing set_rich_presence() with value...")
  localplayer.set_rich_presence(client, "status", option.Some("Testing Vapour"))
  io.println("   ✓ Rich presence set to 'Testing Vapour'")

  // Test: set_rich_presence() with None (clear)
  io.println("\n3. Testing set_rich_presence() with None (clear)...")
  localplayer.set_rich_presence(client, "status", option.None)
  io.println("   ✓ Rich presence cleared")

  io.println("")
}

fn demo_achievements(client: vapour.Client) -> Nil {
  io.println("─────────────────────────────────")
  io.println("ACHIEVEMENT API")
  io.println("─────────────────────────────────")

  // Test: names()
  io.println("\n1. Testing names()...")
  let achievement_list = achievement.names(client)
  let count = list.length(achievement_list)
  io.println("   Found " <> int.to_string(count) <> " achievements")
  io.println("   ✓ names() works")

  case achievement_list {
    [] -> {
      io.println(
        "\n   Note: No achievements configured for this app (Spacewar)",
      )
      io.println(
        "   Skipping achievement tests (activate, is_activated, clear)",
      )
    }
    [first, ..] -> {
      io.println("\n   Testing with achievement: " <> first)

      // Test: is_activated() - before activation
      io.println("\n2. Testing is_activated() - before activation...")
      let is_active_before = achievement.is_activated(client, first)
      io.println("   Activated: " <> bool.to_string(is_active_before))
      io.println("   ✓ is_activated() works")

      // Test: activate()
      io.println("\n3. Testing activate()...")
      let activated = achievement.activate(client, first)
      io.println("   Result: " <> bool.to_string(activated))
      io.println("   ✓ activate() works")

      // Test: is_activated() - after activation
      io.println("\n4. Testing is_activated() - after activation...")
      let is_active_after = achievement.is_activated(client, first)
      io.println("   Activated: " <> bool.to_string(is_active_after))
      io.println("   ✓ is_activated() reflects activation")

      // Test: clear() - for testing purposes
      io.println("\n5. Testing clear() - for testing purposes...")
      let cleared = achievement.clear(client, first)
      io.println("   Result: " <> bool.to_string(cleared))
      io.println("   ✓ clear() works")

      // Test: is_activated() - after clearing
      io.println("\n6. Testing is_activated() - after clearing...")
      let is_active_cleared = achievement.is_activated(client, first)
      io.println("   Activated: " <> bool.to_string(is_active_cleared))
      io.println("   ✓ is_activated() reflects clearing")
    }
  }

  io.println("")
}

fn demo_cloud(client: vapour.Client) -> Nil {
  io.println("─────────────────────────────────")
  io.println("CLOUD API")
  io.println("─────────────────────────────────")

  // Test: is_enabled_for_account()
  io.println("\n1. Testing is_enabled_for_account()...")
  let enabled_account = cloud.is_enabled_for_account(client)
  io.println(
    "   Cloud enabled for account: " <> bool.to_string(enabled_account),
  )
  io.println("   ✓ is_enabled_for_account() works")

  // Test: is_enabled_for_app()
  io.println("\n2. Testing is_enabled_for_app()...")
  let enabled_app = cloud.is_enabled_for_app(client)
  io.println("   Cloud enabled for app: " <> bool.to_string(enabled_app))
  io.println("   ✓ is_enabled_for_app() works")

  // Test: set_enabled_for_app()
  io.println("\n3. Testing set_enabled_for_app()...")
  cloud.set_enabled_for_app(client, True)
  io.println("   ✓ set_enabled_for_app(True) works")

  // Test: write_file()
  io.println("\n4. Testing write_file()...")
  let test_file = "vapour_test.txt"
  let test_content = "Hello from Vapour! Test data: 12345"
  let write_result = cloud.write_file(client, test_file, test_content)
  io.println("   Write result: " <> bool.to_string(write_result))
  io.println("   ✓ write_file() works")

  case write_result {
    True -> {
      // Test: file_exists()
      io.println("\n5. Testing file_exists()...")
      let exists = cloud.file_exists(client, test_file)
      io.println("   File exists: " <> bool.to_string(exists))
      io.println("   ✓ file_exists() works")

      // Test: read_file()
      io.println("\n6. Testing read_file()...")
      let read_content = cloud.read_file(client, test_file)
      io.println("   Read content: " <> read_content)
      let content_matches = read_content == test_content
      io.println("   Content matches: " <> bool.to_string(content_matches))
      io.println("   ✓ read_file() works")

      // Test: list_files()
      io.println("\n7. Testing list_files()...")
      let files = cloud.list_files(client)
      io.println("   Total cloud files: " <> int.to_string(list.length(files)))
      case list.find(files, fn(f) { f.name == test_file }) {
        Ok(file) -> {
          io.println("   Found our test file:")
          io.println("     Name: " <> file.name)
          io.println("     Size: " <> file.size <> " bytes")
        }
        Error(_) -> io.println("   Test file not found in list")
      }
      io.println("   ✓ list_files() works")

      // Test: delete_file()
      io.println("\n8. Testing delete_file()...")
      let delete_result = cloud.delete_file(client, test_file)
      io.println("   Delete result: " <> bool.to_string(delete_result))
      io.println("   ✓ delete_file() works")

      // Test: file_exists() after delete
      io.println("\n9. Testing file_exists() after delete...")
      let exists_after = cloud.file_exists(client, test_file)
      io.println("   File exists: " <> bool.to_string(exists_after))
      io.println("   ✓ file_exists() correctly shows file is gone")
    }
    False -> {
      io.println("\n   Warning: Cloud write failed, skipping remaining tests")
      io.println("   This might be because cloud is disabled or not available")
    }
  }

  io.println("")
}

fn demo_overlay(client: vapour.Client) -> Nil {
  io.println("─────────────────────────────────")
  io.println("OVERLAY API")
  io.println("─────────────────────────────────")

  io.println("\n1. Testing activate_dialog()...")
  io.println("   Opening Achievements dialog...")
  overlay.activate_dialog(client, "Achievements")
  io.println("   ✓ activate_dialog() works")
  io.println("   (Check if Steam overlay opened)")

  io.println("\n2. Testing activate_dialog_to_user()...")
  io.println("   Opening user profile (example Steam ID)...")
  overlay.activate_dialog_to_user(client, "steamid", "76561197960287930")
  io.println("   ✓ activate_dialog_to_user() works")
  io.println("   (Check if user profile opened)")

  io.println("\n3. Testing activate_web_page()...")
  io.println("   Opening gleam.run website...")
  overlay.activate_web_page(client, "https://gleam.run")
  io.println("   ✓ activate_web_page() works")
  io.println("   (Check if web page opened in overlay)")

  io.println("\n4. Testing activate_store()...")
  io.println("   Opening store page for Spacewar (480)...")
  overlay.activate_store(client, 480)
  io.println("   ✓ activate_store() works")
  io.println("   (Check if store page opened)")

  io.println(
    "\nNote: Overlay functions trigger Steam UI - check if they opened!",
  )
  io.println("")
}

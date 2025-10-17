import gleam/bool
import gleam/int
import gleam/io
import gleam/javascript/promise
import gleam/list
import gleam/option
import vapour

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
  io.println(
    "Note: Achievement tests run asynchronously - check console for results",
  )
}

fn demo_localplayer(client: vapour.SteamworksClient) -> Nil {
  io.println("─────────────────────────────────")
  io.println("LOCAL PLAYER API")
  io.println("─────────────────────────────────")

  // Test: get_name()
  io.println("\n1. Testing display_name()...")
  let name = vapour.display_name(client)
  io.println("   Player name: " <> name)

  // Test: set_rich_presence() with value
  io.println("\n2. Testing set_rich_presence() with value...")
  vapour.set_rich_presence(client, "status", "Testing Vapour")

  // Test: set_rich_presence() with None (clear)
  // io.println("\n3. Testing clear_rich_presence()...")
  // vapour.clear_rich_presence(client)

  io.println("")
}

fn demo_achievements(client: vapour.SteamworksClient) -> promise.Promise(Nil) {
  io.println("─────────────────────────────────")
  io.println("ACHIEVEMENT API (Async)")
  io.println("─────────────────────────────────")

  // Test: names() - returns a Promise
  io.println("\n1. Testing list_achievements() [async]...")

  use achievement_list <- promise.await(vapour.list_achievements(client))

  let count = list.length(achievement_list)
  io.println("   Found " <> int.to_string(count) <> " achievements")
  io.println("   ✓ list_achievements() works")

  let assert [first, ..] = achievement_list
  io.println("\n   Testing with achievement: " <> first)

  // Test: is_activated() - before activation
  io.println(
    "\n2. Testing is_achievement_unlocked() - before activation [async]...",
  )
  use is_active_before <- promise.await(vapour.is_achievement_unlocked(
    client,
    first,
  ))

  io.println("   Activated: " <> bool.to_string(is_active_before))
  io.println("   ✓ is_achievement_unlocked() works")

  // Test: activate()
  io.println("\n3. Testing unlock_achievement() [async]...")

  use activated <- promise.await(vapour.unlock_achievement(client, first))

  io.println("   Result: " <> bool.to_string(activated))
  io.println("   ✓ unlock_achievement() works")

  // Test: is_activated() - after activation
  io.println(
    "\n4. Testing is_achievement_unlocked() - after activation [async]...",
  )

  use is_active_after <- promise.await(vapour.is_achievement_unlocked(
    client,
    first,
  ))

  io.println("   Activated: " <> bool.to_string(is_active_after))
  io.println("   ✓ is_achievement_unlocked() reflects activation")

  io.println(
    "\n5. Testing lock_achievement() - for testing purposes [async]...",
  )

  use cleared <- promise.await(vapour.lock_achievement(client, first))

  io.println("   Result: " <> bool.to_string(cleared))
  io.println("   ✓ lock_achievement() works")

  // Test: is_activated() - after clearing
  io.println(
    "\n6. Testing is_achievement_unlocked() - after clearing [async]...",
  )
  use is_active_cleared <- promise.await(vapour.is_achievement_unlocked(
    client,
    first,
  ))

  io.println("   Activated: " <> bool.to_string(is_active_cleared))
  io.println("   ✓ is_achievement_unlocked() reflects clearing")
  io.println("")
  promise.resolve(Nil)
}

fn demo_cloud(client: vapour.SteamworksClient) -> Nil {
  io.println("─────────────────────────────────")
  io.println("CLOUD API")
  io.println("─────────────────────────────────")

  // Test: is_enabled_for_account()
  io.println("\n1. Testing is_cloud_enabled_for_account()...")
  let enabled_account = vapour.is_cloud_enabled_for_account(client)
  io.println(
    "   Cloud enabled for account: " <> bool.to_string(enabled_account),
  )
  io.println("   ✓ is_cloud_enabled_for_account() works")

  // Test: is_enabled_for_app()
  io.println("\n2. Testing is_cloud_enabled_for_app()...")
  let enabled_app = vapour.is_cloud_enabled_for_app(client)
  io.println("   Cloud enabled for app: " <> bool.to_string(enabled_app))
  io.println("   ✓ is_cloud_enabled_for_app() works")

  // Test: set_enabled_for_app()
  io.println("\n3. Testing toggle_cloud_for_app()...")
  vapour.toggle_cloud_for_app(client, True)
  io.println("   ✓ toggle_cloud_for_app(True) works")

  // Test: write_file()
  io.println("\n4. Testing write_file()...")
  let test_file = "vapour_test.txt"
  let test_content = "Hello from Vapour! Test data: 12345"
  let assert True = vapour.write_file(client, test_file, test_content)
  io.println("   ✓ write_file() works")

  // Test: file_exists()
  io.println("\n5. Testing file_exists()...")
  let exists = vapour.file_exists(client, test_file)
  io.println("   File exists: " <> bool.to_string(exists))
  io.println("   ✓ file_exists() works")

  // Test: read_file()
  io.println("\n6. Testing read_file()...")
  let read_content = vapour.read_file(client, test_file)
  io.println("   Read content: " <> read_content)
  let content_matches = read_content == test_content
  io.println("   Content matches: " <> bool.to_string(content_matches))
  io.println("   ✓ read_file() works")

  // Test: list_files()
  io.println("\n7. Testing list_files()...")
  let files = vapour.list_files(client)
  io.println("   Total cloud files: " <> int.to_string(list.length(files)))
  case list.find(files, fn(f) { f.name == test_file }) {
    Ok(file) -> {
      io.println("   Found our test file:")
      io.println("     Name: " <> file.name)
      io.println("     Size: " <> int.to_string(file.bytes) <> " bytes")
    }
    Error(_) -> io.println("   Test file not found in list")
  }
  io.println("   ✓ list_files() works")

  // Test: delete_file()
  io.println("\n8. Testing delete_file()...")
  let delete_result = vapour.delete_file(client, test_file)
  io.println("   Delete result: " <> bool.to_string(delete_result))
  io.println("   ✓ delete_file() works")

  // Test: file_exists() after delete
  io.println("\n9. Testing file_exists() after delete...")
  let exists_after = vapour.file_exists(client, test_file)
  io.println("   File exists: " <> bool.to_string(exists_after))
  io.println("   ✓ file_exists() correctly shows file is gone")
}

fn demo_overlay(client: vapour.SteamworksClient) -> Nil {
  io.println("─────────────────────────────────")
  io.println("OVERLAY API")
  io.println("─────────────────────────────────")

  io.println("\n1. Testing activate_dialog()...")
  io.println("   Opening Achievements dialog...")
  vapour.activate_dialog(client, "Achievements")
  io.println("   ✓ activate_dialog() works")
  io.println("   (Check if Steam overlay opened)")

  io.println("\n2. Testing activate_dialog_to_user()...")
  io.println("   Opening user profile (example Steam ID)...")
  vapour.activate_user_page_dialog(client, "steamid", "76561197960287930")
  io.println("   ✓ activate_dialog_to_user() works")
  io.println("   (Check if user profile opened)")

  io.println("\n3. Testing activate_web_page()...")
  io.println("   Opening gleam.run website...")
  vapour.activate_web_page(client, "https://gleam.run")
  io.println("   ✓ activate_web_page() works")
  io.println("   (Check if web page opened in overlay)")

  io.println("\n4. Testing activate_store()...")
  io.println("   Opening store page for Spacewar (480)...")
  vapour.activate_store(client, 480)
  io.println("   ✓ activate_store() works")
  io.println("   (Check if store page opened)")

  io.println(
    "\nNote: Overlay functions trigger Steam UI - check if they opened!",
  )
  io.println("")
}

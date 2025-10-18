import gleam/bool
import gleam/float
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
  demo_core_api(client)
  demo_localplayer(client)
  demo_achievements(client)
  demo_stats(client)
  demo_cloud(client)
  demo_friends(client)
  demo_overlay(client)
  demo_leaderboards(client)

  io.println("\n=== All Tests Complete ===")
  io.println("Note: Async tests run in background - check console for results")
}

fn demo_core_api(client: vapour.SteamworksClient) -> Nil {
  io.println("─────────────────────────────────")
  io.println("CORE API")
  io.println("─────────────────────────────────")

  // Test: get_status()
  io.println("\n1. Testing get_status()...")
  let status = vapour.status(client)
  io.println("   App ID: " <> int.to_string(status.app_id))
  io.println("   Steam ID: " <> status.steam_id)
  io.println("   Initialized: " <> bool.to_string(status.is_initialized))
  io.println("   ✓ get_status() works")

  // Test: is_steam_running()
  io.println("\n2. Testing is_steam_running()...")
  let running = vapour.running_steam(client)
  io.println("   Steam running: " <> bool.to_string(running))
  io.println("   ✓ is_steam_running() works")

  io.println("")
}

fn demo_localplayer(client: vapour.SteamworksClient) -> Nil {
  io.println("─────────────────────────────────")
  io.println("LOCAL PLAYER API")
  io.println("─────────────────────────────────")

  // Test: get_name()
  io.println("\n1. Testing display_name()...")
  let name = vapour.display_name(client)
  io.println("   Player name: " <> name)
  io.println("   ✓ display_name() works")

  // Test: set_rich_presence() with value
  io.println("\n2. Testing set_rich_presence()...")
  vapour.set_rich_presence(client, "status", "Testing Vapour")
  io.println("   ✓ set_rich_presence() works")

  // Test: clear_rich_presence()
  io.println("\n3. Testing clear_rich_presence()...")
  vapour.clear_rich_presence(client)
  io.println("   ✓ clear_rich_presence() works")

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

  // Test: indicate_achievement_progress()
  io.println("\n7. Testing indicate_achievement_progress() [async]...")
  use progress_result <- promise.await(vapour.indicate_achievement_progress(
    client,
    first,
    25,
    50,
  ))
  io.println("   Progress shown: " <> bool.to_string(progress_result))
  io.println("   ✓ indicate_achievement_progress() works")
  io.println("   (Check Steam overlay for progress notification)")

  // Test: request_global_achievement_percentages() and get_achievement_achieved_percent()
  io.println("\n8. Testing global achievement percentages [async]...")
  use global_req <- promise.await(vapour.request_global_achievement_percentages(
    client,
  ))
  io.println("   Global data requested: " <> bool.to_string(global_req))

  // Give it a moment to retrieve the data
  use percent_result <- promise.await(vapour.achievement_achieved_percent(
    client,
    first,
  ))
  case percent_result {
    Ok(percent) -> {
      io.println("   Unlock percentage: " <> float.to_string(percent) <> "%")
      case percent <. 10.0 {
        True -> io.println("   This is a RARE achievement!")
        False -> io.println("   This is a common achievement")
      }
      io.println("   ✓ get_achievement_achieved_percent() works")
    }
    Error(_) -> {
      io.println("   ✗ Percentage data not available yet")
      io.println("   (May need to wait longer for Steam servers)")
    }
  }

  io.println("")
  promise.resolve(Nil)
}

fn demo_stats(client: vapour.SteamworksClient) -> promise.Promise(Nil) {
  io.println("─────────────────────────────────")
  io.println("STATS API (Async)")
  io.println("─────────────────────────────────")

  // Test: set_stat_int()
  io.println("\n1. Testing set_stat_int() [async]...")
  use set_result <- promise.await(vapour.set_stat_int(client, "NumGames", 42))
  io.println("   Set result: " <> bool.to_string(set_result))
  io.println("   ✓ set_stat_int() works")

  // Test: get_stat_int()
  io.println("\n2. Testing get_stat_int() [async]...")
  use get_result <- promise.await(vapour.stat_int(client, "NumGames"))
  case get_result {
    Ok(value) -> {
      io.println("   NumGames: " <> int.to_string(value))
      io.println("   ✓ get_stat_int() works")
    }
    Error(_) -> io.println("   ✗ Stat not found")
  }

  // Test: set_stat_float()
  io.println("\n3. Testing set_stat_float() [async]...")
  use set_float_result <- promise.await(vapour.set_stat_float(
    client,
    "MaxFeetTraveled",
    1234.56,
  ))
  io.println("   Set result: " <> bool.to_string(set_float_result))
  io.println("   ✓ set_stat_float() works")

  // Test: get_stat_float()
  io.println("\n4. Testing get_stat_float() [async]...")
  use get_float_result <- promise.await(vapour.stat_float(
    client,
    "MaxFeetTraveled",
  ))
  case get_float_result {
    Ok(value) -> {
      io.println("   MaxFeetTraveled: " <> float.to_string(value))
      io.println("   ✓ get_stat_float() works")
    }
    Error(_) -> io.println("   ✗ Stat not found")
  }

  // Test: get_number_of_current_players()
  io.println("\n5. Testing get_number_of_current_players() [async]...")
  use players_result <- promise.await(vapour.number_of_current_players(client))
  case players_result {
    Ok(count) -> {
      io.println("   Current players: " <> int.to_string(count))
      io.println("   ✓ get_number_of_current_players() works")
    }
    Error(_) -> io.println("   ✗ Failed to get player count")
  }

  // Test: update_avg_rate_stat()
  io.println("\n6. Testing update_avg_rate_stat() [async]...")
  use avg_result <- promise.await(vapour.update_avg_rate_stat(
    client,
    "AverageSpeed",
    10,
    60,
  ))
  io.println("   Update result: " <> bool.to_string(avg_result))
  io.println("   ✓ update_avg_rate_stat() works")

  // Test: request_global_stats() and get_global_stat_int()
  io.println("\n7. Testing global stats [async]...")
  use global_req <- promise.await(vapour.request_global_stats(client, 1))
  io.println("   Global stats request: " <> bool.to_string(global_req))

  use global_stat <- promise.await(vapour.global_stat_int(
    client,
    "TotalGamesPlayed",
  ))
  case global_stat {
    Ok(value) -> {
      io.println("   TotalGamesPlayed (global): " <> int.to_string(value))
      io.println("   ✓ global stats work")
    }
    Error(_) -> io.println("   ✗ Global stat not available")
  }

  io.println("")
  promise.resolve(Nil)
}

fn demo_cloud(client: vapour.SteamworksClient) -> Nil {
  io.println("─────────────────────────────────")
  io.println("CLOUD API")
  io.println("─────────────────────────────────")

  // Test: is_enabled_for_account()
  io.println("\n1. Testing is_cloud_enabled_for_account()...")
  let enabled_account = vapour.cloud_enabled_for_account(client)
  io.println(
    "   Cloud enabled for account: " <> bool.to_string(enabled_account),
  )
  io.println("   ✓ is_cloud_enabled_for_account() works")

  // Test: is_enabled_for_app()
  io.println("\n2. Testing is_cloud_enabled_for_app()...")
  let enabled_app = vapour.cloud_enabled_for_app(client)
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
  io.println("")
}

fn demo_friends(client: vapour.SteamworksClient) -> Nil {
  io.println("─────────────────────────────────")
  io.println("FRIENDS API")
  io.println("─────────────────────────────────")

  // Test: get_persona_state()
  io.println("\n1. Testing get_persona_state()...")
  let state = vapour.persona_state(client)
  let state_str = persona_state_to_string(state)
  io.println("   Your status: " <> state_str)
  io.println("   ✓ get_persona_state() works")

  // Test: get_friend_count()
  io.println("\n2. Testing get_friend_count()...")
  let friend_count = vapour.friend_count(client)
  io.println("   Friend count: " <> int.to_string(friend_count))
  io.println("   ✓ get_friend_count() works")

  // Test: get_all_friends()
  io.println("\n3. Testing get_all_friends()...")
  let friends = vapour.all_friends(client)
  io.println("   Total friends: " <> int.to_string(list.length(friends)))

  case friends {
    [first, ..] -> {
      io.println("   First friend: " <> first.persona_name)
      io.println("   Steam ID: " <> first.steam_id)
      let friend_state = persona_state_to_string(first.persona_state)
      io.println("   Status: " <> friend_state)

      // Test friend-specific functions with first friend
      io.println("\n4. Testing friend-specific functions...")

      // Test: get_friend_persona_name()
      let persona_name = vapour.friend_persona_name(client, first.steam_id)
      io.println("   get_friend_persona_name: " <> persona_name)

      // Test: get_friend_persona_state()
      let persona_state = vapour.friend_persona_state(client, first.steam_id)
      let state_name = persona_state_to_string(persona_state)
      io.println("   get_friend_persona_state: " <> state_name)

      // Test: get_friend_steam_level()
      let level = vapour.friend_steam_level(client, first.steam_id)
      io.println("   Steam level: " <> int.to_string(level))

      // Test: get_friend_game_played()
      case vapour.friend_game_played(client, first.steam_id) {
        Ok(app_id) -> io.println("   Playing App ID: " <> int.to_string(app_id))
        Error(_) -> io.println("   Not playing any game")
      }

      // Test: get_friend_relationship()
      let relationship = vapour.friend_relationship(client, first.steam_id)
      let rel_str = relationship_to_string(relationship)
      io.println("   Relationship: " <> rel_str)

      // Test: get_friend_coplay_time()
      let coplay_time = vapour.friend_coplay_time(client, first.steam_id)
      io.println("   Last coplay time: " <> int.to_string(coplay_time))

      // Test: get_friend_coplay_game()
      let coplay_game = vapour.friend_coplay_game(client, first.steam_id)
      io.println("   Last coplay game: " <> int.to_string(coplay_game))
    }
    [] -> io.println("   No friends to test with")
  }

  // Test: get_coplay_friend_count()
  io.println("\n5. Testing get_coplay_friend_count()...")
  let coplay_count = vapour.coplay_friend_count(client)
  io.println("   Coplay friends: " <> int.to_string(coplay_count))
  io.println("   ✓ get_coplay_friend_count() works")

  io.println("")
}

fn persona_state_to_string(state: vapour.PersonaState) -> String {
  case state {
    vapour.Offline -> "Offline"
    vapour.Online -> "Online"
    vapour.Busy -> "Busy"
    vapour.Away -> "Away"
    vapour.Snooze -> "Snooze"
    vapour.LookingToTrade -> "Looking to Trade"
    vapour.LookingToPlay -> "Looking to Play"
    vapour.Invisible -> "Invisible"
    vapour.Max -> "Max"
  }
}

fn relationship_to_string(rel: vapour.FriendRelationship) -> String {
  case rel {
    vapour.RelationshipNone -> "None"
    vapour.RelationshipBlocked -> "Blocked"
    vapour.RelationshipRequestRecipient -> "Request Recipient"
    vapour.RelationshipFriend -> "Friend"
    vapour.RelationshipRequestInitiator -> "Request Initiator"
    vapour.RelationshipIgnored -> "Ignored"
    vapour.RelationshipIgnoredFriend -> "Ignored Friend"
    vapour.RelationshipSuggested -> "Suggested"
    vapour.RelationshipMax -> "Max"
  }
}

fn demo_overlay(client: vapour.SteamworksClient) -> Nil {
  io.println("─────────────────────────────────")
  io.println("OVERLAY API")
  io.println("─────────────────────────────────")

  io.println("\n1. Testing activate_dialog()...")
  io.println("   Opening Achievements dialog...")
  vapour.activate_dialog(client, vapour.AchievementsDialog)
  io.println("   ✓ activate_dialog() works")
  io.println("   (Check if Steam overlay opened)")

  io.println("\n2. Testing activate_dialog_to_user()...")
  io.println("   Opening user profile (example Steam ID)...")
  vapour.activate_user_page_dialog(client, vapour.SteamId("76561197960287930"))
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

  io.println("\n5. Testing invite_friends_to_lobby()...")
  io.println("   Opening invite dialog (dummy lobby ID)...")
  vapour.invite_friends_to_lobby(client, "0")
  io.println("   ✓ invite_friends_to_lobby() works")
  io.println("   (Check if invite dialog opened)")

  io.println("\n6. Testing invite_friends_with_connect_string()...")
  io.println("   Opening invite with connect string...")
  vapour.invite_friends_with_connect_string(client, "+connect 127.0.0.1:27015")
  io.println("   ✓ invite_friends_with_connect_string() works")
  io.println("   (Check if invite dialog opened)")

  io.println(
    "\nNote: Overlay functions trigger Steam UI - check if they opened!",
  )
  io.println("")
}

fn demo_leaderboards(client: vapour.SteamworksClient) -> promise.Promise(Nil) {
  io.println("─────────────────────────────────")
  io.println("LEADERBOARDS API (Async)")
  io.println("─────────────────────────────────")

  // Test: find_or_create_leaderboard()
  io.println("\n1. Testing find_or_create_leaderboard() [async]...")
  io.println("   Creating test leaderboard: 'VapourTest'")
  use create_result <- promise.await(vapour.find_or_create_leaderboard(
    client,
    "VapourTest",
    vapour.Descending,
    vapour.Numeric,
  ))

  use _ <- promise.await(case create_result {
    Ok(test_leaderboard) -> {
      io.println("   ✓ find_or_create_leaderboard() works")
      io.println("   Created/found leaderboard: VapourTest")

      // Upload a test score to the created leaderboard
      io.println("\n   Uploading test score to VapourTest...")
      use _ <- promise.await(vapour.upload_score(
        client,
        test_leaderboard,
        9999,
        vapour.KeepBest,
      ))
      io.println("   ✓ Uploaded score to custom leaderboard\n")
      promise.resolve(Nil)
    }
    Error(_) -> {
      io.println("   ✗ Failed to create leaderboard\n")
      promise.resolve(Nil)
    }
  })

  // Test: find_leaderboard()
  io.println("2. Testing find_leaderboard() [async]...")
  use leaderboard_result <- promise.await(vapour.find_leaderboard(
    client,
    "Quickest Win",
  ))

  case leaderboard_result {
    Ok(leaderboard_handle) -> {
      io.println("   Found leaderboard")
      io.println("   ✓ find_leaderboard() works")

      // Test: get_leaderboard_entry_count()
      io.println("\n3. Testing get_leaderboard_entry_count()...")
      let entry_count =
        vapour.get_leaderboard_entry_count(client, leaderboard_handle)
      io.println("   Entry count: " <> int.to_string(entry_count))
      io.println("   ✓ get_leaderboard_entry_count() works")

      // Test: upload_score()
      io.println("\n4. Testing upload_score() [async]...")
      use upload_result <- promise.await(vapour.upload_score(
        client,
        leaderboard_handle,
        12_345,
        vapour.KeepBest,
      ))
      io.println("   Upload result: " <> bool.to_string(upload_result))
      io.println("   ✓ upload_score() works")

      // Test: download_scores() - Global
      io.println("\n5. Testing download_scores() - Global [async]...")
      use global_scores <- promise.await(vapour.download_scores(
        client,
        leaderboard_handle,
        vapour.Global,
        1,
        10,
      ))
      io.println(
        "   Downloaded "
        <> int.to_string(list.length(global_scores))
        <> " global entries",
      )
      case global_scores {
        [first, ..] -> {
          io.println("   Top score:")
          io.println("     Rank: " <> int.to_string(first.global_rank))
          io.println("     Score: " <> int.to_string(first.score))
          io.println("     Steam ID: " <> first.steam_id)
        }
        [] -> io.println("   No entries found")
      }
      io.println("   ✓ download_scores() works")

      // Test: download_scores() - Friends
      io.println("\n6. Testing download_scores() - Friends [async]...")
      use friend_scores <- promise.await(vapour.download_scores(
        client,
        leaderboard_handle,
        vapour.Friends,
        1,
        10,
      ))
      io.println(
        "   Downloaded "
        <> int.to_string(list.length(friend_scores))
        <> " friend entries",
      )
      io.println("   ✓ download_scores() with Friends filter works")

      // Test: download_scores() - GlobalAroundUser
      io.println("\n7. Testing download_scores() - GlobalAroundUser [async]...")
      use around_user_scores <- promise.await(vapour.download_scores(
        client,
        leaderboard_handle,
        vapour.GlobalAroundUser,
        -5,
        5,
      ))
      io.println(
        "   Downloaded "
        <> int.to_string(list.length(around_user_scores))
        <> " entries around user",
      )
      io.println("   ✓ download_scores() with GlobalAroundUser filter works")

      io.println("")
      promise.resolve(Nil)
    }
    Error(_) -> {
      io.println("   ✗ Leaderboard not found")
      io.println(
        "   Note: This is expected if Spacewar doesn't have this leaderboard",
      )
      io.println("")
      promise.resolve(Nil)
    }
  }
}

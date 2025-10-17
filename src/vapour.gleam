//// Copyright (c) 2025 Renata Amutio
//// SPDX-License-Identifier: MIT
////
//// # Vapour - Steamworks SDK Bindings for Gleam
////
//// Vapour provides type-safe, idiomatic Gleam bindings for the Steamworks SDK via
//// [steamworks-ffi-node](https://github.com/ArtyProf/steamworks-ffi-node).
////
//// ## Features
////
//// - **Core API**: Initialize Steamworks, run callbacks, check connection status
//// - **Achievements**: Unlock/lock achievements, list achievements (async with Promises)
//// - **Cloud Storage**: Save/load files to Steam Cloud, manage cloud settings
//// - **Rich Presence**: Set player status visible to friends
//// - **Overlay**: Trigger Steam overlay dialogs (friends, achievements, store, web pages)
//// - **Stats**: Track player statistics, get/set int and float stats, global stats, user stats, average rate stats (async with Promises)
//// - **Friends**: Get friends list, check online status, view friend info, relationship status, coplay features
//// - **Leaderboards**: Find leaderboards, upload scores, download entries (async with Promises)
////
//// ## Quick Start
////
//// ```gleam
//// import gleam/option
//// import vapour
////
//// pub fn main() {
////   // Initialize with your app ID (or use 480 for testing with Spacewar)
////   let assert Ok(client) = vapour.init(option.Some(480))
////
////   // Run callbacks regularly to keep the connection alive
////   vapour.run_callbacks(client)
////
////   // Use the API
////   let name = vapour.display_name(client)
////   let _result = vapour.write_file(client, "save.dat", "game data")
//// }
//// ```
////
//// ## Important Notes
////
//// - Call `run_callbacks()` regularly (every frame or every 100ms) to process Steam events
//// - Achievement, Stats, and Leaderboard functions return Promises - use `gleam/javascript/promise` to handle them
//// - Steam must be running for initialization to succeed
//// - Cloud storage requires Steam Cloud to be enabled for your app and the user's account
////

import gleam/javascript/promise
import gleam/option

// ============================================================================
// Core API Types
// ============================================================================

/// Opaque type representing a connected Steamworks client.
///
/// This is obtained by calling `init()` and is required for all other API calls.
pub type SteamworksClient

/// Steam API status information.
pub type Status {
  Status(is_initialized: Bool, app_id: Int, steam_id: String)
}

/// Information about a file stored in Steam Cloud.
pub type FileInfo {
  FileInfo(name: String, bytes: Int)
}

/// Information about a friend.
pub type FriendInfo {
  FriendInfo(
    steam_id: String,
    persona_name: String,
    persona_state: PersonaState,
  )
}

/// Player online status.
pub type PersonaState {
  Offline
  Online
  Busy
  Away
  Snooze
  LookingToTrade
  LookingToPlay
  Invisible
  Max
}

/// Friend relationship status.
pub type FriendRelationship {
  RelationshipNone
  RelationshipBlocked
  RelationshipRequestRecipient
  RelationshipFriend
  RelationshipRequestInitiator
  RelationshipIgnored
  RelationshipIgnoredFriend
  RelationshipSuggested
  RelationshipMax
}

/// Leaderboard entry.
pub type LeaderboardEntry {
  LeaderboardEntry(steam_id: String, global_rank: Int, score: Int)
}

/// Leaderboard upload method.
pub type UploadScoreMethod {
  KeepBest
  ForceUpdate
}

/// Leaderboard data request type.
pub type LeaderboardDataRequest {
  Global
  GlobalAroundUser
  Friends
}

// ============================================================================
// Core API Functions
// ============================================================================

/// Initialize the Steamworks API.
///
/// This must be called before using any other Steamworks functionality.
/// Steam must be running for initialization to succeed.
///
/// ## Parameters
///
/// - `app_id`: Your Steam App ID. Pass `option.None` to read from a
///   `steam_appid.txt` file in the current directory. Use `option.Some(480)`
///   for testing with Spacewar (Steam's test app).
///
/// ## Returns
///
/// - `Ok(client)`: Successfully initialized. Use this client for all API calls.
/// - `Error(Nil)`: Initialization failed (Steam not running or invalid app ID).
///
/// ## Example
///
/// ```gleam
/// import gleam/option
/// import vapour
///
/// // Initialize with your app ID
/// let assert Ok(client) = vapour.init(option.Some(YOUR_APP_ID))
///
/// // Or use Spacewar for testing
/// let assert Ok(client) = vapour.init(option.Some(480))
///
/// // Or read from steam_appid.txt
/// let assert Ok(client) = vapour.init(option.None)
/// ```
pub fn init(app_id: option.Option(Int)) -> Result(SteamworksClient, Nil) {
  case app_id {
    option.Some(id) -> {
      let client = do_init(id)
      Ok(client)
    }
    option.None -> {
      let client = do_init_default()
      Ok(client)
    }
  }
}

@external(javascript, "./vapour.ffi.mjs", "init")
fn do_init(app_id: Int) -> SteamworksClient

fn do_init_default() -> SteamworksClient {
  do_init_null()
}

@external(javascript, "./vapour.ffi.mjs", "init")
fn do_init_null() -> SteamworksClient

/// Run Steam callbacks to process pending events.
///
/// This should be called regularly (ideally every frame or every 100ms) to
/// keep the Steam connection alive and process asynchronous operations.
///
/// ## Example
///
/// ```gleam
/// import vapour
///
/// pub fn game_loop(client: vapour.SteamworksClient) {
///   // Process Steam callbacks each frame
///   vapour.run_callbacks(client)
///
///   // Rest of your game loop...
/// }
/// ```
pub fn run_callbacks(client: SteamworksClient) -> Nil {
  do_run_callbacks(client)
}

@external(javascript, "./vapour.ffi.mjs", "runCallbacks")
fn do_run_callbacks(client: SteamworksClient) -> Nil

/// Get Steam API status including Steam ID and connection state.
///
/// Returns information about the current Steam connection including
/// the logged-in user's Steam ID.
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import gleam/io
///
/// let status = vapour.get_status(client)
/// io.println("Steam ID: " <> status.steam_id)
/// io.println("Connected: " <> bool.to_string(status.is_initialized))
/// ```
@external(javascript, "./vapour.ffi.mjs", "getStatus")
pub fn get_status(client: SteamworksClient) -> Status

/// Check if the Steam client is running.
///
/// Returns `True` if Steam is currently running on the system, `False` otherwise.
///
/// ## Example
///
/// ```gleam
/// import vapour
///
/// case vapour.is_steam_running(client) {
///   True -> io.println("Steam is running")
///   False -> io.println("Steam is not running")
/// }
/// ```
@external(javascript, "./vapour.ffi.mjs", "isSteamRunning")
pub fn is_steam_running(client: SteamworksClient) -> Bool

// ============================================================================
// Cloud Storage API
// ============================================================================

/// Check if Steam Cloud is enabled for the current user's account.
///
/// Returns `True` if the user has Steam Cloud enabled in their Steam settings.
///
/// ## Example
///
/// ```gleam
/// case vapour.is_cloud_enabled_for_account(client) {
///   True -> io.println("Cloud enabled for account")
///   False -> io.println("Cloud disabled - user must enable it in Steam settings")
/// }
/// ```
@external(javascript, "./vapour.ffi.mjs", "cloudIsEnabledForAccount")
pub fn is_cloud_enabled_for_account(client: SteamworksClient) -> Bool

/// Check if Steam Cloud is enabled for the current app.
///
/// Returns `True` if Steam Cloud is enabled for this app. This can be toggled
/// using `toggle_cloud_for_app()`.
@external(javascript, "./vapour.ffi.mjs", "cloudIsEnabledForApp")
pub fn is_cloud_enabled_for_app(client: SteamworksClient) -> Bool

/// Enable or disable Steam Cloud for the current app.
///
/// ## Parameters
///
/// - `enabled`: `True` to enable cloud storage, `False` to disable it
///
/// ## Example
///
/// ```gleam
/// // Enable cloud storage
/// vapour.toggle_cloud_for_app(client, True)
///
/// // Disable cloud storage
/// vapour.toggle_cloud_for_app(client, False)
/// ```
@external(javascript, "./vapour.ffi.mjs", "cloudSetEnabledForApp")
pub fn toggle_cloud_for_app(client: SteamworksClient, enabled: Bool) -> Nil

/// Read a file from Steam Cloud.
///
/// Returns the file contents as a string, or an empty string if the file
/// doesn't exist or the read fails.
///
/// ## Example
///
/// ```gleam
/// let content = vapour.read_file(client, "savegame.json")
/// case content {
///   "" -> io.println("File not found")
///   data -> process_save_data(data)
/// }
/// ```
@external(javascript, "./vapour.ffi.mjs", "cloudReadFile")
pub fn read_file(client: SteamworksClient, name: String) -> String

/// Write a file to Steam Cloud.
///
/// ## Parameters
///
/// - `name`: Filename to write (e.g., "savegame.json")
/// - `content`: File content as a string
///
/// ## Returns
///
/// `True` if the write was successful, `False` otherwise.
///
/// ## Example
///
/// ```gleam
/// let save_data = json.encode(game_state)
/// case vapour.write_file(client, "savegame.json", save_data) {
///   True -> io.println("Game saved to cloud")
///   False -> io.println("Failed to save to cloud")
/// }
/// ```
@external(javascript, "./vapour.ffi.mjs", "cloudWriteFile")
pub fn write_file(
  client: SteamworksClient,
  name: String,
  content: String,
) -> Bool

/// Delete a file from Steam Cloud.
///
/// Returns `True` if the file was successfully deleted, `False` otherwise.
///
/// ## Example
///
/// ```gleam
/// case vapour.delete_file(client, "old_save.dat") {
///   True -> io.println("File deleted")
///   False -> io.println("Failed to delete file")
/// }
/// ```
@external(javascript, "./vapour.ffi.mjs", "cloudDeleteFile")
pub fn delete_file(client: SteamworksClient, name: String) -> Bool

/// Check if a file exists in Steam Cloud.
///
/// Returns `True` if the file exists, `False` otherwise.
///
/// ## Example
///
/// ```gleam
/// case vapour.file_exists(client, "savegame.json") {
///   True -> load_save_file(client)
///   False -> create_new_game()
/// }
/// ```
@external(javascript, "./vapour.ffi.mjs", "cloudFileExists")
pub fn file_exists(client: SteamworksClient, name: String) -> Bool

/// List all files in Steam Cloud.
///
/// Returns a list of `FileInfo` records containing file names and sizes in bytes.
///
/// ## Example
///
/// ```gleam
/// let files = vapour.list_files(client)
/// list.each(files, fn(file) {
///   io.println(file.name <> ": " <> int.to_string(file.bytes) <> " bytes")
/// })
/// ```
@external(javascript, "./vapour.ffi.mjs", "cloudListFiles")
pub fn list_files(client: SteamworksClient) -> List(FileInfo)

// ============================================================================
// Achievement API (Async)
// ============================================================================

/// Unlock an achievement (async).
///
/// Returns a Promise that resolves to `True` if the achievement was successfully
/// unlocked, `False` otherwise.
///
/// ## Example
///
/// ```gleam
/// import gleam/javascript/promise
///
/// vapour.unlock_achievement(client, "ACH_WIN_ONE_GAME")
/// |> promise.await(fn(success) {
///   case success {
///     True -> io.println("Achievement unlocked!")
///     False -> io.println("Failed to unlock achievement")
///   }
///   promise.resolve(Nil)
/// })
/// ```
@external(javascript, "./vapour.ffi.mjs", "achievementActivate")
pub fn unlock_achievement(
  client: SteamworksClient,
  achievement: String,
) -> promise.Promise(Bool)

/// Check if an achievement is unlocked (async).
///
/// Returns a Promise that resolves to `True` if the achievement is unlocked,
/// `False` otherwise.
///
/// ## Example
///
/// ```gleam
/// import gleam/javascript/promise
///
/// vapour.is_achievement_unlocked(client, "ACH_WIN_ONE_GAME")
/// |> promise.await(fn(is_unlocked) {
///   case is_unlocked {
///     True -> io.println("Already unlocked")
///     False -> io.println("Not yet unlocked")
///   }
///   promise.resolve(Nil)
/// })
/// ```
@external(javascript, "./vapour.ffi.mjs", "achievementIsActivated")
pub fn is_achievement_unlocked(
  client: SteamworksClient,
  achievement: String,
) -> promise.Promise(Bool)

/// Lock an achievement (async) - primarily for testing.
///
/// Returns a Promise that resolves to `True` if the achievement was successfully
/// locked, `False` otherwise.
///
/// ## Example
///
/// ```gleam
/// import gleam/javascript/promise
///
/// vapour.lock_achievement(client, "ACH_WIN_ONE_GAME")
/// |> promise.await(fn(success) {
///   case success {
///     True -> io.println("Achievement locked for testing")
///     False -> io.println("Failed to lock achievement")
///   }
///   promise.resolve(Nil)
/// })
/// ```
@external(javascript, "./vapour.ffi.mjs", "achievementClear")
pub fn lock_achievement(
  client: SteamworksClient,
  achievement: String,
) -> promise.Promise(Bool)

/// Get a list of all achievement names (async).
///
/// Returns a Promise that resolves to a list of all achievement IDs defined
/// for this app.
///
/// ## Example
///
/// ```gleam
/// import gleam/javascript/promise
/// import gleam/list
///
/// vapour.list_achievements(client)
/// |> promise.await(fn(achievements) {
///   io.println("Found " <> int.to_string(list.length(achievements)) <> " achievements")
///   list.each(achievements, io.println)
///   promise.resolve(Nil)
/// })
/// ```
@external(javascript, "./vapour.ffi.mjs", "achievementNames")
pub fn list_achievements(
  client: SteamworksClient,
) -> promise.Promise(List(String))

// ============================================================================
// Local Player API
// ============================================================================

/// Get the local player's display name (persona name).
///
/// Returns the Steam display name that other users see.
///
/// ## Example
///
/// ```gleam
/// let name = vapour.display_name(client)
/// io.println("Welcome, " <> name <> "!")
/// ```
@external(javascript, "./vapour.ffi.mjs", "localplayerGetName")
pub fn display_name(client: SteamworksClient) -> String

/// Set a Rich Presence key/value pair.
///
/// Rich Presence allows friends to see what you're doing in-game (e.g.,
/// "In Menu", "Playing Level 3", "Score: 1000").
///
/// ## Parameters
///
/// - `key`: Rich Presence key (e.g., "status", "score", "level")
/// - `value`: Rich Presence value (e.g., "In Menu", "1000", "Level 3")
///
/// ## Example
///
/// ```gleam
/// // Set player status
/// vapour.set_rich_presence(client, "status", "In Main Menu")
///
/// // Set current level
/// vapour.set_rich_presence(client, "level", "Level 3")
///
/// // Set score
/// vapour.set_rich_presence(client, "score", "1500")
/// ```
@external(javascript, "./vapour.ffi.mjs", "localplayerSetRichPresence")
pub fn set_rich_presence(
  client: SteamworksClient,
  key: String,
  value: String,
) -> Nil

/// Clear all Rich Presence data.
///
/// Removes all Rich Presence information for the current player.
///
/// ## Example
///
/// ```gleam
/// // Clear rich presence when exiting game
/// vapour.clear_rich_presence(client)
/// ```
@external(javascript, "./vapour.ffi.mjs", "localplayerClearRichPresence")
pub fn clear_rich_presence(client: SteamworksClient) -> Nil

// ============================================================================
// Overlay API
// ============================================================================

/// Activate a Steam overlay dialog.
///
/// Opens the Steam overlay to a specific dialog.
///
/// ## Common Dialog Names
///
/// - `"Friends"`: Show friends list
/// - `"Community"`: Show community hub
/// - `"Players"`: Show players in current game
/// - `"Settings"`: Show Steam settings
/// - `"OfficialGameGroup"`: Show game's official group
/// - `"Stats"`: Show stats and achievements
/// - `"Achievements"`: Show achievements
///
/// ## Example
///
/// ```gleam
/// // Open achievements dialog
/// vapour.activate_dialog(client, "Achievements")
///
/// // Open friends list
/// vapour.activate_dialog(client, "Friends")
/// ```
@external(javascript, "./vapour.ffi.mjs", "overlayActivateDialog")
pub fn activate_dialog(client: SteamworksClient, dialog: String) -> Nil

/// Activate the Steam overlay to a specific user's profile.
///
/// ## Parameters
///
/// - `dialog`: Dialog type (usually `"steamid"` for profile)
/// - `steam_id_64`: The user's 64-bit Steam ID as a string
///
/// ## Example
///
/// ```gleam
/// // Open a friend's profile
/// vapour.activate_user_page_dialog(client, "steamid", "76561197960287930")
/// ```
@external(javascript, "./vapour.ffi.mjs", "overlayActivateDialogToUser")
pub fn activate_user_page_dialog(
  client: SteamworksClient,
  dialog: String,
  steam_id_64: String,
) -> Nil

/// Activate the Steam overlay browser to a web page.
///
/// Opens the specified URL in the Steam overlay browser.
///
/// ## Example
///
/// ```gleam
/// // Open game website
/// vapour.activate_web_page(client, "https://mygame.com")
///
/// // Open wiki page
/// vapour.activate_web_page(client, "https://wiki.mygame.com/walkthrough")
/// ```
@external(javascript, "./vapour.ffi.mjs", "overlayActivateWebPage")
pub fn activate_web_page(client: SteamworksClient, url: String) -> Nil

/// Activate the Steam overlay to a store page.
///
/// Opens the Steam store to the specified app's page.
///
/// ## Parameters
///
/// - `app_id`: The Steam App ID to show in the store
///
/// ## Example
///
/// ```gleam
/// // Open your game's DLC store page
/// vapour.activate_store(client, 12345)
///
/// // Open your game's main store page
/// vapour.activate_store(client, YOUR_APP_ID)
/// ```
@external(javascript, "./vapour.ffi.mjs", "overlayActivateStore")
pub fn activate_store(client: SteamworksClient, app_id: Int) -> Nil

// ============================================================================
// Stats API (Async)
// ============================================================================

/// Get an integer stat value for the current user (async).
///
/// Returns a Promise that resolves to the stat value, or `Error(Nil)` if not found.
///
/// ## Example
///
/// ```gleam
/// import gleam/javascript/promise
///
/// vapour.get_stat_int(client, "total_kills")
/// |> promise.await(fn(result) {
///   case result {
///     Ok(kills) -> io.println("Total kills: " <> int.to_string(kills))
///     Error(_) -> io.println("Stat not found")
///   }
///   promise.resolve(Nil)
/// })
/// ```
pub fn get_stat_int(
  client: SteamworksClient,
  stat_name: String,
) -> promise.Promise(Result(Int, Nil)) {
  do_get_stat_int(client, stat_name)
  |> promise.map(fn(value) {
    case value {
      -1 -> Error(Nil)
      v -> Ok(v)
    }
  })
}

@external(javascript, "./vapour.ffi.mjs", "statsGetInt")
fn do_get_stat_int(
  client: SteamworksClient,
  stat_name: String,
) -> promise.Promise(Int)

/// Get a float stat value for the current user (async).
///
/// Returns a Promise that resolves to the stat value, or `Error(Nil)` if not found.
///
/// ## Example
///
/// ```gleam
/// import gleam/javascript/promise
///
/// vapour.get_stat_float(client, "accuracy")
/// |> promise.await(fn(result) {
///   case result {
///     Ok(accuracy) -> io.println("Accuracy: " <> float.to_string(accuracy))
///     Error(_) -> io.println("Stat not found")
///   }
///   promise.resolve(Nil)
/// })
/// ```
pub fn get_stat_float(
  client: SteamworksClient,
  stat_name: String,
) -> promise.Promise(Result(Float, Nil)) {
  do_get_stat_float(client, stat_name)
  |> promise.map(fn(value) {
    case value {
      -1.0 -> Error(Nil)
      v -> Ok(v)
    }
  })
}

@external(javascript, "./vapour.ffi.mjs", "statsGetFloat")
fn do_get_stat_float(
  client: SteamworksClient,
  stat_name: String,
) -> promise.Promise(Float)

/// Set an integer stat value for the current user (async).
///
/// Returns a Promise that resolves to `True` if successful, `False` otherwise.
///
/// ## Example
///
/// ```gleam
/// import gleam/javascript/promise
///
/// vapour.set_stat_int(client, "total_kills", 100)
/// |> promise.await(fn(success) {
///   case success {
///     True -> io.println("Stat updated!")
///     False -> io.println("Failed to update stat")
///   }
///   promise.resolve(Nil)
/// })
/// ```
@external(javascript, "./vapour.ffi.mjs", "statsSetInt")
pub fn set_stat_int(
  client: SteamworksClient,
  stat_name: String,
  value: Int,
) -> promise.Promise(Bool)

/// Set a float stat value for the current user (async).
///
/// Returns a Promise that resolves to `True` if successful, `False` otherwise.
///
/// ## Example
///
/// ```gleam
/// import gleam/javascript/promise
///
/// vapour.set_stat_float(client, "accuracy", 0.85)
/// |> promise.await(fn(success) {
///   case success {
///     True -> io.println("Stat updated!")
///     False -> io.println("Failed to update stat")
///   }
///   promise.resolve(Nil)
/// })
/// ```
@external(javascript, "./vapour.ffi.mjs", "statsSetFloat")
pub fn set_stat_float(
  client: SteamworksClient,
  stat_name: String,
  value: Float,
) -> promise.Promise(Bool)

/// Get the number of players currently playing the game (async).
///
/// Returns a Promise that resolves to the player count, or `Error(Nil)` on error.
///
/// ## Example
///
/// ```gleam
/// import gleam/javascript/promise
///
/// vapour.get_number_of_current_players(client)
/// |> promise.await(fn(result) {
///   case result {
///     Ok(count) -> io.println(int.to_string(count) <> " players online!")
///     Error(_) -> io.println("Failed to get player count")
///   }
///   promise.resolve(Nil)
/// })
/// ```
pub fn get_number_of_current_players(
  client: SteamworksClient,
) -> promise.Promise(Result(Int, Nil)) {
  do_get_number_of_current_players(client)
  |> promise.map(fn(value) {
    case value {
      -1 -> Error(Nil)
      v -> Ok(v)
    }
  })
}

@external(javascript, "./vapour.ffi.mjs", "statsGetNumberOfCurrentPlayers")
fn do_get_number_of_current_players(
  client: SteamworksClient,
) -> promise.Promise(Int)

// ============================================================================
// Friends API
// ============================================================================

/// Get the current user's persona state (online status).
///
/// Returns the user's current online status.
///
/// ## Example
///
/// ```gleam
/// let state = vapour.get_persona_state(client)
/// case state {
///   vapour.Online -> io.println("You are online")
///   vapour.Offline -> io.println("You appear offline")
///   _ -> io.println("Other status")
/// }
/// ```
pub fn get_persona_state(client: SteamworksClient) -> PersonaState {
  let state_int = do_get_persona_state(client)
  int_to_persona_state(state_int)
}

@external(javascript, "./vapour.ffi.mjs", "friendsGetPersonaState")
fn do_get_persona_state(client: SteamworksClient) -> Int

fn int_to_persona_state(state: Int) -> PersonaState {
  case state {
    0 -> Offline
    1 -> Online
    2 -> Busy
    3 -> Away
    4 -> Snooze
    5 -> LookingToTrade
    6 -> LookingToPlay
    7 -> Invisible
    _ -> Max
  }
}

/// Get the count of friends.
///
/// Returns the total number of friends in your friends list.
///
/// ## Example
///
/// ```gleam
/// let count = vapour.get_friend_count(client)
/// io.println("You have " <> int.to_string(count) <> " friends")
/// ```
@external(javascript, "./vapour.ffi.mjs", "friendsGetFriendCount")
pub fn get_friend_count(client: SteamworksClient) -> Int

/// Get a friend's Steam ID by index.
///
/// Returns the Steam ID of the friend at the specified index, or `Error(Nil)` if invalid.
///
/// ## Example
///
/// ```gleam
/// case vapour.get_friend_by_index(client, 0) {
///   Ok(steam_id) -> io.println("First friend: " <> steam_id)
///   Error(_) -> io.println("No friends at this index")
/// }
/// ```
pub fn get_friend_by_index(
  client: SteamworksClient,
  index: Int,
) -> Result(String, Nil) {
  case do_get_friend_by_index(client, index) {
    "" -> Error(Nil)
    steam_id -> Ok(steam_id)
  }
}

@external(javascript, "./vapour.ffi.mjs", "friendsGetFriendByIndex")
fn do_get_friend_by_index(client: SteamworksClient, index: Int) -> String

/// Get a friend's persona name (display name).
///
/// Returns the friend's Steam display name.
///
/// ## Example
///
/// ```gleam
/// let name = vapour.get_friend_persona_name(client, "76561197960287930")
/// io.println("Friend name: " <> name)
/// ```
@external(javascript, "./vapour.ffi.mjs", "friendsGetFriendPersonaName")
pub fn get_friend_persona_name(
  client: SteamworksClient,
  steam_id: String,
) -> String

/// Get a friend's persona state (online status).
///
/// Returns the friend's current online status.
///
/// ## Example
///
/// ```gleam
/// let state = vapour.get_friend_persona_state(client, friend_id)
/// case state {
///   vapour.Online -> io.println("Friend is online")
///   vapour.Offline -> io.println("Friend is offline")
///   _ -> io.println("Friend has other status")
/// }
/// ```
pub fn get_friend_persona_state(
  client: SteamworksClient,
  steam_id: String,
) -> PersonaState {
  let state_int = do_get_friend_persona_state(client, steam_id)
  int_to_persona_state(state_int)
}

@external(javascript, "./vapour.ffi.mjs", "friendsGetFriendPersonaState")
fn do_get_friend_persona_state(
  client: SteamworksClient,
  steam_id: String,
) -> Int

/// Get all friends with their information.
///
/// Returns a list of all friends with their Steam ID, name, and online status.
///
/// ## Example
///
/// ```gleam
/// let friends = vapour.get_all_friends(client)
/// list.each(friends, fn(friend) {
///   io.println(friend.persona_name <> " (" <> friend.steam_id <> ")")
/// })
/// ```
@external(javascript, "./vapour.ffi.mjs", "friendsGetAllFriends")
pub fn get_all_friends(client: SteamworksClient) -> List(FriendInfo)

/// Get a friend's Steam level.
///
/// Returns the friend's Steam level (0 if unavailable).
///
/// ## Example
///
/// ```gleam
/// let level = vapour.get_friend_steam_level(client, friend_id)
/// io.println("Friend is Level " <> int.to_string(level))
/// ```
@external(javascript, "./vapour.ffi.mjs", "friendsGetFriendSteamLevel")
pub fn get_friend_steam_level(client: SteamworksClient, steam_id: String) -> Int

/// Get the game a friend is currently playing.
///
/// Returns the App ID of the game the friend is playing, or `Error(Nil)` if not playing.
///
/// ## Example
///
/// ```gleam
/// case vapour.get_friend_game_played(client, friend_id) {
///   Ok(app_id) -> io.println("Friend is playing App " <> int.to_string(app_id))
///   Error(_) -> io.println("Friend is not playing any game")
/// }
/// ```
pub fn get_friend_game_played(
  client: SteamworksClient,
  steam_id: String,
) -> Result(Int, Nil) {
  case do_get_friend_game_played(client, steam_id) {
    0 -> Error(Nil)
    app_id -> Ok(app_id)
  }
}

@external(javascript, "./vapour.ffi.mjs", "friendsGetFriendGamePlayed")
fn do_get_friend_game_played(client: SteamworksClient, steam_id: String) -> Int

// ============================================================================
// Advanced Stats API (Async)
// ============================================================================

/// Update an average rate stat (async).
///
/// For stats like "kills per hour", Steam maintains the average calculation.
@external(javascript, "./vapour.ffi.mjs", "statsUpdateAvgRateStat")
pub fn update_avg_rate_stat(
  client: SteamworksClient,
  stat_name: String,
  count_this_session: Int,
  session_length: Int,
) -> promise.Promise(Bool)

/// Request global stats from Steam (async).
///
/// Must be called before getting global stats. Returns `True` if request sent successfully.
@external(javascript, "./vapour.ffi.mjs", "statsRequestGlobalStats")
pub fn request_global_stats(
  client: SteamworksClient,
  history_days: Int,
) -> promise.Promise(Bool)

/// Get a global integer stat (async).
pub fn get_global_stat_int(
  client: SteamworksClient,
  stat_name: String,
) -> promise.Promise(Result(Int, Nil)) {
  do_get_global_stat_int(client, stat_name)
  |> promise.map(fn(value) {
    case value {
      -1 -> Error(Nil)
      v -> Ok(v)
    }
  })
}

@external(javascript, "./vapour.ffi.mjs", "statsGetGlobalStatInt")
fn do_get_global_stat_int(
  client: SteamworksClient,
  stat_name: String,
) -> promise.Promise(Int)

/// Get a global float stat (async).
pub fn get_global_stat_float(
  client: SteamworksClient,
  stat_name: String,
) -> promise.Promise(Result(Float, Nil)) {
  do_get_global_stat_float(client, stat_name)
  |> promise.map(fn(value) {
    case value {
      -1.0 -> Error(Nil)
      v -> Ok(v)
    }
  })
}

@external(javascript, "./vapour.ffi.mjs", "statsGetGlobalStatFloat")
fn do_get_global_stat_float(
  client: SteamworksClient,
  stat_name: String,
) -> promise.Promise(Float)

/// Request stats for another user (async).
@external(javascript, "./vapour.ffi.mjs", "statsRequestUserStats")
pub fn request_user_stats(
  client: SteamworksClient,
  steam_id: String,
) -> promise.Promise(Bool)

/// Get an integer stat for another user (async).
pub fn get_user_stat_int(
  client: SteamworksClient,
  steam_id: String,
  stat_name: String,
) -> promise.Promise(Result(Int, Nil)) {
  do_get_user_stat_int(client, steam_id, stat_name)
  |> promise.map(fn(value) {
    case value {
      -1 -> Error(Nil)
      v -> Ok(v)
    }
  })
}

@external(javascript, "./vapour.ffi.mjs", "statsGetUserStatInt")
fn do_get_user_stat_int(
  client: SteamworksClient,
  steam_id: String,
  stat_name: String,
) -> promise.Promise(Int)

/// Get a float stat for another user (async).
pub fn get_user_stat_float(
  client: SteamworksClient,
  steam_id: String,
  stat_name: String,
) -> promise.Promise(Result(Float, Nil)) {
  do_get_user_stat_float(client, steam_id, stat_name)
  |> promise.map(fn(value) {
    case value {
      -1.0 -> Error(Nil)
      v -> Ok(v)
    }
  })
}

@external(javascript, "./vapour.ffi.mjs", "statsGetUserStatFloat")
fn do_get_user_stat_float(
  client: SteamworksClient,
  steam_id: String,
  stat_name: String,
) -> promise.Promise(Float)

// ============================================================================
// Advanced Friends API
// ============================================================================

/// Get the relationship with another user.
pub fn get_friend_relationship(
  client: SteamworksClient,
  steam_id: String,
) -> FriendRelationship {
  let rel_int = do_get_friend_relationship(client, steam_id)
  int_to_relationship(rel_int)
}

@external(javascript, "./vapour.ffi.mjs", "friendsGetFriendRelationship")
fn do_get_friend_relationship(client: SteamworksClient, steam_id: String) -> Int

fn int_to_relationship(rel: Int) -> FriendRelationship {
  case rel {
    0 -> RelationshipNone
    1 -> RelationshipBlocked
    2 -> RelationshipRequestRecipient
    3 -> RelationshipFriend
    4 -> RelationshipRequestInitiator
    5 -> RelationshipIgnored
    6 -> RelationshipIgnoredFriend
    7 -> RelationshipSuggested
    _ -> RelationshipMax
  }
}

/// Get the count of coplay friends (recently played with).
@external(javascript, "./vapour.ffi.mjs", "friendsGetCoplayFriendCount")
pub fn get_coplay_friend_count(client: SteamworksClient) -> Int

/// Get a coplay friend's Steam ID by index.
@external(javascript, "./vapour.ffi.mjs", "friendsGetCoplayFriend")
pub fn get_coplay_friend(client: SteamworksClient, index: Int) -> String

/// Get when you last played with a user (Unix timestamp).
@external(javascript, "./vapour.ffi.mjs", "friendsGetFriendCoplayTime")
pub fn get_friend_coplay_time(client: SteamworksClient, steam_id: String) -> Int

/// Get the App ID of the game you last played with a user.
@external(javascript, "./vapour.ffi.mjs", "friendsGetFriendCoplayGame")
pub fn get_friend_coplay_game(client: SteamworksClient, steam_id: String) -> Int

// ============================================================================
// Leaderboards API (Async)
// ============================================================================

/// Find a leaderboard by name (async).
///
/// Returns a leaderboard handle, or `Error(Nil)` if not found.
pub fn find_leaderboard(
  client: SteamworksClient,
  leaderboard_name: String,
) -> promise.Promise(Result(String, Nil)) {
  do_find_leaderboard(client, leaderboard_name)
  |> promise.map(fn(handle) {
    case handle {
      "" -> Error(Nil)
      h -> Ok(h)
    }
  })
}

@external(javascript, "./vapour.ffi.mjs", "leaderboardsFindLeaderboard")
fn do_find_leaderboard(
  client: SteamworksClient,
  leaderboard_name: String,
) -> promise.Promise(String)

/// Upload a score to a leaderboard (async).
pub fn upload_score(
  client: SteamworksClient,
  leaderboard_handle: String,
  score: Int,
  upload_method: UploadScoreMethod,
) -> promise.Promise(Bool) {
  let method_str = upload_score_method_to_string(upload_method)
  do_upload_score(client, leaderboard_handle, score, method_str)
}

@external(javascript, "./vapour.ffi.mjs", "leaderboardsUploadScore")
fn do_upload_score(
  client: SteamworksClient,
  leaderboard_handle: String,
  score: Int,
  upload_method: String,
) -> promise.Promise(Bool)

fn upload_score_method_to_string(method: UploadScoreMethod) -> String {
  case method {
    KeepBest -> "KeepBest"
    ForceUpdate -> "ForceUpdate"
  }
}

/// Download leaderboard entries (async).
pub fn download_scores(
  client: SteamworksClient,
  leaderboard_handle: String,
  data_request: LeaderboardDataRequest,
  start: Int,
  end: Int,
) -> promise.Promise(List(LeaderboardEntry)) {
  let request_str = leaderboard_data_request_to_string(data_request)
  do_download_scores(client, leaderboard_handle, request_str, start, end)
}

@external(javascript, "./vapour.ffi.mjs", "leaderboardsDownloadScores")
fn do_download_scores(
  client: SteamworksClient,
  leaderboard_handle: String,
  data_request: String,
  start: Int,
  end: Int,
) -> promise.Promise(List(LeaderboardEntry))

fn leaderboard_data_request_to_string(request: LeaderboardDataRequest) -> String {
  case request {
    Global -> "Global"
    GlobalAroundUser -> "GlobalAroundUser"
    Friends -> "Friends"
  }
}

/// Get the entry count for a leaderboard.
@external(javascript, "./vapour.ffi.mjs", "leaderboardsGetEntryCount")
pub fn get_leaderboard_entry_count(
  client: SteamworksClient,
  leaderboard_handle: String,
) -> Int

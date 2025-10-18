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

/// Leaderboard sort method.
pub type LeaderboardSortMethod {
  SortNone
  Ascending
  Descending
}

/// Leaderboard display type.
pub type LeaderboardDisplayType {
  DisplayNone
  Numeric
  TimeSeconds
  TimeMilliseconds
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
/// let status = vapour.status(client)
/// io.println("Steam ID: " <> status.steam_id)
/// io.println("Connected: " <> bool.to_string(status.is_initialized))
/// ```
@external(javascript, "./vapour.ffi.mjs", "getStatus")
pub fn status(client: SteamworksClient) -> Status

/// Check if the Steam client is running.
///
/// Returns `True` if Steam is currently running on the system, `False` otherwise.
///
/// ## Example
///
/// ```gleam
/// import vapour
///
/// case vapour.running_steam(client) {
///   True -> io.println("Steam is running")
///   False -> io.println("Steam is not running")
/// }
/// ```
@external(javascript, "./vapour.ffi.mjs", "isSteamRunning")
pub fn running_steam(client: SteamworksClient) -> Bool

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
/// case vapour.cloud_enabled_for_account(client) {
///   True -> io.println("Cloud enabled for account")
///   False -> io.println("Cloud disabled - user must enable it in Steam settings")
/// }
/// ```
@external(javascript, "./vapour.ffi.mjs", "cloudIsEnabledForAccount")
pub fn cloud_enabled_for_account(client: SteamworksClient) -> Bool

/// Check if Steam Cloud is enabled for the current app.
///
/// Returns `True` if Steam Cloud is enabled for this app. This can be toggled
/// using `toggle_cloud_for_app()`.
@external(javascript, "./vapour.ffi.mjs", "cloudIsEnabledForApp")
pub fn cloud_enabled_for_app(client: SteamworksClient) -> Bool

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

/// Show achievement progress notification (async).
///
/// Displays a progress notification in the Steam overlay (e.g., "Win 50 games: 25/50").
/// Useful for achievements that require multiple steps.
///
/// ## Parameters
///
/// - `achievement`: Achievement API name
/// - `current_progress`: Current progress value
/// - `max_progress`: Maximum progress value needed to unlock
///
/// ## Example
///
/// ```gleam
/// import gleam/javascript/promise
///
/// vapour.indicate_achievement_progress(client, "ACH_WIN_50_GAMES", 25, 50)
/// |> promise.await(fn(success) {
///   case success {
///     True -> io.println("Progress notification shown")
///     False -> io.println("Failed to show progress")
///   }
///   promise.resolve(Nil)
/// })
/// ```
@external(javascript, "./vapour.ffi.mjs", "achievementIndicateProgress")
pub fn indicate_achievement_progress(
  client: SteamworksClient,
  achievement: String,
  current_progress: Int,
  max_progress: Int,
) -> promise.Promise(Bool)

/// Request global achievement unlock percentages (async).
///
/// Must be called before using `achievement_achieved_percent()`.
/// Returns `True` if the request was sent successfully.
///
/// ## Example
///
/// ```gleam
/// import gleam/javascript/promise
///
/// vapour.request_global_achievement_percentages(client)
/// |> promise.await(fn(success) {
///   case success {
///     True -> io.println("Global data requested")
///     False -> io.println("Request failed")
///   }
///   promise.resolve(Nil)
/// })
/// ```
@external(javascript, "./vapour.ffi.mjs", "achievementRequestGlobalPercentages")
pub fn request_global_achievement_percentages(
  client: SteamworksClient,
) -> promise.Promise(Bool)

/// Get global unlock percentage for an achievement (async).
///
/// Returns what percentage of all players have unlocked this achievement (0-100).
/// Must call `request_global_achievement_percentages()` first.
///
/// ## Example
///
/// ```gleam
/// import gleam/javascript/promise
///
/// use request_successful <- promise.await(
///   vapour.request_global_achievement_percentages(client),
/// )
/// case request_successful {
///   True -> {
///     vapour.achievement_achieved_percent(client, "ACH_WIN_ONE_GAME")
///     |> promise.await(fn(result) {
///       case result {
///         Ok(percent) ->
///           io.println(float.to_string(percent) <> "% of players have this")
///         Error(_) -> io.println("Data not available")
///       }
///       promise.resolve(Nil)
///     })
///   }
///   False -> promise.resolve(Nil)
/// }
/// ```
@external(javascript, "./vapour.ffi.mjs", "achievementGetAchievedPercent")
pub fn achievement_achieved_percent(
  client: SteamworksClient,
  achievement: String,
) -> promise.Promise(Result(Float, Nil))

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

pub type Dialog {
  FriendsDialog
  CommunityDialog
  PlayersDialog
  SettingsDialog
  OfficialGameGroupDialog
  StatsDialog
  AchievementsDialog
}

fn dialog_to_string(dialog: Dialog) {
  case dialog {
    AchievementsDialog -> "Achievements"
    CommunityDialog -> "Community"
    FriendsDialog -> "Friends"
    OfficialGameGroupDialog -> "OfficialGameGroup"
    PlayersDialog -> "Players"
    SettingsDialog -> "Settings"
    StatsDialog -> "Stats"
  }
}

/// Activate a Steam overlay dialog.
///
/// Opens the Steam overlay to a specific dialog.
///
/// ## Example
///
/// ```gleam
/// // Open achievements dialog
/// vapour.activate_dialog(client, AchievementsDialog)
///
/// // Open friends list
/// vapour.activate_dialog(client, FriendsDialog)
/// ```
pub fn activate_dialog(client: SteamworksClient, dialog: Dialog) {
  do_activate_dialog(client, dialog_to_string(dialog))
}

@external(javascript, "./vapour.ffi.mjs", "overlayActivateDialog")
fn do_activate_dialog(client: SteamworksClient, dialog: String) -> Nil

/// Activate the Steam overlay to a specific user's profile.
///
/// ## Parameters
///
/// - `steam_id` The user's Steam ID 
///
/// ## Example
///
/// ```gleam
/// // Open a friend's profile
/// vapour.activate_user_page_dialog(client, steam_id)
/// ```
pub fn activate_user_page_dialog(client: SteamworksClient, steam_id: SteamId) {
  let SteamId(id) = steam_id
  do_activate_user_page_dialog(client, "steam_id", id)
}

@external(javascript, "./vapour.ffi.mjs", "overlayActivateDialogToUser")
pub fn do_activate_user_page_dialog(
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

/// Open the Steam overlay invite dialog for a lobby.
///
/// Opens the invite dialog where players can select friends to invite to the specified lobby.
/// Essential for multiplayer games.
///
/// ## Parameters
///
/// - `lobby_steam_id`: The Steam ID of the lobby to invite friends to
///
/// ## Example
///
/// ```gleam
/// // Open invite dialog for a lobby
/// vapour.invite_friends_to_lobby(client, "109775241021923456")
/// ```
@external(javascript, "./vapour.ffi.mjs", "overlayActivateInviteDialog")
pub fn invite_friends_to_lobby(
  client: SteamworksClient,
  lobby_steam_id: String,
) -> Nil

/// Open the Steam overlay invite dialog with a custom connect string.
///
/// Opens the invite dialog and sends the connect string with the invitation.
/// When friends accept, they receive this connect string (e.g., server IP, session ID).
///
/// ## Parameters
///
/// - `connect_string`: Custom connection information (e.g., "+connect 192.168.1.100:27015")
///
/// ## Example
///
/// ```gleam
/// // Invite with server connection info
/// let connect_str = "+connect 192.168.1.100:27015"
/// vapour.invite_friends_with_connect_string(client, connect_str)
///
/// // Invite with session ID
/// let connect_str = "+join_session abc123-def456"
/// vapour.invite_friends_with_connect_string(client, connect_str)
/// ```
@external(javascript, "./vapour.ffi.mjs", "overlayActivateInviteDialogConnectString")
pub fn invite_friends_with_connect_string(
  client: SteamworksClient,
  connect_string: String,
) -> Nil

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
/// vapour.stat_int(client, "total_kills")
/// |> promise.await(fn(result) {
///   case result {
///     Ok(kills) -> io.println("Total kills: " <> int.to_string(kills))
///     Error(_) -> io.println("Stat not found")
///   }
///   promise.resolve(Nil)
/// })
/// ```
@external(javascript, "./vapour.ffi.mjs", "statsGetInt")
pub fn stat_int(
  client: SteamworksClient,
  stat_name: String,
) -> promise.Promise(Result(Int, Nil))

/// Get a float stat value for the current user (async).
///
/// Returns a Promise that resolves to the stat value, or `Error(Nil)` if not found.
///
/// ## Example
///
/// ```gleam
/// import gleam/javascript/promise
///
/// vapour.stat_float(client, "accuracy")
/// |> promise.await(fn(result) {
///   case result {
///     Ok(accuracy) -> io.println("Accuracy: " <> float.to_string(accuracy))
///     Error(_) -> io.println("Stat not found")
///   }
///   promise.resolve(Nil)
/// })
/// ```
@external(javascript, "./vapour.ffi.mjs", "statsGetFloat")
pub fn stat_float(
  client: SteamworksClient,
  stat_name: String,
) -> promise.Promise(Result(Float, Nil))

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
/// vapour.number_of_current_players(client)
/// |> promise.await(fn(result) {
///   case result {
///     Ok(count) -> io.println(int.to_string(count) <> " players online!")
///     Error(_) -> io.println("Failed to get player count")
///   }
///   promise.resolve(Nil)
/// })
/// ```
@external(javascript, "./vapour.ffi.mjs", "statsGetNumberOfCurrentPlayers")
pub fn number_of_current_players(
  client: SteamworksClient,
) -> promise.Promise(Result(Int, Nil))

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
/// let state = vapour.persona_state(client)
/// case state {
///   vapour.Online -> io.println("You are online")
///   vapour.Offline -> io.println("You appear offline")
///   _ -> io.println("Other status")
/// }
/// ```
pub fn persona_state(client: SteamworksClient) -> PersonaState {
  let state_int = get_persona_state(client)
  int_to_persona_state(state_int)
}

@external(javascript, "./vapour.ffi.mjs", "friendsGetPersonaState")
fn get_persona_state(client: SteamworksClient) -> Int

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
/// let count = vapour.friend_count(client)
/// io.println("You have " <> int.to_string(count) <> " friends")
/// ```
@external(javascript, "./vapour.ffi.mjs", "friendsGetFriendCount")
pub fn friend_count(client: SteamworksClient) -> Int

pub type SteamId {
  SteamId(String)
}

/// Get a friend's persona name (display name).
///
/// Returns the friend's Steam display name.
///
/// ## Example
///
/// ```gleam
/// let name = vapour.friend_persona_name(client, "76561197960287930")
/// io.println("Friend name: " <> name)
/// ```
@external(javascript, "./vapour.ffi.mjs", "friendsGetFriendPersonaName")
pub fn friend_persona_name(client: SteamworksClient, steam_id: String) -> String

/// Get a friend's persona state (online status).
///
/// Returns the friend's current online status.
///
/// ## Example
///
/// ```gleam
/// let state = vapour.friend_persona_state(client, friend_id)
/// case state {
///   vapour.Online -> io.println("Friend is online")
///   vapour.Offline -> io.println("Friend is offline")
///   _ -> io.println("Friend has other status")
/// }
/// ```
pub fn friend_persona_state(
  client: SteamworksClient,
  steam_id: String,
) -> PersonaState {
  let state_int = do_friend_persona_state(client, steam_id)
  int_to_persona_state(state_int)
}

@external(javascript, "./vapour.ffi.mjs", "friendsGetFriendPersonaState")
fn do_friend_persona_state(client: SteamworksClient, steam_id: String) -> Int

/// Get all friends with their information.
///
/// Returns a list of all friends with their Steam ID, name, and online status.
///
/// ## Example
///
/// ```gleam
/// let friends = vapour.all_friends(client)
/// list.each(friends, fn(friend) {
///   io.println(friend.persona_name <> " (" <> friend.steam_id <> ")")
/// })
/// ```
@external(javascript, "./vapour.ffi.mjs", "friendsGetAllFriends")
pub fn all_friends(client: SteamworksClient) -> List(FriendInfo)

/// Get a friend's Steam level.
///
/// Returns the friend's Steam level (0 if unavailable).
///
/// ## Example
///
/// ```gleam
/// let level = vapour.friend_steam_level(client, friend_id)
/// io.println("Friend is Level " <> int.to_string(level))
/// ```
@external(javascript, "./vapour.ffi.mjs", "friendsGetFriendSteamLevel")
pub fn friend_steam_level(client: SteamworksClient, steam_id: String) -> Int

/// Get the game a friend is currently playing.
///
/// Returns the App ID of the game the friend is playing, or `Error(Nil)` if not playing.
///
/// ## Example
///
/// ```gleam
/// case vapour.friend_game_played(client, friend_id) {
///   Ok(app_id) -> io.println("Friend is playing App " <> int.to_string(app_id))
///   Error(_) -> io.println("Friend is not playing any game")
/// }
/// ```
@external(javascript, "./vapour.ffi.mjs", "friendsGetFriendGamePlayed")
pub fn friend_game_played(
  client: SteamworksClient,
  steam_id: String,
) -> Result(Int, Nil)

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
@external(javascript, "./vapour.ffi.mjs", "statsGetGlobalStatInt")
pub fn global_stat_int(
  client: SteamworksClient,
  stat_name: String,
) -> promise.Promise(Result(Int, Nil))

/// Get a global float stat (async).
@external(javascript, "./vapour.ffi.mjs", "statsGetGlobalStatFloat")
pub fn global_stat_float(
  client: SteamworksClient,
  stat_name: String,
) -> promise.Promise(Result(Float, Nil))

/// Request stats for another user (async).
@external(javascript, "./vapour.ffi.mjs", "statsRequestUserStats")
pub fn request_user_stats(
  client: SteamworksClient,
  steam_id: String,
) -> promise.Promise(Bool)

/// Get an integer stat for another user (async).
@external(javascript, "./vapour.ffi.mjs", "statsGetUserStatInt")
pub fn user_stat_int(
  client: SteamworksClient,
  steam_id: String,
  stat_name: String,
) -> promise.Promise(Result(Int, Nil))

/// Get a float stat for another user (async).
@external(javascript, "./vapour.ffi.mjs", "statsGetUserStatFloat")
pub fn user_stat_float(
  client: SteamworksClient,
  steam_id: String,
  stat_name: String,
) -> promise.Promise(Result(Float, Nil))

// ============================================================================
// Advanced Friends API
// ============================================================================

/// Get the relationship with another user.
pub fn friend_relationship(
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
pub fn coplay_friend_count(client: SteamworksClient) -> Int

/// Get when you last played with a user (Unix timestamp).
@external(javascript, "./vapour.ffi.mjs", "friendsGetFriendCoplayTime")
pub fn friend_coplay_time(client: SteamworksClient, steam_id: String) -> Int

/// Get the App ID of the game you last played with a user.
@external(javascript, "./vapour.ffi.mjs", "friendsGetFriendCoplayGame")
pub fn friend_coplay_game(client: SteamworksClient, steam_id: String) -> Int

// ============================================================================
// Leaderboards API (Async)
// ============================================================================

pub type LeaderBoard

/// Find a leaderboard by name (async).
///
/// Returns a leaderboard handle, or `Error(Nil)` if not found.
@external(javascript, "./vapour.ffi.mjs", "leaderboardsFindLeaderboard")
pub fn find_leaderboard(
  client: SteamworksClient,
  leaderboard_name: String,
) -> promise.Promise(Result(LeaderBoard, Nil))

/// Find or create a leaderboard with sort and display settings (async).
///
/// Searches for a leaderboard by name and creates it if it doesn't exist.
/// Allows you to specify how scores are sorted and displayed.
///
/// ## Parameters
///
/// - `name`: Leaderboard name (max 128 UTF-8 bytes)
/// - `sort_method`: How entries should be sorted (Ascending for times, Descending for scores)
/// - `display_type`: How scores should be displayed (Numeric, TimeSeconds, etc.)
///
/// ## Returns
///
/// A Promise that resolves to `Ok(leaderboard)` or `Error(Nil)`.
///
/// ## Example
///
/// ```gleam
/// import gleam/javascript/promise
/// import vapour.{Descending, Numeric}
///
/// // Create a high score leaderboard
/// vapour.find_or_create_leaderboard(client, "HighScores", Descending, Numeric)
/// |> promise.await(fn(result) {
///   case result {
///     Ok(leaderboard) -> io.println("Leaderboard ready")
///     Error(_) -> io.println("Failed to create leaderboard")
///   }
///   promise.resolve(Nil)
/// })
///
/// // Create a speedrun leaderboard (lower time is better)
/// vapour.find_or_create_leaderboard(client, "Speedrun", Ascending, TimeSeconds)
/// |> promise.await(fn(result) {
///   case result {
///     Ok(lb) -> io.println("Speedrun leaderboard ready")
///     Error(_) -> io.println("Failed")
///   }
///   promise.resolve(Nil)
/// })
/// ```
pub fn find_or_create_leaderboard(
  client: SteamworksClient,
  name: String,
  sort_method: LeaderboardSortMethod,
  display_type: LeaderboardDisplayType,
) -> promise.Promise(Result(LeaderBoard, Nil)) {
  let sort_int = leaderboard_sort_method_to_int(sort_method)
  let display_int = leaderboard_display_type_to_int(display_type)
  do_find_or_create_leaderboard(client, name, sort_int, display_int)
}

@external(javascript, "./vapour.ffi.mjs", "leaderboardsFindOrCreateLeaderboard")
fn do_find_or_create_leaderboard(
  client: SteamworksClient,
  name: String,
  sort_method: Int,
  display_type: Int,
) -> promise.Promise(Result(LeaderBoard, Nil))

fn leaderboard_sort_method_to_int(method: LeaderboardSortMethod) -> Int {
  case method {
    SortNone -> 0
    Ascending -> 1
    Descending -> 2
  }
}

fn leaderboard_display_type_to_int(display: LeaderboardDisplayType) -> Int {
  case display {
    DisplayNone -> 0
    Numeric -> 1
    TimeSeconds -> 2
    TimeMilliseconds -> 3
  }
}

/// Upload a score to a leaderboard (async).
pub fn upload_score(
  client: SteamworksClient,
  leaderboard_handle: LeaderBoard,
  score: Int,
  upload_method: UploadScoreMethod,
) -> promise.Promise(Bool) {
  let method_int = upload_score_method_to_int(upload_method)
  do_upload_score(client, leaderboard_handle, score, method_int)
}

@external(javascript, "./vapour.ffi.mjs", "leaderboardsUploadScore")
fn do_upload_score(
  client: SteamworksClient,
  leaderboard_handle: LeaderBoard,
  score: Int,
  upload_method: Int,
) -> promise.Promise(Bool)

fn upload_score_method_to_int(method: UploadScoreMethod) -> Int {
  case method {
    KeepBest -> 1
    ForceUpdate -> 2
  }
}

/// Download leaderboard entries (async).
pub fn download_scores(
  client: SteamworksClient,
  leaderboard_handle: LeaderBoard,
  data_request: LeaderboardDataRequest,
  start: Int,
  end: Int,
) -> promise.Promise(List(LeaderboardEntry)) {
  let request_int = leaderboard_data_request_to_int(data_request)
  do_download_scores(client, leaderboard_handle, request_int, start, end)
}

@external(javascript, "./vapour.ffi.mjs", "leaderboardsDownloadScores")
fn do_download_scores(
  client: SteamworksClient,
  leaderboard_handle: LeaderBoard,
  data_request: Int,
  start: Int,
  end: Int,
) -> promise.Promise(List(LeaderboardEntry))

fn leaderboard_data_request_to_int(request: LeaderboardDataRequest) -> Int {
  case request {
    Global -> 0
    GlobalAroundUser -> 1
    Friends -> 2
  }
}

/// Get the entry count for a leaderboard.
@external(javascript, "./vapour.ffi.mjs", "leaderboardsGetEntryCount")
pub fn get_leaderboard_entry_count(
  client: SteamworksClient,
  leaderboard_handle: LeaderBoard,
) -> Int

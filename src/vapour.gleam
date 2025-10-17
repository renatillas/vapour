// Core Vapour module - Steamworks.js bindings for Gleam
//
// This module provides the main initialization and lifecycle functions
// for the Steamworks API.

import gleam/option.{type Option}

/// Opaque type representing the Steamworks client
pub opaque type Client {
  Client(internal: SteamworksClient)
}

/// Internal FFI type
type SteamworksClient

/// Initialize the Steamworks API
///
/// If app_id is None, Steamworks will look for a steam_appid.txt file
/// in the current directory.
///
/// Returns Error if Steam is not running or initialization fails.
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import gleam/option
///
/// pub fn main() {
///   // Initialize with app ID 480 (Spacewar, Steam's test app)
///   let assert Ok(client) = vapour.init(option.Some(480))
///
///   // Or let it read from steam_appid.txt
///   let assert Ok(client) = vapour.init(option.None)
/// }
/// ```
pub fn init(app_id: Option(Int)) -> Result(Client, Nil) {
  case app_id {
    option.Some(id) -> {
      let client = do_init(id)
      Ok(Client(client))
    }
    option.None -> {
      let client = do_init_default()
      Ok(Client(client))
    }
  }
}

@external(javascript, "./steamworks.ffi.mjs", "init")
fn do_init(app_id: Int) -> SteamworksClient

fn do_init_default() -> SteamworksClient {
  do_init_null()
}

@external(javascript, "./steamworks.ffi.mjs", "init")
fn do_init_null() -> SteamworksClient

/// Restart the app if it wasn't launched through Steam
///
/// This function checks if your executable was launched through Steam.
/// If it wasn't, it will restart your app through Steam.
///
/// Returns True if the app needs to restart (in which case you should
/// exit immediately), False if the app was launched through Steam.
///
/// ## Example
///
/// ```gleam
/// import vapour
///
/// pub fn main() {
///   // Check if we need to restart through Steam
///   case vapour.restart_app_if_necessary(480) {
///     True -> {
///       // App will restart through Steam, exit now
///       Nil
///     }
///     False -> {
///       // All good, continue with normal startup
///       let assert Ok(client) = vapour.init(option.Some(480))
///       // ...
///     }
///   }
/// }
/// ```
pub fn restart_app_if_necessary(app_id: Int) -> Bool {
  do_restart_app_if_necessary(app_id)
}

@external(javascript, "./steamworks.ffi.mjs", "restartAppIfNecessary")
fn do_restart_app_if_necessary(app_id: Int) -> Bool

/// Run Steam callbacks
///
/// This should be called regularly (ideally every frame) to process
/// Steam callbacks and keep the connection alive.
///
/// ## Example
///
/// ```gleam
/// import vapour
///
/// pub fn game_loop() {
///   // Process Steam callbacks each frame
///   vapour.run_callbacks()
///
///   // Rest of your game loop...
/// }
/// ```
pub fn run_callbacks() -> Nil {
  do_run_callbacks()
}

@external(javascript, "./steamworks.ffi.mjs", "runCallbacks")
fn do_run_callbacks() -> Nil

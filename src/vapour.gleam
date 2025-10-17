// Core Vapour module - Steamworks.js bindings for Gleam
//
// This module provides the main initialization and lifecycle functions
// for the Steamworks API.

import gleam/option.{type Option}

/// Opaque type representing the Steamworks client
pub opaque type Client {
  Client(internal: SteamworksClient)
}

/// Internal FFI type - exposed for use by submodules
pub type SteamworksClient

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

/// Run Steam callbacks
///
/// This should be called regularly (ideally every frame) to process
/// Steam callbacks and keep the connection alive.
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import gleam/option
///
/// pub fn game_loop(client: vapour.Client) {
///   // Process Steam callbacks each frame
///   vapour.run_callbacks(client)
///
///   // Rest of your game loop...
/// }
/// ```
pub fn run_callbacks(client: Client) -> Nil {
  do_run_callbacks(client.internal)
}

@external(javascript, "./steamworks.ffi.mjs", "runCallbacks")
fn do_run_callbacks(client: SteamworksClient) -> Nil

/// Get the internal client reference for passing to submodules
///
/// This is used internally by vapour modules to access the Steam client.
/// You don't typically need to call this directly.
pub fn get_client(client: Client) -> SteamworksClient {
  client.internal
}

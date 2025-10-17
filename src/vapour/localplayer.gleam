// Local Player API - Information about the current Steam user

import gleam/option.{type Option}

/// Represents a Steam ID in various formats
pub type SteamId {
  SteamId(steam_id_64: String, steam_id_32: String, account_id: Int)
}

/// Get the local player's Steam ID
///
/// Returns the Steam ID of the currently logged in user in multiple formats.
///
/// ## Example
///
/// ```gleam
/// import vapour/localplayer
/// import gleam/io
///
/// pub fn show_player_info() {
///   let id = localplayer.get_steam_id()
///   io.println("Steam ID 64: " <> id.steam_id_64)
///   io.println("Steam ID 32: " <> id.steam_id_32)
/// }
/// ```
pub fn get_steam_id() -> SteamId {
  do_get_steam_id()
}

@external(javascript, "../steamworks.ffi.mjs", "localplayerGetSteamId")
fn do_get_steam_id() -> SteamId

/// Get the local player's display name
///
/// Returns the persona name (display name) of the currently logged in user.
///
/// ## Example
///
/// ```gleam
/// import vapour/localplayer
/// import gleam/io
///
/// pub fn greet_player() {
///   let name = localplayer.get_name()
///   io.println("Hello, " <> name <> "!")
/// }
/// ```
pub fn get_name() -> String {
  do_get_name()
}

@external(javascript, "../steamworks.ffi.mjs", "localplayerGetName")
fn do_get_name() -> String

/// Get the local player's Steam level
///
/// Returns the Steam community level of the currently logged in user.
///
/// ## Example
///
/// ```gleam
/// import vapour/localplayer
/// import gleam/int
/// import gleam/io
///
/// pub fn show_level() {
///   let level = localplayer.get_level()
///   io.println("Steam Level: " <> int.to_string(level))
/// }
/// ```
pub fn get_level() -> Int {
  do_get_level()
}

@external(javascript, "../steamworks.ffi.mjs", "localplayerGetLevel")
fn do_get_level() -> Int

/// Get the local player's IP country
///
/// Returns the two-letter country code for the country the user is currently in.
///
/// ## Example
///
/// ```gleam
/// import vapour/localplayer
/// import gleam/io
///
/// pub fn show_country() {
///   let country = localplayer.get_ip_country()
///   io.println("Country: " <> country)
/// }
/// ```
pub fn get_ip_country() -> String {
  do_get_ip_country()
}

@external(javascript, "../steamworks.ffi.mjs", "localplayerGetIpCountry")
fn do_get_ip_country() -> String

/// Set Rich Presence data
///
/// Sets a Rich Presence key/value pair for the current user. This will be
/// visible to other users in their Steam overlay when viewing your profile.
///
/// Pass None for the value to clear the key.
///
/// ## Example
///
/// ```gleam
/// import vapour/localplayer
/// import gleam/option
///
/// pub fn update_status() {
///   // Set status
///   localplayer.set_rich_presence("status", option.Some("In Main Menu"))
///
///   // Clear status
///   localplayer.set_rich_presence("status", option.None)
/// }
/// ```
pub fn set_rich_presence(key: String, value: Option(String)) -> Nil {
  case value {
    option.Some(v) -> do_set_rich_presence(key, v)
    option.None -> do_clear_rich_presence(key)
  }
}

@external(javascript, "../steamworks.ffi.mjs", "localplayerSetRichPresence")
fn do_set_rich_presence(key: String, value: String) -> Nil

fn do_clear_rich_presence(key: String) -> Nil {
  do_set_rich_presence_undefined(key)
}

@external(javascript, "../steamworks.ffi.mjs", "localplayerSetRichPresence")
fn do_set_rich_presence_undefined(key: String) -> Nil

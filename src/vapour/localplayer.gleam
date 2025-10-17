// Copyright (c) 2025 Renata Amutio
// SPDX-License-Identifier: MIT
//
// Local Player API - Information about the current Steam user

import gleam/option.{type Option}
import vapour

/// Get the local player's display name
///
/// Returns the persona name (display name) of the currently logged in user.
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/localplayer
/// import gleam/io
/// import gleam/option
///
/// pub fn greet_player(client: vapour.Client) {
///   let name = localplayer.get_name(client)
///   io.println("Hello, " <> name <> "!")
/// }
/// ```
pub fn get_name(client: vapour.Client) -> String {
  do_get_name(vapour.get_client(client))
}

@external(javascript, "../steamworks.ffi.mjs", "localplayerGetName")
fn do_get_name(client: vapour.SteamworksClient) -> String

/// Set Rich Presence data
///
/// Sets a Rich Presence key/value pair for the current user. This will be
/// visible to other users in their Steam overlay when viewing your profile.
///
/// Pass None for the value to clear all Rich Presence data.
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/localplayer
/// import gleam/option
///
/// pub fn update_status(client: vapour.Client) {
///   // Set status
///   localplayer.set_rich_presence(client, "status", option.Some("In Main Menu"))
///
///   // Clear all rich presence
///   localplayer.set_rich_presence(client, "status", option.None)
/// }
/// ```
pub fn set_rich_presence(
  client: vapour.Client,
  key: String,
  value: Option(String),
) -> Nil {
  case value {
    option.Some(v) -> do_set_rich_presence(vapour.get_client(client), key, v)
    option.None -> do_clear_rich_presence(vapour.get_client(client))
  }
}

@external(javascript, "../steamworks.ffi.mjs", "localplayerSetRichPresence")
fn do_set_rich_presence(
  client: vapour.SteamworksClient,
  key: String,
  value: String,
) -> Nil

@external(javascript, "../steamworks.ffi.mjs", "localplayerClearRichPresence")
fn do_clear_rich_presence(client: vapour.SteamworksClient) -> Nil

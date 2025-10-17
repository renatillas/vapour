// Copyright (c) 2025 Renata Amutio
// SPDX-License-Identifier: MIT
//
// Achievement API - Manage Steam achievements

import vapour

/// Activate (unlock) an achievement
///
/// Returns True if the achievement was successfully activated,
/// False otherwise.
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/achievement
/// import gleam/option
///
/// pub fn complete_level(client: vapour.Client) {
///   case achievement.activate(client, "ACH_WIN_ONE_GAME") {
///     True -> io.println("Achievement unlocked!")
///     False -> io.println("Failed to unlock achievement")
///   }
/// }
/// ```
pub fn activate(client: vapour.Client, achievement: String) -> Bool {
  do_activate(vapour.get_client(client), achievement)
}

@external(javascript, "../steamworks.ffi.mjs", "achievementActivate")
fn do_activate(client: vapour.SteamworksClient, achievement: String) -> Bool

/// Check if an achievement is activated
///
/// Returns True if the achievement has been unlocked, False otherwise.
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/achievement
/// import gleam/option
///
/// pub fn check_achievement(client: vapour.Client) {
///   case achievement.is_activated(client, "ACH_WIN_ONE_GAME") {
///     True -> io.println("Already unlocked")
///     False -> io.println("Not yet unlocked")
///   }
/// }
/// ```
pub fn is_activated(client: vapour.Client, achievement: String) -> Bool {
  do_is_activated(vapour.get_client(client), achievement)
}

@external(javascript, "../steamworks.ffi.mjs", "achievementIsActivated")
fn do_is_activated(client: vapour.SteamworksClient, achievement: String) -> Bool

/// Clear (lock) an achievement
///
/// This is primarily useful for testing. Returns True if the achievement
/// was successfully cleared, False otherwise.
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/achievement
/// import gleam/option
///
/// pub fn reset_achievements(client: vapour.Client) {
///   achievement.clear(client, "ACH_WIN_ONE_GAME")
/// }
/// ```
pub fn clear(client: vapour.Client, achievement: String) -> Bool {
  do_clear(vapour.get_client(client), achievement)
}

@external(javascript, "../steamworks.ffi.mjs", "achievementClear")
fn do_clear(client: vapour.SteamworksClient, achievement: String) -> Bool

/// Get a list of all achievement names
///
/// Returns a list of all achievement IDs defined for this app.
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/achievement
/// import gleam/list
/// import gleam/io
/// import gleam/option
///
/// pub fn list_all_achievements(client: vapour.Client) {
///   achievement.names(client)
///   |> list.each(io.println)
/// }
/// ```
pub fn names(client: vapour.Client) -> List(String) {
  do_names(vapour.get_client(client))
}

@external(javascript, "../steamworks.ffi.mjs", "achievementNames")
fn do_names(client: vapour.SteamworksClient) -> List(String)

// Steam Overlay API - Control the Steam overlay

import vapour

/// Activate a Steam overlay dialog
///
/// Opens the Steam overlay to a specific dialog.
///
/// Common dialog values:
/// - "Friends" - Friends list
/// - "Community" - Community hub
/// - "Players" - Recently played with players
/// - "Settings" - Steam settings
/// - "OfficialGameGroup" - Game's official group
/// - "Stats" - Game stats
/// - "Achievements" - Achievement list
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/overlay
/// import gleam/option
///
/// pub fn show_achievements(client: vapour.Client) {
///   overlay.activate_dialog(client, "Achievements")
/// }
/// ```
pub fn activate_dialog(client: vapour.Client, dialog: String) -> Nil {
  do_activate_dialog(vapour.get_client(client), dialog)
}

@external(javascript, "../steamworks.ffi.mjs", "overlayActivateDialog")
fn do_activate_dialog(client: vapour.SteamworksClient, dialog: String) -> Nil

/// Activate the Steam overlay to a user
///
/// Opens the Steam overlay showing the specified user's profile.
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/overlay
/// import gleam/option
///
/// pub fn show_friend_profile(client: vapour.Client, steam_id: String) {
///   overlay.activate_dialog_to_user(client, "steamid", steam_id)
/// }
/// ```
pub fn activate_dialog_to_user(
  client: vapour.Client,
  dialog: String,
  steam_id_64: String,
) -> Nil {
  do_activate_dialog_to_user(vapour.get_client(client), dialog, steam_id_64)
}

@external(javascript, "../steamworks.ffi.mjs", "overlayActivateDialogToUser")
fn do_activate_dialog_to_user(
  client: vapour.SteamworksClient,
  dialog: String,
  steam_id_64: String,
) -> Nil

/// Activate the Steam overlay to a web page
///
/// Opens the Steam overlay browser to the specified URL.
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/overlay
/// import gleam/option
///
/// pub fn show_website(client: vapour.Client) {
///   overlay.activate_web_page(client, "https://example.com")
/// }
/// ```
pub fn activate_web_page(client: vapour.Client, url: String) -> Nil {
  do_activate_web_page(vapour.get_client(client), url)
}

@external(javascript, "../steamworks.ffi.mjs", "overlayActivateWebPage")
fn do_activate_web_page(client: vapour.SteamworksClient, url: String) -> Nil

/// Activate the Steam overlay to a store page
///
/// Opens the Steam overlay to the store page for the specified app.
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/overlay
/// import gleam/option
///
/// pub fn show_store_dlc(client: vapour.Client) {
///   overlay.activate_store(client, 12345)
/// }
/// ```
pub fn activate_store(client: vapour.Client, app_id: Int) -> Nil {
  do_activate_store(vapour.get_client(client), app_id)
}

@external(javascript, "../steamworks.ffi.mjs", "overlayActivateStore")
fn do_activate_store(client: vapour.SteamworksClient, app_id: Int) -> Nil

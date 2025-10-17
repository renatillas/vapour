// Apps API - Information about Steam applications

import gleam/option.{type Option}
import vapour/localplayer.{type SteamId}

/// Check if the user is subscribed to a specific app
pub fn is_subscribed_app(app_id: Int) -> Bool {
  do_is_subscribed_app(app_id)
}

@external(javascript, "../steamworks.ffi.mjs", "appsIsSubscribedApp")
fn do_is_subscribed_app(app_id: Int) -> Bool

/// Check if an app is installed
pub fn is_app_installed(app_id: Int) -> Bool {
  do_is_app_installed(app_id)
}

@external(javascript, "../steamworks.ffi.mjs", "appsIsAppInstalled")
fn do_is_app_installed(app_id: Int) -> Bool

/// Check if a DLC is installed
pub fn is_dlc_installed(app_id: Int) -> Bool {
  do_is_dlc_installed(app_id)
}

@external(javascript, "../steamworks.ffi.mjs", "appsIsDlcInstalled")
fn do_is_dlc_installed(app_id: Int) -> Bool

/// Check if the user is playing during a free weekend
pub fn is_subscribed_from_free_weekend() -> Bool {
  do_is_subscribed_from_free_weekend()
}

@external(javascript, "../steamworks.ffi.mjs", "appsIsSubscribedFromFreeWeekend")
fn do_is_subscribed_from_free_weekend() -> Bool

/// Check if the user has a VAC ban on their account
pub fn is_vac_banned() -> Bool {
  do_is_vac_banned()
}

@external(javascript, "../steamworks.ffi.mjs", "appsIsVacBanned")
fn do_is_vac_banned() -> Bool

/// Check if the game is being run from a cybercafe
pub fn is_cybercafe() -> Bool {
  do_is_cybercafe()
}

@external(javascript, "../steamworks.ffi.mjs", "appsIsCybercafe")
fn do_is_cybercafe() -> Bool

/// Check if the game is a low violence version
pub fn is_low_violence() -> Bool {
  do_is_low_violence()
}

@external(javascript, "../steamworks.ffi.mjs", "appsIsLowViolence")
fn do_is_low_violence() -> Bool

/// Check if the user is subscribed to the current app
pub fn is_subscribed() -> Bool {
  do_is_subscribed()
}

@external(javascript, "../steamworks.ffi.mjs", "appsIsSubscribed")
fn do_is_subscribed() -> Bool

/// Get the current app's build ID
pub fn app_build_id() -> Int {
  do_app_build_id()
}

@external(javascript, "../steamworks.ffi.mjs", "appsAppBuildId")
fn do_app_build_id() -> Int

/// Get the installation directory for an app
pub fn app_install_dir(app_id: Int) -> String {
  do_app_install_dir(app_id)
}

@external(javascript, "../steamworks.ffi.mjs", "appsAppInstallDir")
fn do_app_install_dir(app_id: Int) -> String

/// Get the Steam ID of the original owner of the current app
///
/// This is useful for detecting if the app is being played via Family Sharing.
pub fn app_owner() -> SteamId {
  do_app_owner()
}

@external(javascript, "../steamworks.ffi.mjs", "appsAppOwner")
fn do_app_owner() -> SteamId

/// Get a list of available game languages
pub fn available_game_languages() -> List(String) {
  do_available_game_languages()
}

@external(javascript, "../steamworks.ffi.mjs", "appsAvailableGameLanguages")
fn do_available_game_languages() -> List(String)

/// Get the current game language
pub fn current_game_language() -> String {
  do_current_game_language()
}

@external(javascript, "../steamworks.ffi.mjs", "appsCurrentGameLanguage")
fn do_current_game_language() -> String

/// Get the current beta name, if the user is in a beta
///
/// Returns None if the user is not in a beta branch.
pub fn current_beta_name() -> Option(String) {
  case do_current_beta_name() {
    "" -> option.None
    name -> option.Some(name)
  }
}

@external(javascript, "../steamworks.ffi.mjs", "appsCurrentBetaName")
fn do_current_beta_name() -> String

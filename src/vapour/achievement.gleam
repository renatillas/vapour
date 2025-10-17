// Achievement API - Manage Steam achievements

/// Activate (unlock) an achievement
///
/// Returns True if the achievement was successfully activated,
/// False otherwise.
///
/// ## Example
///
/// ```gleam
/// import vapour/achievement
///
/// pub fn complete_level() {
///   case achievement.activate("ACH_WIN_ONE_GAME") {
///     True -> io.println("Achievement unlocked!")
///     False -> io.println("Failed to unlock achievement")
///   }
/// }
/// ```
pub fn activate(achievement: String) -> Bool {
  do_activate(achievement)
}

@external(javascript, "../steamworks.ffi.mjs", "achievementActivate")
fn do_activate(achievement: String) -> Bool

/// Check if an achievement is activated
///
/// Returns True if the achievement has been unlocked, False otherwise.
///
/// ## Example
///
/// ```gleam
/// import vapour/achievement
///
/// pub fn check_achievement() {
///   case achievement.is_activated("ACH_WIN_ONE_GAME") {
///     True -> io.println("Already unlocked")
///     False -> io.println("Not yet unlocked")
///   }
/// }
/// ```
pub fn is_activated(achievement: String) -> Bool {
  do_is_activated(achievement)
}

@external(javascript, "../steamworks.ffi.mjs", "achievementIsActivated")
fn do_is_activated(achievement: String) -> Bool

/// Clear (lock) an achievement
///
/// This is primarily useful for testing. Returns True if the achievement
/// was successfully cleared, False otherwise.
///
/// ## Example
///
/// ```gleam
/// import vapour/achievement
///
/// pub fn reset_achievements() {
///   achievement.clear("ACH_WIN_ONE_GAME")
/// }
/// ```
pub fn clear(achievement: String) -> Bool {
  do_clear(achievement)
}

@external(javascript, "../steamworks.ffi.mjs", "achievementClear")
fn do_clear(achievement: String) -> Bool

/// Get a list of all achievement names
///
/// Returns a list of all achievement IDs defined for this app.
///
/// ## Example
///
/// ```gleam
/// import vapour/achievement
/// import gleam/list
/// import gleam/io
///
/// pub fn list_all_achievements() {
///   achievement.names()
///   |> list.each(io.println)
/// }
/// ```
pub fn names() -> List(String) {
  do_names()
}

@external(javascript, "../steamworks.ffi.mjs", "achievementNames")
fn do_names() -> List(String)

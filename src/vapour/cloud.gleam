// Cloud API - Steam Cloud save file management

import vapour

/// Represents information about a cloud file
pub type FileInfo {
  FileInfo(name: String, size: String)
}

/// Check if Steam Cloud is enabled for the current user
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/cloud
/// import gleam/option
///
/// pub fn check_cloud(client: vapour.Client) {
///   case cloud.is_enabled_for_account(client) {
///     True -> io.println("Cloud enabled")
///     False -> io.println("Cloud disabled")
///   }
/// }
/// ```
pub fn is_enabled_for_account(client: vapour.Client) -> Bool {
  do_is_enabled_for_account(vapour.get_client(client))
}

@external(javascript, "../steamworks.ffi.mjs", "cloudIsEnabledForAccount")
fn do_is_enabled_for_account(client: vapour.SteamworksClient) -> Bool

/// Check if Steam Cloud is enabled for the current app
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/cloud
/// import gleam/option
///
/// pub fn check_app_cloud(client: vapour.Client) {
///   case cloud.is_enabled_for_app(client) {
///     True -> io.println("Cloud enabled for app")
///     False -> io.println("Cloud disabled for app")
///   }
/// }
/// ```
pub fn is_enabled_for_app(client: vapour.Client) -> Bool {
  do_is_enabled_for_app(vapour.get_client(client))
}

@external(javascript, "../steamworks.ffi.mjs", "cloudIsEnabledForApp")
fn do_is_enabled_for_app(client: vapour.SteamworksClient) -> Bool

/// Enable or disable Steam Cloud for the current app
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/cloud
/// import gleam/option
///
/// pub fn toggle_cloud(client: vapour.Client, enabled: Bool) {
///   cloud.set_enabled_for_app(client, enabled)
/// }
/// ```
pub fn set_enabled_for_app(client: vapour.Client, enabled: Bool) -> Nil {
  do_set_enabled_for_app(vapour.get_client(client), enabled)
}

@external(javascript, "../steamworks.ffi.mjs", "cloudSetEnabledForApp")
fn do_set_enabled_for_app(client: vapour.SteamworksClient, enabled: Bool) -> Nil

/// Read a file from Steam Cloud
///
/// Returns the file contents as a string.
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/cloud
/// import gleam/option
///
/// pub fn load_save(client: vapour.Client) {
///   let save_data = cloud.read_file(client, "save.json")
///   // Parse and use save_data
/// }
/// ```
pub fn read_file(client: vapour.Client, name: String) -> String {
  do_read_file(vapour.get_client(client), name)
}

@external(javascript, "../steamworks.ffi.mjs", "cloudReadFile")
fn do_read_file(client: vapour.SteamworksClient, name: String) -> String

/// Write a file to Steam Cloud
///
/// Returns True if the file was successfully written, False otherwise.
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/cloud
/// import gleam/option
///
/// pub fn save_game(client: vapour.Client, data: String) {
///   case cloud.write_file(client, "save.json", data) {
///     True -> io.println("Game saved!")
///     False -> io.println("Failed to save")
///   }
/// }
/// ```
pub fn write_file(client: vapour.Client, name: String, content: String) -> Bool {
  do_write_file(vapour.get_client(client), name, content)
}

@external(javascript, "../steamworks.ffi.mjs", "cloudWriteFile")
fn do_write_file(
  client: vapour.SteamworksClient,
  name: String,
  content: String,
) -> Bool

/// Delete a file from Steam Cloud
///
/// Returns True if the file was successfully deleted, False otherwise.
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/cloud
/// import gleam/option
///
/// pub fn delete_save(client: vapour.Client) {
///   cloud.delete_file(client, "save.json")
/// }
/// ```
pub fn delete_file(client: vapour.Client, name: String) -> Bool {
  do_delete_file(vapour.get_client(client), name)
}

@external(javascript, "../steamworks.ffi.mjs", "cloudDeleteFile")
fn do_delete_file(client: vapour.SteamworksClient, name: String) -> Bool

/// Check if a file exists in Steam Cloud
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/cloud
/// import gleam/option
///
/// pub fn has_save(client: vapour.Client) -> Bool {
///   cloud.file_exists(client, "save.json")
/// }
/// ```
pub fn file_exists(client: vapour.Client, name: String) -> Bool {
  do_file_exists(vapour.get_client(client), name)
}

@external(javascript, "../steamworks.ffi.mjs", "cloudFileExists")
fn do_file_exists(client: vapour.SteamworksClient, name: String) -> Bool

/// List all files in Steam Cloud
///
/// Returns a list of FileInfo records containing name and size information.
///
/// ## Example
///
/// ```gleam
/// import vapour
/// import vapour/cloud
/// import gleam/list
/// import gleam/io
/// import gleam/option
///
/// pub fn list_saves(client: vapour.Client) {
///   cloud.list_files(client)
///   |> list.each(fn(file) {
///     io.println(file.name <> " (" <> file.size <> " bytes)")
///   })
/// }
/// ```
pub fn list_files(client: vapour.Client) -> List(FileInfo) {
  do_list_files(vapour.get_client(client))
}

@external(javascript, "../steamworks.ffi.mjs", "cloudListFiles")
fn do_list_files(client: vapour.SteamworksClient) -> List(FileInfo)

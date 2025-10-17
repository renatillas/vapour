// Cloud API - Steam Cloud save file management

/// Represents information about a cloud file
pub type FileInfo {
  FileInfo(name: String, size: String)
}

/// Check if Steam Cloud is enabled for the current user
pub fn is_enabled_for_account() -> Bool {
  do_is_enabled_for_account()
}

@external(javascript, "../steamworks.ffi.mjs", "cloudIsEnabledForAccount")
fn do_is_enabled_for_account() -> Bool

/// Check if Steam Cloud is enabled for the current app
pub fn is_enabled_for_app() -> Bool {
  do_is_enabled_for_app()
}

@external(javascript, "../steamworks.ffi.mjs", "cloudIsEnabledForApp")
fn do_is_enabled_for_app() -> Bool

/// Enable or disable Steam Cloud for the current app
///
/// ## Example
///
/// ```gleam
/// import vapour/cloud
///
/// pub fn toggle_cloud(enabled: Bool) {
///   cloud.set_enabled_for_app(enabled)
/// }
/// ```
pub fn set_enabled_for_app(enabled: Bool) -> Nil {
  do_set_enabled_for_app(enabled)
}

@external(javascript, "../steamworks.ffi.mjs", "cloudSetEnabledForApp")
fn do_set_enabled_for_app(enabled: Bool) -> Nil

/// Read a file from Steam Cloud
///
/// Returns the file contents as a string.
///
/// ## Example
///
/// ```gleam
/// import vapour/cloud
///
/// pub fn load_save() {
///   let save_data = cloud.read_file("save.json")
///   // Parse and use save_data
/// }
/// ```
pub fn read_file(name: String) -> String {
  do_read_file(name)
}

@external(javascript, "../steamworks.ffi.mjs", "cloudReadFile")
fn do_read_file(name: String) -> String

/// Write a file to Steam Cloud
///
/// Returns True if the file was successfully written, False otherwise.
///
/// ## Example
///
/// ```gleam
/// import vapour/cloud
///
/// pub fn save_game(data: String) {
///   case cloud.write_file("save.json", data) {
///     True -> io.println("Game saved!")
///     False -> io.println("Failed to save")
///   }
/// }
/// ```
pub fn write_file(name: String, content: String) -> Bool {
  do_write_file(name, content)
}

@external(javascript, "../steamworks.ffi.mjs", "cloudWriteFile")
fn do_write_file(name: String, content: String) -> Bool

/// Delete a file from Steam Cloud
///
/// Returns True if the file was successfully deleted, False otherwise.
///
/// ## Example
///
/// ```gleam
/// import vapour/cloud
///
/// pub fn delete_save() {
///   cloud.delete_file("save.json")
/// }
/// ```
pub fn delete_file(name: String) -> Bool {
  do_delete_file(name)
}

@external(javascript, "../steamworks.ffi.mjs", "cloudDeleteFile")
fn do_delete_file(name: String) -> Bool

/// Check if a file exists in Steam Cloud
///
/// ## Example
///
/// ```gleam
/// import vapour/cloud
///
/// pub fn has_save() -> Bool {
///   cloud.file_exists("save.json")
/// }
/// ```
pub fn file_exists(name: String) -> Bool {
  do_file_exists(name)
}

@external(javascript, "../steamworks.ffi.mjs", "cloudFileExists")
fn do_file_exists(name: String) -> Bool

/// List all files in Steam Cloud
///
/// Returns a list of FileInfo records containing name and size information.
///
/// ## Example
///
/// ```gleam
/// import vapour/cloud
/// import gleam/list
/// import gleam/io
///
/// pub fn list_saves() {
///   cloud.list_files()
///   |> list.each(fn(file) {
///     io.println(file.name <> " (" <> file.size <> " bytes)")
///   })
/// }
/// ```
pub fn list_files() -> List(FileInfo) {
  do_list_files()
}

@external(javascript, "../steamworks.ffi.mjs", "cloudListFiles")
fn do_list_files() -> List(FileInfo)

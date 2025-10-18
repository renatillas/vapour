// Copyright (c) 2025 Renata Amutio
// SPDX-License-Identifier: MIT
//
// Pure 1:1 bindings to steamworks-ffi-node
// No business logic - just thin wrappers around the Steamworks API

// Use nw.require for NW.js compatibility - this loads Node.js modules properly
// Falls back to dynamic import for Node.js ES module environments
let SteamworksModule;
let SteamworksSDK;
if (typeof nw !== 'undefined' && nw.require) {
  // NW.js environment - use nw.require
  SteamworksModule = nw.require("steamworks-ffi-node");

  SteamworksSDK = SteamworksModule.default;
} else {
  // Node.js ES module environment - use dynamic import
  SteamworksModule = await import("steamworks-ffi-node");
  SteamworksSDK = SteamworksModule.default.default;
}

import { toList, Ok, Error, Result } from "./gleam.mjs";
import * as VAPOUR from "./vapour.mjs"

// ============================================================================
// Root Level Functions
// ============================================================================

/**
 * Initialize the Steamworks API
 * @param {number|undefined|null} appId - Optional Steam app ID
 * @returns {SteamworksSDK} The Steamworks SDK instance
 */
export function init(appId) {
  const steamInstance = SteamworksSDK.getInstance()
  const options = appId ? { appId } : { appId: 480 };
  steamInstance.init(options);
  return steamInstance;
}

/**
 * Run Steam callbacks - should be called regularly (e.g., each frame)
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @returns {void}
 */
export function runCallbacks(steamInstance) {
  steamInstance.runCallbacks();
}

/**
 * Get Steam API status information including Steam ID and connection state
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @returns {{is_initialized: boolean, app_id: number, steam_id: string}} Status object
 */
export function getStatus(steamInstance) {
  const status = steamInstance.getStatus();
  // Convert JavaScript camelCase to Gleam snake_case
  return new VAPOUR.Status(
    status.isInitialized,
    status.appId,
    status.steamId
  );
}

/**
 * Check if the Steam client is running
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @returns {boolean} True if Steam is running
 */
export function isSteamRunning(steamInstance) {
  return steamInstance.isSteamRunning();
}

// ============================================================================
// Achievement API
// ============================================================================

/**
 * Unlock an achievement
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} achievement - The achievement API name
 * @returns {Promise<boolean>} True if the achievement was unlocked successfully
 */
export async function achievementActivate(steamInstance, achievement) {
  return await steamInstance.achievements.unlockAchievement(achievement);
}

/**
 * Check if an achievement is unlocked
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} achievement - The achievement API name
 * @returns {Promise<boolean>} True if the achievement is unlocked
 */
export async function achievementIsActivated(steamInstance, achievement) {
  return await steamInstance.achievements.isAchievementUnlocked(achievement);
}

/**
 * Clear (lock) an achievement - primarily for testing
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} achievement - The achievement API name
 * @returns {Promise<boolean>} True if the achievement was cleared successfully
 */
export async function achievementClear(steamInstance, achievement) {
  return await steamInstance.achievements.clearAchievement(achievement);
}

/**
 * Get all achievement names for this app
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @returns {Promise<List<string>>} Gleam list of achievement API names
 */
export async function achievementNames(steamInstance) {
  const achievements = await steamInstance.achievements.getAllAchievements();
  const jsArray = achievements.map(ach => ach.apiName);
  return toList(jsArray);
}

/**
 * Show achievement progress notification
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} achievement - The achievement API name
 * @param {number} currentProgress - Current progress value
 * @param {number} maxProgress - Maximum progress value
 * @returns {Promise<boolean>} True if notification shown successfully
 */
export async function achievementIndicateProgress(steamInstance, achievement, currentProgress, maxProgress) {
  return await steamInstance.achievements.indicateAchievementProgress(achievement, currentProgress, maxProgress);
}

/**
 * Request global achievement unlock percentages
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @returns {Promise<boolean>} True if request sent successfully
 */
export async function achievementRequestGlobalPercentages(steamInstance) {
  return await steamInstance.achievements.requestGlobalAchievementPercentages();
}

/**
 * Get global unlock percentage for an achievement
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} achievement - The achievement API name
 * @returns {Promise<Result<number, Nil>>} Percentage (0-100) or Error if not available
 */
export async function achievementGetAchievedPercent(steamInstance, achievement) {
  const percent = await steamInstance.achievements.getAchievementAchievedPercent(achievement);
  return percent !== null ? new Ok(percent) : new Error(undefined);
}

// ============================================================================
// Cloud API
// ============================================================================

/**
 * Check if Steam Cloud is enabled for the current user's account
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @returns {boolean} True if cloud is enabled for the account
 */
export function cloudIsEnabledForAccount(steamInstance) {
  return steamInstance.cloud.isCloudEnabledForAccount();
}

/**
 * Check if Steam Cloud is enabled for the current app
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @returns {boolean} True if cloud is enabled for the app
 */
export function cloudIsEnabledForApp(steamInstance) {
  return steamInstance.cloud.isCloudEnabledForApp();
}

/**
 * Enable or disable Steam Cloud for the current app
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {boolean} enabled - True to enable, false to disable
 * @returns {void}
 */
export function cloudSetEnabledForApp(steamInstance, enabled) {
  steamInstance.cloud.setCloudEnabledForApp(enabled);
}

/**
 * Read a file from Steam Cloud
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} name - The filename to read
 * @returns {string} File contents as string, or empty string if read failed
 */
export function cloudReadFile(steamInstance, name) {
  const result = steamInstance.cloud.fileRead(name);
  if (result.success && result.data) {
    return result.data.toString();
  }
  return "";
}

/**
 * Write a file to Steam Cloud
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} name - The filename to write
 * @param {string} content - The file content as string
 * @returns {boolean} True if write was successful
 */
export function cloudWriteFile(steamInstance, name, content) {
  const buffer = Buffer.from(content);
  return steamInstance.cloud.fileWrite(name, buffer);
}

/**
 * Delete a file from Steam Cloud
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} name - The filename to delete
 * @returns {boolean} True if delete was successful
 */
export function cloudDeleteFile(steamInstance, name) {
  return steamInstance.cloud.fileDelete(name);
}

/**
 * Check if a file exists in Steam Cloud
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} name - The filename to check
 * @returns {boolean} True if the file exists
 */
export function cloudFileExists(steamInstance, name) {
  return steamInstance.cloud.fileExists(name);
}

/**
 * List all files in Steam Cloud
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @returns {List<{name: string, size: string}>} Gleam list of file info objects
 */
export function cloudListFiles(steamInstance) {
  const files = steamInstance.cloud.getAllFiles();
  const jsArray = files.map(f => new VAPOUR.FileInfo(f.name, f.size));
  return toList(jsArray);
}

// ============================================================================
// Local Player API
// ============================================================================

/**
 * Get the local player's display name (persona name)
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @returns {string} The player's Steam display name or empty string
 */
export function localplayerGetName(steamInstance) {
  const result = steamInstance.friends.getPersonaName();
  return result || "";
}

/**
 * Set a Rich Presence key/value pair
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} key - The Rich Presence key
 * @param {string} value - The Rich Presence value
 * @returns {void}
 */
export function localplayerSetRichPresence(steamInstance, key, value) {
  steamInstance.richPresence.setRichPresence(key, value);
}

/**
 * Clear all Rich Presence data
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @returns {void}
 */
export function localplayerClearRichPresence(steamInstance) {
  steamInstance.richPresence.clearRichPresence();
}

// ============================================================================
// Stats API
// ============================================================================

/**
 * Get an integer stat value for the current user
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} statName - Name of the stat to retrieve
 * @returns {Promise<Result<number, Nil>>} Stat value or Error if not found
 */
export async function statsGetInt(steamInstance, statName) {
  const stat = await steamInstance.stats.getStatInt(statName);
  return stat ? new Ok(stat.value) : new Error(undefined);
}

/**
 * Get a float stat value for the current user
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} statName - Name of the stat to retrieve
 * @returns {Promise<Result<number, Nil>>} Stat value or Error if not found
 */
export async function statsGetFloat(steamInstance, statName) {
  const stat = await steamInstance.stats.getStatFloat(statName);
  return stat ? new Ok(stat.value) : new Error(undefined);
}

/**
 * Set an integer stat value for the current user
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} statName - Name of the stat to set
 * @param {number} value - Integer value to set
 * @returns {Promise<boolean>} True if successful
 */
export async function statsSetInt(steamInstance, statName, value) {
  return await steamInstance.stats.setStatInt(statName, value);
}

/**
 * Set a float stat value for the current user
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} statName - Name of the stat to set
 * @param {number} value - Float value to set
 * @returns {Promise<boolean>} True if successful
 */
export async function statsSetFloat(steamInstance, statName, value) {
  return await steamInstance.stats.setStatFloat(statName, value);
}

/**
 * Get the number of players currently playing the game
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @returns {Promise<Result<number, Nil>>} Number of current players or Error on error
 */
export async function statsGetNumberOfCurrentPlayers(steamInstance) {
  const result = await steamInstance.stats.getNumberOfCurrentPlayers();
  return result ? new Ok(result) : new Error(undefined);
}

/**
 * Update an average rate stat
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} statName - Name of the stat
 * @param {number} countThisSession - Count for this session
 * @param {number} sessionLength - Session length in seconds
 * @returns {Promise<boolean>} True if successful
 */
export async function statsUpdateAvgRateStat(steamInstance, statName, countThisSession, sessionLength) {
  return await steamInstance.stats.updateAvgRateStat(statName, countThisSession, sessionLength);
}

/**
 * Request global stats from Steam
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {number} historyDays - Number of days of history (0-60)
 * @returns {Promise<boolean>} True if request sent successfully
 */
export async function statsRequestGlobalStats(steamInstance, historyDays) {
  return await steamInstance.stats.requestGlobalStats(historyDays);
}

/**
 * Get a global stat (int)
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} statName - Name of the stat
 * @returns {Promise<Result<number, Nil>>} Stat value or Error if not found
 */
export async function statsGetGlobalStatInt(steamInstance, statName) {
  const stat = await steamInstance.stats.getGlobalStatInt(statName);
  return stat ? new Ok(stat.value) : new Error(undefined);
}

/**
 * Get a global stat (float)
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} statName - Name of the stat
 * @returns {Promise<Result<number, Nil>>} Stat value or Error if not found
 */
export async function statsGetGlobalStatFloat(steamInstance, statName) {
  const stat = await steamInstance.stats.getGlobalStatDouble(statName);
  return stat ? new Ok(stat.value) : new Error(undefined);
}

/**
 * Request stats for another user
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} steamId - User's Steam ID
 * @returns {Promise<boolean>} True if request sent successfully
 */
export async function statsRequestUserStats(steamInstance, steamId) {
  return await steamInstance.stats.requestUserStats(steamId);
}

/**
 * Get an integer stat for another user
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} steamId - User's Steam ID
 * @param {string} statName - Name of the stat
 * @returns {Promise<Result<number, Nil>>} Stat value or Error if not found
 */
export async function statsGetUserStatInt(steamInstance, steamId, statName) {
  const stat = await steamInstance.stats.getUserStatInt(steamId, statName);
  return stat ? new Ok(stat.value) : new Error(undefined);
}

/**
 * Get a float stat for another user
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} steamId - User's Steam ID
 * @param {string} statName - Name of the stat
 * @returns {Promise<Result<number, Nil>>} Stat value or Error if not found
 */
export async function statsGetUserStatFloat(steamInstance, steamId, statName) {
  const stat = await steamInstance.stats.getUserStatFloat(steamId, statName);
  return stat ? new Ok(stat.value) : new Error(undefined);
}

// ============================================================================
// Friends API
// ============================================================================

/**
 * Get the current user's persona state (online status)
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @returns {number} Persona state enum value
 */
export function friendsGetPersonaState(steamInstance) {
  return steamInstance.friends.getPersonaState();
}

/**
 * Get the count of friends
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @returns {number} Number of friends
 */
export function friendsGetFriendCount(steamInstance) {
  return steamInstance.friends.getFriendCount();
}


/**
 * Get a friend's persona name
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} steamId - Friend's Steam ID
 * @returns {string} Friend's display name or empty string
 */
export function friendsGetFriendPersonaName(steamInstance, steamId) {
  const result = steamInstance.friends.getFriendPersonaName(steamId);
  return result || "";
}

/**
 * Get a friend's persona state
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} steamId - Friend's Steam ID
 * @returns {number} Friend's persona state
 */
export function friendsGetFriendPersonaState(steamInstance, steamId) {
  return steamInstance.friends.getFriendPersonaState(steamId);
}

/**
 * Get all friends with their information
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @returns {List} Gleam list of friend info
 */
export function friendsGetAllFriends(steamInstance) {
  const friends = steamInstance.friends.getAllFriends();
  const jsArray = friends.map(f => new VAPOUR.FriendInfo(
    f.steamId,
    f.personaName,
    f.personaState
  ));
  return toList(jsArray);
}

/**
 * Get a friend's Steam level
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} steamId - Friend's Steam ID
 * @returns {number} Friend's Steam level
 */
export function friendsGetFriendSteamLevel(steamInstance, steamId) {
  return steamInstance.friends.getFriendSteamLevel(steamId);
}

/**
 * Check if a friend is playing a game
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} steamId - Friend's Steam ID
 * @returns {Result<number, Nil>} Game App ID or Error if not playing
 */
export function friendsGetFriendGamePlayed(steamInstance, steamId) {
  const gameInfo = steamInstance.friends.getFriendGamePlayed(steamId);
  return gameInfo ? new Ok(parseInt(gameInfo.gameId)) : new Error(undefined);
}

/**
 * Get the relationship with another user
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} steamId - User's Steam ID
 * @returns {number} Relationship enum value
 */
export function friendsGetFriendRelationship(steamInstance, steamId) {
  return steamInstance.friends.getFriendRelationship(steamId);
}

/**
 * Get the count of coplay friends (recently played with)
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @returns {number} Number of coplay friends
 */
export function friendsGetCoplayFriendCount(steamInstance) {
  return steamInstance.friends.getCoplayFriendCount();
}


/**
 * Get when you last played with a user
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} steamId - User's Steam ID
 * @returns {number} Unix timestamp
 */
export function friendsGetFriendCoplayTime(steamInstance, steamId) {
  return steamInstance.friends.getFriendCoplayTime(steamId);
}

/**
 * Get the game you last played with a user
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} steamId - User's Steam ID
 * @returns {number} App ID
 */
export function friendsGetFriendCoplayGame(steamInstance, steamId) {
  return steamInstance.friends.getFriendCoplayGame(steamId);
}

// ============================================================================
// Overlay API
// ============================================================================

/**
 * Activate a Steam overlay dialog
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} dialog - The dialog name (e.g., "Friends", "Achievements")
 * @returns {void}
 */
export function overlayActivateDialog(steamInstance, dialog) {
  steamInstance.overlay.activateGameOverlay(dialog);
}

/**
 * Activate the Steam overlay to a specific user's profile
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} dialog - The dialog type (e.g., "steamid")
 * @param {string} steamId64 - The user's 64-bit Steam ID
 * @returns {void}
 */
export function overlayActivateDialogToUser(steamInstance, dialog, steamId64) {
  steamInstance.overlay.activateGameOverlayToUser(dialog, steamId64);
}

/**
 * Activate the Steam overlay browser to a web page
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} url - The URL to open in the overlay browser
 * @returns {void}
 */
export function overlayActivateWebPage(steamInstance, url) {
  steamInstance.overlay.activateGameOverlayToWebPage(url);
}

/**
 * Activate the Steam overlay to a store page
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {number} appId - The Steam App ID to show in the store
 * @returns {void}
 */
export function overlayActivateStore(steamInstance, appId) {
  steamInstance.overlay.activateGameOverlayToStore(appId);
}

/**
 * Open the Steam overlay invite dialog for a lobby
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} lobbySteamId - The Steam ID of the lobby
 * @returns {void}
 */
export function overlayActivateInviteDialog(steamInstance, lobbySteamId) {
  steamInstance.overlay.activateGameOverlayInviteDialog(lobbySteamId);
}

/**
 * Open the Steam overlay invite dialog with a custom connect string
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} connectString - Custom connection information
 * @returns {void}
 */
export function overlayActivateInviteDialogConnectString(steamInstance, connectString) {
  steamInstance.overlay.activateGameOverlayInviteDialogConnectString(connectString);
}

// ============================================================================
// Leaderboards API
// ============================================================================

/**
 * Find a leaderboard by name
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} leaderboardName - Name of the leaderboard
 * @returns {Promise<Result<string, Nil>>} Leaderboard handle or Error if not found
 */
export async function leaderboardsFindLeaderboard(steamInstance, leaderboardName) {
  const leaderboardInfo = await steamInstance.leaderboards.findLeaderboard(leaderboardName);
  // leaderboardInfo has: { handle, name, entryCount, sortMethod, displayType }
  return leaderboardInfo ? new Ok(leaderboardInfo) : new Error(undefined);
}

/**
 * Find or create a leaderboard with sort and display settings
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} name - Leaderboard name
 * @param {number} sortMethod - Sort method enum: 0=None, 1=Ascending, 2=Descending
 * @param {number} displayType - Display type enum: 0=None, 1=Numeric, 2=TimeSeconds, 3=TimeMilliseconds
 * @returns {Promise<Result<LeaderBoard, Nil>>} Leaderboard info or Error if failed
 */
export async function leaderboardsFindOrCreateLeaderboard(steamInstance, name, sortMethod, displayType) {
  const leaderboardInfo = await steamInstance.leaderboards.findOrCreateLeaderboard(name, sortMethod, displayType);
  return leaderboardInfo ? new Ok(leaderboardInfo) : new Error(undefined);
}

/**
 * Upload a score to a leaderboard
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {VAPOUR.LeaderBoard} leaderboardInfo - Leaderboard info object
 * @param {number} score - Score to upload
 * @param {number} uploadScoreMethod - Enum value: 1=KeepBest, 2=ForceUpdate
 * @returns {Promise<boolean>} True if successful
 */
export async function leaderboardsUploadScore(steamInstance, leaderboardInfo, score, uploadScoreMethod) {
  const result = await steamInstance.leaderboards.uploadScore(leaderboardInfo.handle, score, uploadScoreMethod);
  return result ? result.success : false;
}

/**
 * Download leaderboard entries
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {VAPOUR.LeaderBoard} leaderboardInfo - Leaderboard info object
 * @param {number} dataRequest - Enum value: 0=Global, 1=GlobalAroundUser, 2=Friends
 * @param {number} start - Start index
 * @param {number} end - End index
 * @returns {Promise<List>} Gleam list of leaderboard entries
 */
export async function leaderboardsDownloadScores(steamInstance, leaderboardInfo, dataRequest, start, end) {
  const entries = await steamInstance.leaderboards.downloadLeaderboardEntries(leaderboardInfo.handle, dataRequest, start, end);
  const jsArray = entries.map(e => new VAPOUR.LeaderboardEntry(
    e.steamId,
    e.globalRank,
    e.score
  ));
  return toList(jsArray);
}

/**
 * Get the entry count for a leaderboard
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {VAPOUR.LeaderBoard} leaderboardHandle - Leaderboard handle
 * @returns {number} Number of entries
 */
export function leaderboardsGetEntryCount(steamInstance, leaderboardInfo) {
  // entryCount is a property on LeaderboardInfo, not a method
  return leaderboardInfo.entryCount;
}

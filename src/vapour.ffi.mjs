// Copyright (c) 2025 Renata Amutio
// SPDX-License-Identifier: MIT
//
// Pure 1:1 bindings to steamworks-ffi-node
// No business logic - just thin wrappers around the Steamworks API

// Use nw.require for NW.js compatibility - this loads Node.js modules properly
// Falls back to regular require for non-NW.js environments
const nodeRequire = (typeof nw !== 'undefined' && nw.require) ? nw.require : require;
const SteamworksModule = nodeRequire("steamworks-ffi-node");

import { toList } from "./gleam.mjs";
import * as VAPOUR from "./vapour.mjs"

const SteamworksSDK = SteamworksModule.default;

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
 * @returns {{isInitialized: boolean, appId: number, steamId: string}} Status object
 */
export function getStatus(steamInstance) {
  return steamInstance.getStatus();
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
 * @returns {string|null} File contents as string, or null if read failed
 */
export function cloudReadFile(steamInstance, name) {
  const result = steamInstance.cloud.fileRead(name);
  if (result.success && result.data) {
    return result.data.toString();
  }
  return null;
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
 * @returns {string} The player's Steam display name
 */
export function localplayerGetName(steamInstance) {
  return steamInstance.friends.getPersonaName();
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
 * @returns {Promise<number|null>} Stat value or null if not found
 */
export async function statsGetInt(steamInstance, statName) {
  const stat = await steamInstance.stats.getStatInt(statName);
  return stat ? stat.value : null;
}

/**
 * Get a float stat value for the current user
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} statName - Name of the stat to retrieve
 * @returns {Promise<number|null>} Stat value or null if not found
 */
export async function statsGetFloat(steamInstance, statName) {
  const stat = await steamInstance.stats.getStatFloat(statName);
  return stat ? stat.value : null;
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
 * @returns {Promise<number|null>} Number of current players or null on error
 */
export async function statsGetNumberOfCurrentPlayers(steamInstance) {
  return await steamInstance.stats.getNumberOfCurrentPlayers();
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
 * @returns {Promise<number|null>} Stat value or null
 */
export async function statsGetGlobalStatInt(steamInstance, statName) {
  const stat = await steamInstance.stats.getGlobalStatInt(statName);
  return stat ? stat.value : null;
}

/**
 * Get a global stat (float)
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} statName - Name of the stat
 * @returns {Promise<number|null>} Stat value or null
 */
export async function statsGetGlobalStatFloat(steamInstance, statName) {
  const stat = await steamInstance.stats.getGlobalStatDouble(statName);
  return stat ? stat.value : null;
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
 * @returns {Promise<number|null>} Stat value or null
 */
export async function statsGetUserStatInt(steamInstance, steamId, statName) {
  const stat = await steamInstance.stats.getUserStatInt(steamId, statName);
  return stat ? stat.value : null;
}

/**
 * Get a float stat for another user
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} steamId - User's Steam ID
 * @param {string} statName - Name of the stat
 * @returns {Promise<number|null>} Stat value or null
 */
export async function statsGetUserStatFloat(steamInstance, steamId, statName) {
  const stat = await steamInstance.stats.getUserStatFloat(steamId, statName);
  return stat ? stat.value : null;
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
 * Get a friend's Steam ID by index
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {number} index - Friend index
 * @returns {string|null} Steam ID or null
 */
export function friendsGetFriendByIndex(steamInstance, index) {
  return steamInstance.friends.getFriendByIndex(index);
}

/**
 * Get a friend's persona name
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} steamId - Friend's Steam ID
 * @returns {string} Friend's display name
 */
export function friendsGetFriendPersonaName(steamInstance, steamId) {
  return steamInstance.friends.getFriendPersonaName(steamId);
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
 * @returns {number|null} Game App ID or null if not playing
 */
export function friendsGetFriendGamePlayed(steamInstance, steamId) {
  const gameInfo = steamInstance.friends.getFriendGamePlayed(steamId);
  return gameInfo ? parseInt(gameInfo.gameId) : null;
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
 * Get a coplay friend's Steam ID by index
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {number} index - Coplay friend index
 * @returns {string} Steam ID
 */
export function friendsGetCoplayFriend(steamInstance, index) {
  return steamInstance.friends.getCoplayFriend(index);
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

// ============================================================================
// Leaderboards API
// ============================================================================

/**
 * Find a leaderboard by name
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} leaderboardName - Name of the leaderboard
 * @returns {Promise<string|null>} Leaderboard handle or null if not found
 */
export async function leaderboardsFindLeaderboard(steamInstance, leaderboardName) {
  const handle = await steamInstance.leaderboards.findLeaderboard(leaderboardName);
  return handle ? handle.toString() : null;
}

/**
 * Upload a score to a leaderboard
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} leaderboardHandle - Leaderboard handle
 * @param {number} score - Score to upload
 * @param {string} uploadScoreMethod - "KeepBest" or "ForceUpdate"
 * @returns {Promise<boolean>} True if successful
 */
export async function leaderboardsUploadScore(steamInstance, leaderboardHandle, score, uploadScoreMethod) {
  // Convert string handle back to bigint
  const handle = BigInt(leaderboardHandle);
  return await steamInstance.leaderboards.uploadScore(handle, score, uploadScoreMethod);
}

/**
 * Download leaderboard entries
 * @param {SteamworksSDK} steamInstance - The Steamworks SDK instance
 * @param {string} leaderboardHandle - Leaderboard handle
 * @param {string} dataRequest - "Global", "GlobalAroundUser", or "Friends"
 * @param {number} start - Start index
 * @param {number} end - End index
 * @returns {Promise<List>} Gleam list of leaderboard entries
 */
export async function leaderboardsDownloadScores(steamInstance, leaderboardHandle, dataRequest, start, end) {
  const handle = BigInt(leaderboardHandle);
  const entries = await steamInstance.leaderboards.downloadScores(handle, dataRequest, start, end);
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
 * @param {string} leaderboardHandle - Leaderboard handle
 * @returns {number} Number of entries
 */
export function leaderboardsGetEntryCount(steamInstance, leaderboardHandle) {
  const handle = BigInt(leaderboardHandle);
  return steamInstance.leaderboards.getLeaderboardEntryCount(handle);
}

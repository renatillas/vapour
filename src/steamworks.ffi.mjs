// Copyright (c) 2025 Renata Amutio
// SPDX-License-Identifier: MIT
//
// Pure 1:1 bindings to steamworks-ffi-node
// No business logic - just thin wrappers around the Steamworks API

import SteamworksSDK from "steamworks-ffi-node";

// ============================================================================
// Root Level Functions
// ============================================================================

/**
 * Initialize the Steamworks API
 * @param {number|undefined|null} appId - Optional Steam app ID
 * @returns {object} The Steamworks SDK instance
 */
export function init(appId) {
  const steamInstance = new SteamworksSDK();
  const options = appId ? { appId } : { appId: 480 };
  steamInstance.init(options);
  return steamInstance;
}

/**
 * Run Steam callbacks - should be called regularly (e.g., each frame)
 * @param {object} steamInstance - The Steamworks SDK instance
 */
export function runCallbacks(steamInstance) {
  steamInstance.runCallbacks();
}

// ============================================================================
// Achievement API
// ============================================================================

export async function achievementActivate(steamInstance, achievement) {
  return await steamInstance.achievements.unlockAchievement(achievement);
}

export async function achievementIsActivated(steamInstance, achievement) {
  return await steamInstance.achievements.isAchievementUnlocked(achievement);
}

export async function achievementClear(steamInstance, achievement) {
  return await steamInstance.achievements.clearAchievement(achievement);
}

export async function achievementNames(steamInstance) {
  const achievements = await steamInstance.achievements.getAllAchievements();
  return achievements.map(ach => ach.apiName);
}

// ============================================================================
// Cloud API
// ============================================================================

export function cloudIsEnabledForAccount(steamInstance) {
  return steamInstance.cloud.isCloudEnabledForAccount();
}

export function cloudIsEnabledForApp(steamInstance) {
  return steamInstance.cloud.isCloudEnabledForApp();
}

export function cloudSetEnabledForApp(steamInstance, enabled) {
  steamInstance.cloud.setCloudEnabledForApp(enabled);
}

export function cloudReadFile(steamInstance, name) {
  const result = steamInstance.cloud.fileRead(name);
  if (result.success && result.data) {
    return result.data.toString();
  }
  return null;
}

export function cloudWriteFile(steamInstance, name, content) {
  const buffer = Buffer.from(content);
  return steamInstance.cloud.fileWrite(name, buffer);
}

export function cloudDeleteFile(steamInstance, name) {
  return steamInstance.cloud.fileDelete(name);
}

export function cloudFileExists(steamInstance, name) {
  return steamInstance.cloud.fileExists(name);
}

export function cloudListFiles(steamInstance) {
  const files = steamInstance.cloud.getAllFiles();
  return files.map(f => ({
    name: f.name,
    size: f.size.toString(),
  }));
}

// ============================================================================
// Local Player API
// ============================================================================

export function localplayerGetName(steamInstance) {
  return steamInstance.friends.getPersonaName();
}

export function localplayerSetRichPresence(steamInstance, key, value) {
  steamInstance.richPresence.setRichPresence(key, value);
}

export function localplayerClearRichPresence(steamInstance) {
  steamInstance.richPresence.clearRichPresence();
}

// ============================================================================
// Overlay API
// ============================================================================

export function overlayActivateDialog(steamInstance, dialog) {
  steamInstance.overlay.activateGameOverlay(dialog);
}

export function overlayActivateDialogToUser(steamInstance, dialog, steamId64) {
  steamInstance.overlay.activateGameOverlayToUser(dialog, steamId64);
}

export function overlayActivateWebPage(steamInstance, url) {
  steamInstance.overlay.activateGameOverlayToWebPage(url);
}

export function overlayActivateStore(steamInstance, appId) {
  steamInstance.overlay.activateGameOverlayToStore(appId);
}

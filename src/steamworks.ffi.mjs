// Pure 1:1 bindings to steamworks.js
// No business logic - just thin wrappers around the Steamworks API

import steamworks from "steamworks.js";

// ============================================================================
// Root Level Functions
// ============================================================================

/**
 * Initialize the Steamworks API
 * @param {number|undefined|null} appId - Optional Steam app ID
 * @returns {object} The Steamworks client
 */
export function init(appId) {
  return steamworks.init(appId);
}

/**
 * Restart the app if it wasn't launched through Steam
 * @param {number} appId - Steam app ID
 * @returns {boolean} True if the app needs to restart
 */
export function restartAppIfNecessary(appId) {
  return steamworks.restartAppIfNecessary(appId);
}

/**
 * Run Steam callbacks - should be called regularly (e.g., each frame)
 */
export function runCallbacks() {
  steamworks.runCallbacks();
}

// ============================================================================
// Achievement API
// ============================================================================

export function achievementActivate(achievement) {
  return steamworks.achievement.activate(achievement);
}

export function achievementIsActivated(achievement) {
  return steamworks.achievement.isActivated(achievement);
}

export function achievementClear(achievement) {
  return steamworks.achievement.clear(achievement);
}

export function achievementNames() {
  return steamworks.achievement.names();
}

// ============================================================================
// Apps API
// ============================================================================

export function appsIsSubscribedApp(appId) {
  return steamworks.apps.isSubscribedApp(appId);
}

export function appsIsAppInstalled(appId) {
  return steamworks.apps.isAppInstalled(appId);
}

export function appsIsDlcInstalled(appId) {
  return steamworks.apps.isDlcInstalled(appId);
}

export function appsIsSubscribedFromFreeWeekend() {
  return steamworks.apps.isSubscribedFromFreeWeekend();
}

export function appsIsVacBanned() {
  return steamworks.apps.isVacBanned();
}

export function appsIsCybercafe() {
  return steamworks.apps.isCybercafe();
}

export function appsIsLowViolence() {
  return steamworks.apps.isLowViolence();
}

export function appsIsSubscribed() {
  return steamworks.apps.isSubscribed();
}

export function appsAppBuildId() {
  return steamworks.apps.appBuildId();
}

export function appsAppInstallDir(appId) {
  return steamworks.apps.appInstallDir(appId);
}

export function appsAppOwner() {
  const owner = steamworks.apps.appOwner();
  return {
    steamId64: owner.steamId64.toString(), // Convert BigInt to string for Gleam
    steamId32: owner.steamId32,
    accountId: owner.accountId,
  };
}

export function appsAvailableGameLanguages() {
  return steamworks.apps.availableGameLanguages();
}

export function appsCurrentGameLanguage() {
  return steamworks.apps.currentGameLanguage();
}

export function appsCurrentBetaName() {
  return steamworks.apps.currentBetaName();
}

// ============================================================================
// Cloud API
// ============================================================================

export function cloudIsEnabledForAccount() {
  return steamworks.cloud.isEnabledForAccount();
}

export function cloudIsEnabledForApp() {
  return steamworks.cloud.isEnabledForApp();
}

export function cloudSetEnabledForApp(enabled) {
  steamworks.cloud.setEnabledForApp(enabled);
}

export function cloudReadFile(name) {
  return steamworks.cloud.readFile(name);
}

export function cloudWriteFile(name, content) {
  return steamworks.cloud.writeFile(name, content);
}

export function cloudDeleteFile(name) {
  return steamworks.cloud.deleteFile(name);
}

export function cloudFileExists(name) {
  return steamworks.cloud.fileExists(name);
}

export function cloudListFiles() {
  const files = steamworks.cloud.listFiles();
  // Convert BigInt sizes to strings for Gleam
  return files.map(f => ({
    name: f.name,
    size: f.size.toString(),
  }));
}

// ============================================================================
// Input API
// ============================================================================

export function inputInit() {
  steamworks.input.init();
}

export function inputShutdown() {
  steamworks.input.shutdown();
}

export function inputGetControllers() {
  return steamworks.input.getControllers();
}

export function inputGetActionSet(actionSetName) {
  const handle = steamworks.input.getActionSet(actionSetName);
  return handle.toString(); // Convert BigInt to string
}

export function inputGetDigitalAction(actionName) {
  const handle = steamworks.input.getDigitalAction(actionName);
  return handle.toString(); // Convert BigInt to string
}

export function inputGetAnalogAction(actionName) {
  const handle = steamworks.input.getAnalogAction(actionName);
  return handle.toString(); // Convert BigInt to string
}

// Controller methods
export function controllerGetDigitalActionData(controller, actionHandle) {
  const data = controller.getDigitalActionData(BigInt(actionHandle));
  return {
    state: data.state,
    active: data.active,
  };
}

export function controllerGetAnalogActionData(controller, actionHandle) {
  const data = controller.getAnalogActionData(BigInt(actionHandle));
  return {
    x: data.x,
    y: data.y,
    mode: data.mode,
    active: data.active,
  };
}

export function controllerActivateActionSet(controller, actionSetHandle) {
  controller.activateActionSet(BigInt(actionSetHandle));
}

export function controllerGetCurrentActionSet(controller) {
  const handle = controller.getCurrentActionSet();
  return handle.toString();
}

export function controllerTriggerVibration(controller, leftSpeed, rightSpeed) {
  controller.triggerVibration(leftSpeed, rightSpeed);
}

// ============================================================================
// Local Player API
// ============================================================================

export function localplayerGetSteamId() {
  const id = steamworks.localplayer.getSteamId();
  return {
    steamId64: id.steamId64.toString(),
    steamId32: id.steamId32,
    accountId: id.accountId,
  };
}

export function localplayerGetName() {
  return steamworks.localplayer.getName();
}

export function localplayerGetLevel() {
  return steamworks.localplayer.getLevel();
}

export function localplayerGetIpCountry() {
  return steamworks.localplayer.getIpCountry();
}

export function localplayerSetRichPresence(key, value) {
  steamworks.localplayer.setRichPresence(key, value);
}

// ============================================================================
// Matchmaking API
// ============================================================================

export async function matchmakingCreateLobby(lobbyType, maxMembers) {
  const lobby = await steamworks.matchmaking.createLobby(lobbyType, maxMembers);
  return lobby;
}

export async function matchmakingJoinLobby(lobbyId) {
  const lobby = await steamworks.matchmaking.joinLobby(BigInt(lobbyId));
  return lobby;
}

export async function matchmakingGetLobbies() {
  return await steamworks.matchmaking.getLobbies();
}

// Lobby methods
export function lobbyGetId(lobby) {
  return lobby.getId().toString();
}

export function lobbyLeave(lobby) {
  lobby.leave();
}

export function lobbyJoin(lobby) {
  return lobby.join();
}

export function lobbyGetMembers(lobby) {
  const members = lobby.getMembers();
  return members.map(m => ({
    steamId64: m.steamId64.toString(),
    steamId32: m.steamId32,
    accountId: m.accountId,
  }));
}

export function lobbyGetMemberCount(lobby) {
  return lobby.getMemberCount();
}

export function lobbyGetOwner(lobby) {
  const owner = lobby.getOwner();
  return {
    steamId64: owner.steamId64.toString(),
    steamId32: owner.steamId32,
    accountId: owner.accountId,
  };
}

export function lobbySetData(lobby, key, value) {
  lobby.setData(key, value);
}

export function lobbyGetData(lobby, key) {
  return lobby.getData(key);
}

export function lobbyDeleteData(lobby, key) {
  lobby.deleteData(key);
}

export function lobbySetJoinable(lobby, joinable) {
  lobby.setJoinable(joinable);
}

export function lobbyOpenInviteDialog(lobby) {
  lobby.openInviteDialog();
}

// ============================================================================
// Networking API (P2P)
// ============================================================================

export function networkingSendP2PPacket(steamId64, sendType, data) {
  return steamworks.networking.sendP2PPacket(BigInt(steamId64), sendType, data);
}

export function networkingIsP2PPacketAvailable() {
  return steamworks.networking.isP2PPacketAvailable();
}

export function networkingReadP2PPacket(size) {
  const packet = steamworks.networking.readP2PPacket(size);
  return {
    steamId64: packet.steamId64.toString(),
    data: packet.data,
  };
}

export function networkingAcceptP2PSession(steamId64) {
  steamworks.networking.acceptP2PSession(BigInt(steamId64));
}

export function networkingCloseP2PSession(steamId64) {
  steamworks.networking.closeP2PSession(BigInt(steamId64));
}

// ============================================================================
// Overlay API
// ============================================================================

export function overlayActivateDialog(dialog) {
  steamworks.overlay.activateDialog(dialog);
}

export function overlayActivateDialogToUser(dialog, steamId64) {
  steamworks.overlay.activateDialogToUser(dialog, BigInt(steamId64));
}

export function overlayIsEnabled() {
  return steamworks.overlay.isEnabled();
}

export function overlaySetNotificationPosition(position) {
  steamworks.overlay.setNotificationPosition(position);
}

// ============================================================================
// Utils API
// ============================================================================

export function utilsGetAppId() {
  return steamworks.utils.getAppId();
}

export function utilsGetServerRealTime() {
  return steamworks.utils.getServerRealTime();
}

export function utilsIsSteamRunningOnSteamDeck() {
  return steamworks.utils.isSteamRunningOnSteamDeck();
}

export function utilsIsSteamInBigPictureMode() {
  return steamworks.utils.isSteamInBigPictureMode();
}

// ============================================================================
// Workshop API
// ============================================================================

export function workshopGetSubscribedItems() {
  const items = steamworks.workshop.getSubscribedItems();
  return items.map(id => id.toString());
}

export function workshopGetItemState(publishedFileId) {
  return steamworks.workshop.getItemState(BigInt(publishedFileId));
}

export function workshopGetItemInstallInfo(publishedFileId) {
  const info = steamworks.workshop.getItemInstallInfo(BigInt(publishedFileId));
  return {
    folder: info.folder,
    sizeOnDisk: info.sizeOnDisk.toString(),
    timestamp: info.timestamp,
  };
}

export function workshopDownloadItem(publishedFileId, highPriority) {
  return steamworks.workshop.downloadItem(BigInt(publishedFileId), highPriority);
}

export function workshopSuspendDownloads(suspend) {
  steamworks.workshop.suspendDownloads(suspend);
}

# Future API Implementations

This document outlines additional features from `steamworks-ffi-node` that could be added to Vapour.

## Currently Implemented ✅

- **Core API**: Initialization, callbacks, status checking
- **Achievements**: Unlock/lock achievements, list achievements (async)
- **Cloud Storage**: Read/write/delete files, check storage status
- **Rich Presence**: Set player status visible to friends
- **Overlay**: Open Steam overlay dialogs, profiles, web pages, store
- **Stats**: Get/set int and float stats, player count, global stats, user stats, average rate stats (async)
- **Friends**: Get friends list, check online status, view friend levels and games, relationship status, coplay features
- **Leaderboards**: Find leaderboards, upload scores, download entries (async)

## Potential Future Additions

### 1. ~~Stats API~~ ✅ **IMPLEMENTED**

~~The Stats API would allow games to track numerical statistics like kills, deaths, play time, etc. Stats can be used for leaderboards and analytics.~~

**Status**: Fully implemented! Complete stats support including:
- Basic stats (get/set int/float, player count)
- Global stats (aggregate across all players)
- User stats (compare with friends)
- Average rate stats (automatic rate calculation)

---

### 2. ~~Friends API~~ ✅ **IMPLEMENTED**

~~The Friends API provides access to the player's Steam friends list and social features.~~

**Status**: Fully implemented! Complete friends support including:
- Core friends functionality (list, status, info)
- Advanced features (coplay, relationship status)

---

### 3. ~~Leaderboards API~~ ✅ **IMPLEMENTED**

~~The Leaderboards API allows games to create competitive leaderboards.~~

**Status**: Fully implemented! Complete leaderboards support including:
- `find_leaderboard(name: String) -> Promise(Result(String, Nil))`
- `upload_score(handle: String, score: Int, method: UploadScoreMethod) -> Promise(Bool)`
- `download_scores(handle: String, request: LeaderboardDataRequest, start: Int, end: Int) -> Promise(List(LeaderboardEntry))`
- `get_leaderboard_entry_count(handle: String) -> Int`

**Use cases:**
- Global high score tables ✅
- Competitive rankings ✅
- Time trials and speedruns ✅
- Friend-only leaderboards ✅

---

## API Prioritization Recommendations

### ✅ Fully Implemented
1. ~~**Stats API**~~ - Complete stats tracking (basic, global, user stats, average rate)
2. ~~**Friends API**~~ - Complete friends functionality (list, status, info, coplay, relationship)
3. ~~**Leaderboards API**~~ - Complete leaderboards support (find, upload, download, entry count)

### Nice-to-Have (Future Additions)
4. **User Generated Content (Workshop)** - Mod support and Steam Workshop integration

### Lower Priority (Specialized Use Cases)
- Input API (controller support) - Most games handle this differently
- Matchmaking API - Complex, requires server infrastructure
- Networking API - Very specialized, P2P networking
- Workshop API - Mod support, not needed by all games

---

## Example Usage

### Stats API
```gleam
import gleam/javascript/promise
import vapour

// Track player kills
pub fn on_enemy_killed(client) {
  use current <- promise.await(vapour.get_stat_int(client, "total_kills"))
  use _result <- promise.await(vapour.set_stat_int(client, "total_kills", current + 1))
  promise.resolve(Nil)
}

// Show player count
pub fn show_player_count(client) {
  use count <- promise.await(vapour.get_number_of_current_players(client))
  io.println(int.to_string(count) <> " players online!")
  promise.resolve(Nil)
}
```

### Friends API
```gleam
import vapour

pub fn show_online_friends(client) {
  let friends = vapour.get_all_friends(client)

  friends
  |> list.filter(fn(friend) {
    vapour.get_friend_persona_state(client, friend.steam_id)
    == vapour.PersonaStateOnline
  })
  |> list.each(fn(friend) {
    io.println(friend.name <> " is online!")
  })
}
```

### Leaderboards API
```gleam
import gleam/javascript/promise
import vapour

pub fn submit_score(client, score: Int) {
  use leaderboard <- promise.await(vapour.find_leaderboard(client, "high_scores"))
  use success <- promise.await(vapour.upload_score(client, leaderboard, score))

  case success {
    True -> io.println("Score submitted!")
    False -> io.println("Failed to submit score")
  }

  promise.resolve(Nil)
}
```

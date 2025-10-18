/// Vapour + Tiramisu Integration
///
/// Demonstrates Steamworks SDK integration with Tiramisu 3D engine and Lustre UI overlay.
/// Shows Steam user information in a beautiful overlay while running a 3D physics simulation.
///
/// Controls:
/// - Watch the physics simulation with falling cubes
/// - Steam user info displayed in top-right overlay
import gleam/int
import gleam/option
import lustre
import lustre/attribute.{class}
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import tiramisu
import tiramisu/background
import tiramisu/camera
import tiramisu/effect as game_effect
import tiramisu/geometry
import tiramisu/light
import tiramisu/material
import tiramisu/physics
import tiramisu/scene
import tiramisu/transform
import tiramisu/ui
import vapour
import vec/vec3

// ============================================================================
// UI STATE AND MESSAGES
// ============================================================================

pub type UIModel {
  UIModel(
    user_name: String,
    user_status: String,
    friend_count: Int,
    is_steam_running: Bool,
    app_id: Int,
    steam_id: String,
    loading: Bool,
  )
}

pub type UIMsg {
  SteamDataLoaded(
    name: String,
    status: vapour.PersonaState,
    friend_count: Int,
    is_running: Bool,
    app_id: Int,
    steam_id: String,
  )
}

// ============================================================================
// MAIN
// ============================================================================

pub fn main() {
  // Start Lustre UI overlay
  let assert Ok(_) =
    lustre.application(ui_init, ui_update, ui_view)
    |> lustre.start("#app", Nil)

  // Start Tiramisu 3D game
  start_game()
}

// ============================================================================
// UI LOGIC
// ============================================================================

fn ui_init(_flags) {
  #(
    UIModel(
      user_name: "Loading...",
      user_status: "...",
      friend_count: 0,
      is_steam_running: False,
      app_id: 0,
      steam_id: "...",
      loading: True,
    ),
    ui.register_lustre(),
  )
}

fn ui_update(_model: UIModel, msg: UIMsg) {
  case msg {
    SteamDataLoaded(name, status, friends, running, app, steam_id) -> {
      let status_str = persona_state_to_string(status)
      #(
        UIModel(
          user_name: name,
          user_status: status_str,
          friend_count: friends,
          is_steam_running: running,
          app_id: app,
          steam_id: steam_id,
          loading: False,
        ),
        effect.none(),
      )
    }
  }
}

fn ui_view(model: UIModel) -> Element(UIMsg) {
  html.div([class("fixed top-0 left-0 w-full h-full pointer-events-none")], [
    steam_overlay(model),
  ])
}

fn steam_overlay(model: UIModel) -> Element(UIMsg) {
  html.div(
    [
      class(
        "absolute top-5 right-5 p-6 bg-gradient-to-br from-[#1e2124]/95 to-[#282b30]/95 rounded-xl text-white font-sans pointer-events-auto shadow-2xl border border-white/10 backdrop-blur-sm min-w-[320px]",
      ),
    ],
    [
      // Title
      html.div([class("mb-4 pb-3 border-b border-white/20")], [
        html.h2([class("text-2xl font-bold text-[#4ecdc4] m-0")], [
          element.text("Steam Integration"),
        ]),
      ]),
      // User Info Section
      html.div([class("space-y-3")], case model.loading {
        True -> [
          html.div([class("text-gray-400 animate-pulse")], [
            element.text("Loading Steam data..."),
          ]),
        ]
        False -> [
          // User Name
          info_row("👤 User: ", model.user_name, "text-blue-300"),
          // Status
          info_row(
            "🟢 Status",
            model.user_status,
            status_color(model.user_status),
          ),
          // Friends Count
          info_row(
            "👥 Friends: ",
            int.to_string(model.friend_count),
            "text-purple-300",
          ),
          // Steam ID
          info_row_small("🔑 Steam ID: ", model.steam_id),
          // App ID
          info_row_small("🎮 App ID: ", int.to_string(model.app_id)),
          // Steam Running
          info_row_small("💻 Steam: ", case model.is_steam_running {
            True -> "Running ✓"
            False -> "Not Running ✗"
          }),
        ]
      }),
      // Footer
      html.div(
        [class("mt-4 pt-3 border-t border-white/20 text-xs text-gray-400")],
        [
          html.div([class("flex items-center gap-2")], [
            html.span([], [element.text("⚡ Powered by: ")]),
            html.span([class("text-[#4ecdc4] font-semibold")], [
              element.text("Vapour + Tiramisu"),
            ]),
          ]),
        ],
      ),
    ],
  )
}

fn info_row(label: String, value: String, color: String) -> Element(UIMsg) {
  html.div([class("flex justify-between items-center py-2")], [
    html.span([class("text-gray-300 text-sm font-medium")], [
      element.text(label),
    ]),
    html.span([class("text-base font-bold " <> color)], [element.text(value)]),
  ])
}

fn info_row_small(label: String, value: String) -> Element(UIMsg) {
  html.div([class("flex justify-between items-center py-1")], [
    html.span([class("text-gray-400 text-xs")], [element.text(label)]),
    html.span([class("text-xs text-gray-300 font-mono")], [
      element.text(value),
    ]),
  ])
}

fn persona_state_to_string(state: vapour.PersonaState) -> String {
  case state {
    vapour.Offline -> "Offline"
    vapour.Online -> "Online"
    vapour.Busy -> "Busy"
    vapour.Away -> "Away"
    vapour.Snooze -> "Snooze"
    vapour.LookingToTrade -> "Looking to Trade"
    vapour.LookingToPlay -> "Looking to Play"
    vapour.Invisible -> "Invisible"
    vapour.Max -> "Unknown"
  }
}

fn status_color(status: String) -> String {
  case status {
    "Online" -> "text-green-400"
    "Offline" -> "text-gray-400"
    "Busy" -> "text-red-400"
    "Away" -> "text-yellow-400"
    _ -> "text-gray-300"
  }
}

// ============================================================================
// GAME LOGIC
// ============================================================================

pub type Id {
  Camera
  Ambient
  Directional
  Ground
  Cube1
  Cube2
  Cube3
}

pub type GameModel {
  GameModel(
    steam_client: vapour.SteamworksClient,
    rotation: Float,
    camera_angle: Float,
    data_sent: Bool,
  )
}

pub type GameMsg {
  Tick
}

fn start_game() -> Nil {
  tiramisu.run(
    dimensions: option.None,
    background: background.Color(0x0f1419),
    init: game_init,
    update: game_update,
    view: game_view,
  )
}

fn game_init(
  _ctx: tiramisu.Context(Id),
) -> #(GameModel, game_effect.Effect(GameMsg), option.Option(_)) {
  // Initialize Steamworks
  let assert Ok(client) = vapour.init(option.Some(480))

  // Initialize physics world
  let physics_world =
    physics.new_world(physics.WorldConfig(gravity: vec3.Vec3(0.0, -9.81, 0.0)))

  #(
    GameModel(
      steam_client: client,
      rotation: 0.0,
      camera_angle: 0.0,
      data_sent: False,
    ),
    game_effect.tick(Tick),
    option.Some(physics_world),
  )
}

fn game_update(
  model: GameModel,
  msg: GameMsg,
  ctx: tiramisu.Context(Id),
) -> #(GameModel, game_effect.Effect(GameMsg), option.Option(_)) {
  // Run Steam callbacks
  vapour.run_callbacks(model.steam_client)

  let assert option.Some(physics_world) = ctx.physics_world

  case msg {
    Tick -> {
      // Step physics
      let new_physics_world = physics.step(physics_world)

      // Update rotation
      let new_rotation = model.rotation +. ctx.delta_time *. 0.5

      // Send Steam data to UI once
      let effects = case model.data_sent {
        False -> {
          // Get Steam data
          let name = vapour.display_name(model.steam_client)
          let status = vapour.persona_state(model.steam_client)
          let friends = vapour.friend_count(model.steam_client)
          let running = vapour.running_steam(model.steam_client)
          let steam_status = vapour.status(model.steam_client)

          [
            game_effect.tick(Tick),
            ui.dispatch_to_lustre(SteamDataLoaded(
              name,
              status,
              friends,
              running,
              steam_status.app_id,
              steam_status.steam_id,
            )),
          ]
        }
        True -> [game_effect.tick(Tick)]
      }

      #(
        GameModel(..model, rotation: new_rotation, data_sent: True),
        game_effect.batch(effects),
        option.Some(new_physics_world),
      )
    }
  }
}

fn game_view(
  _model: GameModel,
  ctx: tiramisu.Context(Id),
) -> List(scene.Node(Id)) {
  let assert option.Some(physics_world) = ctx.physics_world

  // Camera
  let assert Ok(cam) =
    camera.perspective(field_of_view: 75.0, near: 0.1, far: 1000.0)

  // Geometries
  let assert Ok(cube_geom) = geometry.box(width: 1.0, height: 1.0, depth: 1.0)
  let assert Ok(ground_geom) =
    geometry.box(width: 20.0, height: 0.2, depth: 20.0)

  // Materials
  let assert Ok(cube1_mat) =
    material.new() |> material.with_color(0x4ecdc4) |> material.build
  let assert Ok(cube2_mat) =
    material.new() |> material.with_color(0xff6b6b) |> material.build
  let assert Ok(cube3_mat) =
    material.new() |> material.with_color(0xffe66d) |> material.build
  let assert Ok(ground_mat) =
    material.new() |> material.with_color(0x2d3748) |> material.build

  [
    // Camera
    scene.Camera(
      id: Camera,
      camera: cam,
      transform: transform.at(position: vec3.Vec3(0.0, 5.0, 15.0)),
      look_at: option.Some(vec3.Vec3(0.0, 2.0, 0.0)),
      active: True,
      viewport: option.None,
    ),
    // Lights
    scene.Light(
      id: Ambient,
      light: {
        let assert Ok(light) = light.ambient(color: 0xffffff, intensity: 0.4)
        light
      },
      transform: transform.identity,
    ),
    scene.Light(
      id: Directional,
      light: {
        let assert Ok(light) =
          light.directional(color: 0xffffff, intensity: 1.5)
        light
      },
      transform: transform.at(position: vec3.Vec3(5.0, 10.0, 7.5)),
    ),
    // Ground
    scene.Mesh(
      id: Ground,
      geometry: ground_geom,
      material: ground_mat,
      transform: transform.at(position: vec3.Vec3(0.0, 0.0, 0.0)),
      physics: option.Some(
        physics.new_rigid_body(physics.Fixed)
        |> physics.with_collider(physics.Box(
          transform.identity,
          20.0,
          0.2,
          20.0,
        ))
        |> physics.with_restitution(0.3)
        |> physics.build(),
      ),
    ),
    // Falling Cubes
    scene.Mesh(
      id: Cube1,
      geometry: cube_geom,
      material: cube1_mat,
      transform: case physics.get_transform(physics_world, Cube1) {
        Ok(t) -> t
        Error(Nil) -> transform.at(position: vec3.Vec3(-2.5, 5.0, 0.0))
      },
      physics: option.Some(
        physics.new_rigid_body(physics.Dynamic)
        |> physics.with_collider(physics.Box(transform.identity, 1.0, 1.0, 1.0))
        |> physics.with_mass(1.0)
        |> physics.with_restitution(0.6)
        |> physics.with_friction(0.4)
        |> physics.build(),
      ),
    ),
    scene.Mesh(
      id: Cube2,
      geometry: cube_geom,
      material: cube2_mat,
      transform: case physics.get_transform(physics_world, Cube2) {
        Ok(t) -> t
        Error(Nil) -> transform.at(position: vec3.Vec3(0.0, 7.0, 0.0))
      },
      physics: option.Some(
        physics.new_rigid_body(physics.Dynamic)
        |> physics.with_collider(physics.Box(transform.identity, 1.0, 1.0, 1.0))
        |> physics.with_mass(1.0)
        |> physics.with_restitution(0.7)
        |> physics.with_friction(0.3)
        |> physics.build(),
      ),
    ),
    scene.Mesh(
      id: Cube3,
      geometry: cube_geom,
      material: cube3_mat,
      transform: case physics.get_transform(physics_world, Cube3) {
        Ok(t) -> t
        Error(Nil) -> transform.at(position: vec3.Vec3(2.5, 9.0, 0.0))
      },
      physics: option.Some(
        physics.new_rigid_body(physics.Dynamic)
        |> physics.with_collider(physics.Box(transform.identity, 1.0, 1.0, 1.0))
        |> physics.with_mass(1.0)
        |> physics.with_restitution(0.5)
        |> physics.with_friction(0.5)
        |> physics.build(),
      ),
    ),
  ]
}

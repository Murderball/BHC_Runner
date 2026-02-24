/// obj_enemy_manager : Step
///
/// Lane-free enemy spawning:
/// - Spawns enemies using per-spawn y_gui (generated if missing)
/// - Does NOT set e.lane at all
/// - Rebuilds spawn list after leaving editor so newly placed markers are used

function _enemy_spawns_build()
{
    var out = [];

    if (script_exists(scr_enemy_spawns_from_markers))
        out = scr_enemy_spawns_from_markers();

    if (array_length(out) == 0)
    {
        if (variable_global_exists("chart") && is_array(global.chart))
        {
            var len = array_length(global.chart);
            for (var i = 0; i < len; i++)
            {
                var n = global.chart[i];
                if (!is_struct(n)) continue;
                if (!variable_struct_exists(n, "type") || n.type != "enemy") continue;
                if (!variable_struct_exists(n, "t")) continue;

                var lane = 0;
                if (variable_struct_exists(n, "lane")) lane = clamp(floor(n.lane), 0, global.LANE_COUNT - 1);

                var kind = "poptarts";
                if (variable_struct_exists(n, "enemy_kind")) kind = string(n.enemy_kind);

                array_push(out, {
                    t: n.t,
                    lane: lane,
                    kind: kind,
                    y_gui: global.LANE_Y[lane],
                    spawned: false
                });
            }
        }
    }

    return out;
}


// ----------------------------------------------------
// Editor behavior: reset + clear live enemies
// ----------------------------------------------------
if (global.editor_on)
{
    built_spawns = false;
    next_spawn_i = 0;
    spawn_index = 0;

    with (obj_enemy) instance_destroy();
    exit;
}

// Rebuild spawn list once after leaving editor
if (!built_spawns)
{
    enemy_spawns = _enemy_spawns_build();
    next_spawn_i = 0;
    spawn_index = 0;
    built_spawns = true;
}

// Must have spawn list
if (!is_array(enemy_spawns)) exit;


// ----------------------------------------------------
// Timing
// ----------------------------------------------------
var now_t = scr_chart_time();
var gw    = display_get_gui_width();
var pps   = scr_timeline_pps();
if (pps <= 0) pps = 1;

var hitx = 448;
if (variable_global_exists("HIT_X_GUI")) hitx = global.HIT_X_GUI;

// Lead time = how early we should spawn before enemy enters from right
var denom = pps;
if (denom == 0)
{
    show_debug_message("[SAFE DIVISION FIX] Zero denominator corrected in " + script_get_name(script_index));
    denom = 1;
}
var lead_s = (gw + enemy_margin_px - hitx) / denom;


// ----------------------------------------------------
// Y mode defaults (optional toggles)
// ----------------------------------------------------
var y_mode = "random";
if (variable_global_exists("enemy_y_mode")) y_mode = global.enemy_y_mode;

// deterministic seed (optional)
if (!variable_global_exists("enemy_spawn_seed")) global.enemy_spawn_seed = irandom(999999);

// If you don’t already have a counter, create one
if (!variable_instance_exists(id, "spawn_index")) spawn_index = 0;


// Safe vertical bounds (avoid UI edges)
var top = 140;
var bot = display_get_gui_height() - 140;


// Helper: generate y_gui if missing
function _gen_y_gui(i, t_s)
{
    if (script_exists(scr_enemy_y_pattern))
        return clamp(scr_enemy_y_pattern(y_mode, i, t_s, global.enemy_spawn_seed), top, bot);

    return irandom_range(top, bot);
}


// ----------------------------------------------------
// Spawn loop
// ----------------------------------------------------
while (next_spawn_i < array_length(enemy_spawns))
{
    var s = enemy_spawns[next_spawn_i];

    if (s.spawned) {
        next_spawn_i++;
        continue;
    }

    // time to spawn?
    if (now_t >= s.t - lead_s - 0.10)
    {
        // Ensure this spawn has y_gui
        if (!variable_struct_exists(s, "y_gui") || is_undefined(s.y_gui))
        {
            s.y_gui = _gen_y_gui(spawn_index, s.t);
        }

        // Create enemy
        var e = instance_create_layer(0, 0, "Instances", obj_enemy);
        e.t_anchor   = s.t;
        e.enemy_kind = s.kind;
        e.margin_px  = enemy_margin_px;

        // Lane-free vertical placement
        e.y_gui      = s.y_gui;

        // --- Health (simple, kind-based) ---
        var k = (script_exists(scr_enemy_kind_normalize)) ? scr_enemy_kind_normalize(e.enemy_kind) : string(e.enemy_kind);

        var base_hp = 3;
        if (k == "boss")      base_hp = 10;

        e.hp_max = base_hp;
        e.hp     = e.hp_max;

        // Mark spawned + write back struct
        s.spawned = true;
        enemy_spawns[next_spawn_i] = s;

        spawn_index++;
        next_spawn_i++;
        continue;
    }

    // Not time to spawn next one yet
    break;
}

/// obj_pickup_manager : Step
///
/// Marker-driven pickup spawning:
/// - Spawns pickup objects using per-spawn y_gui
/// - Safe if pickup objects don't exist (skips)
/// - Clears pickups in editor mode to keep preview clean

// ----------------------------------------------------
// Editor behavior: clear live pickups + reset
// ----------------------------------------------------
if (global.editor_on)
{
    next_pickup_i = 0;

    // Destroy any existing pickup instances if they exist
    var o;
    o = asset_get_index("pup_chart"); if (o != -1) with (o) instance_destroy();
    o = asset_get_index("pup_eyes");  if (o != -1) with (o) instance_destroy();
    o = asset_get_index("pup_shard"); if (o != -1) with (o) instance_destroy();

    exit;
}

if (!is_array(pickup_spawns)) exit;

// ----------------------------------------------------
// Timing
// ----------------------------------------------------
var now_t = scr_chart_time();
var gw    = display_get_gui_width();
var pps   = scr_timeline_pps();
if (pps <= 0) pps = 1;

var hitx = 448;
if (variable_global_exists("HIT_X_GUI")) hitx = global.HIT_X_GUI;

var lead_s = (gw + pickup_margin_px - hitx) / pps;

// Safe vertical bounds
var top = 140;
var bot = display_get_gui_height() - 140;

// ----------------------------------------------------
// Spawn loop
// ----------------------------------------------------
while (next_pickup_i < array_length(pickup_spawns))
{
    var s = pickup_spawns[next_pickup_i];

    if (s.spawned) { next_pickup_i++; continue; }

    if (now_t >= s.t - lead_s - 0.10)
    {
        // Determine object by kind
        var kind = (variable_struct_exists(s, "kind") ? string_lower(string(s.kind)) : "shard");
        var obj_name = "pup_shard";
        if (kind == "chart") obj_name = "pup_chart";
        else if (kind == "eyes") obj_name = "pup_eyes";
        else obj_name = "pup_shard";

        var obj_pick = asset_get_index(obj_name);

        // Only spawn if the object exists in the project
        if (obj_pick != -1)
        {
            var p = instance_create_layer(0, 0, "Instances", obj_pick);

            // Anchor time so the pickup can align to the timeline like enemies do (if your pickup uses it)
            p.t_anchor  = s.t;
            p.margin_px = pickup_margin_px;

            // Lane-free vertical placement
            p.y_gui = clamp(s.y_gui, top, bot);

            // Optional: store kind for debugging/FX
            p.pickup_kind = kind;
        }

        // Mark spawned
        s.spawned = true;
        pickup_spawns[next_pickup_i] = s;

        next_pickup_i++;
        continue;
    }

    break;
}

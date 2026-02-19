/// scr_player_snap_to_spawn()
/// Snap player to spawn, then drop onto ground using FEET probe (bbox bottom),
/// so sprites with different origins land correctly.
///
/// IMPORTANT:
/// If the first chunk hasn't been stamped into tm_collide yet, scr_solid_at() will
/// report "no ground" and this script will push the player downward.
/// So we gate the "drop" until streaming is ready.

if (!variable_global_exists("player") || !instance_exists(global.player)) exit;
if (!variable_global_exists("player_world_y")) exit;

if (!variable_global_exists("spawn_y_offset")) global.spawn_y_offset = 0;

// --- STREAMING GATE ---
// The chunk manager will set this true after the first chunk is stamped.
// Until then, we only place the player at spawn_y and DO NOT try to find ground.
if (!variable_global_exists("level_stream_ready")) global.level_stream_ready = false;

with (global.player)
{
    // Base spawn
    spawn_y = global.player_world_y + global.spawn_y_offset;
    y = spawn_y;

    // If streaming isn't ready yet, DO NOT unstick/drop (prevents falling under the floor)
    if (!global.level_stream_ready) exit;

    // Determine a stable sprite to probe with
    var spr = sprite_index;
    if (spr == -1)
    {
        if (variable_instance_exists(id, "SPR_IDLE")) spr = SPR_IDLE;
    }
    if (spr == -1) exit;

    // Cache bbox + offsets ONCE
    var xoff   = sprite_get_xoffset(spr);
    var yoff   = sprite_get_yoffset(spr);
    var bbox_l = sprite_get_bbox_left(spr);
    var bbox_r = sprite_get_bbox_right(spr);
    var bbox_b = sprite_get_bbox_bottom(spr);

    // Feet probe X (center of bbox)
    var probe_x = x + (((bbox_l + bbox_r) * 0.5) - xoff);

    // Feet probe Y (bottom of bbox)
    var probe_y = y + (bbox_b - yoff);

    // Unstick: if feet are inside solid, move UP until clear
    var safety = 512;
    while (safety > 0 && scr_solid_at(probe_x, probe_y))
    {
        y -= 1;
        probe_y = y + (bbox_b - yoff);
        safety--;
    }

    // Drop: move DOWN until standing on solid
    safety = 512;
    while (safety > 0 && !scr_solid_at(probe_x, probe_y + 1))
    {
        y += 1;
        probe_y = y + (bbox_b - yoff);
        safety--;
    }

    // Reset movement / grounded (only if vars exist)
    if (variable_instance_exists(id, "vsp")) vsp = 0;
    if (variable_instance_exists(id, "hsp")) hsp = 0;

    if (variable_instance_exists(id, "grounded"))
        grounded = scr_solid_at(probe_x, probe_y + 1);
}

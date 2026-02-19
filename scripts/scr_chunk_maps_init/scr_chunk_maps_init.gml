/// scr_chunk_maps_init()
/// Cache tile layer + tilemap IDs for collide + 3 visuals.
/// (NO visibility toggling here)

function scr_chunk_maps_init()
{
    global.layer_vis_easy_id   = layer_get_id("TL_Visual_Easy");
    global.layer_vis_normal_id = layer_get_id("TL_Visual_Normal");
    global.layer_vis_hard_id   = layer_get_id("TL_Visual_Hard");
    global.layer_collide_id    = layer_get_id("TL_Collide");

    global.tm_vis_easy   = (global.layer_vis_easy_id   != -1) ? layer_tilemap_get_id(global.layer_vis_easy_id)   : -1;
    global.tm_vis_normal = (global.layer_vis_normal_id != -1) ? layer_tilemap_get_id(global.layer_vis_normal_id) : -1;
    global.tm_vis_hard   = (global.layer_vis_hard_id   != -1) ? layer_tilemap_get_id(global.layer_vis_hard_id)   : -1;
    global.tm_collide    = (global.layer_collide_id    != -1) ? layer_tilemap_get_id(global.layer_collide_id)    : -1;

    // Legacy compatibility (avoid old exits)
    global.tm_visual = global.tm_vis_normal;

    // Optional debug
    // show_debug_message("[Maps] room=" + room_get_name(room)
    //     + " tmE/N/H/C=" + string(global.tm_vis_easy) + "/" + string(global.tm_vis_normal) + "/" + string(global.tm_vis_hard) + "/" + string(global.tm_collide));
}
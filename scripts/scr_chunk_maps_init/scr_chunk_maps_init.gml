/// scr_chunk_maps_init()
/// Cache tile layer + tilemap IDs for collide + 3 visuals.
/// Select active visual tilemap based on requested difficulty + availability.

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

    var d = "";
    if (variable_global_exists("difficulty")) d = string(global.difficulty);
    else if (variable_global_exists("DIFFICULTY")) d = string(global.DIFFICULTY);
    d = string_lower(string_replace_all(d, " ", ""));

    var want_hard   = (d == "hard"   || d == "2");
    var want_normal = (d == "normal" || d == "1");
    var want_easy   = (d == "easy"   || d == "0");

    global.tm_visual = -1;

    if (want_hard && global.tm_vis_hard != -1) {
        global.tm_visual = global.tm_vis_hard;
    } else if (want_normal && global.tm_vis_normal != -1) {
        global.tm_visual = global.tm_vis_normal;
    } else if (want_easy && global.tm_vis_easy != -1) {
        global.tm_visual = global.tm_vis_easy;
    } else if (global.tm_vis_hard != -1) {
        global.tm_visual = global.tm_vis_hard;
    } else if (global.tm_vis_normal != -1) {
        global.tm_visual = global.tm_vis_normal;
    } else if (global.tm_vis_easy != -1) {
        global.tm_visual = global.tm_vis_easy;
    }

    // Optional debug
    // show_debug_message("[Maps] room=" + room_get_name(room)
    //     + " tmE/N/H/C=" + string(global.tm_vis_easy) + "/" + string(global.tm_vis_normal) + "/" + string(global.tm_vis_hard) + "/" + string(global.tm_collide)
    //     + " tm_visual=" + string(global.tm_visual));
}

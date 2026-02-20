/// scr_chunk_maps_init()
/// Cache tile layer + tilemap IDs for collide + 3 visuals.
/// Select a valid global.tm_visual based on difficulty + availability.

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

    // Pick tm_visual safely (NORMAL may be -1 in rm_level01 because tilesetId is null)
    var diff = "normal";
    if (variable_global_exists("difficulty")) diff = string_lower(string(global.difficulty));
    else if (variable_global_exists("DIFFICULTY")) diff = string_lower(string(global.DIFFICULTY));
    diff = string_replace_all(diff, " ", "");

    if (diff == "easy" && global.tm_vis_easy != -1) global.tm_visual = global.tm_vis_easy;
    else if (diff == "hard" && global.tm_vis_hard != -1) global.tm_visual = global.tm_vis_hard;
    else if (global.tm_vis_normal != -1) global.tm_visual = global.tm_vis_normal;
    else if (global.tm_vis_hard != -1) global.tm_visual = global.tm_vis_hard;
    else if (global.tm_vis_easy != -1) global.tm_visual = global.tm_vis_easy;
    else global.tm_visual = -1;
}
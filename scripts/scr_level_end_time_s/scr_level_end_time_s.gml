/// scr_level_end_time_s()
function scr_level_end_time_s()
{
    scr_level_end_config_init();

    if (!variable_global_exists("level_end_cfg_init") || !global.level_end_cfg_init)
        return -1;

    if (!variable_global_exists("level_end_cfg"))
        return -1;

    var key = room_get_name(room);

    if (!ds_map_exists(global.level_end_cfg, key))
        return -1;

    var cfg = global.level_end_cfg[? key];

    if (!ds_map_exists(cfg, "end_s"))
        return -1;

    return cfg[? "end_s"];
}
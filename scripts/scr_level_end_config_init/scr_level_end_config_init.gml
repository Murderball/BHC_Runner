/// scr_level_end_config_init()
function scr_level_end_config_init()
{
    // Prevent re-initializing
    if (variable_global_exists("level_end_cfg_init") && global.level_end_cfg_init)
        return;

    // Create registry map
    global.level_end_cfg = ds_map_create();

    // Internal registration helper
    function _reg(_level_room_name, _boss_room_name, _end_s, _warn_s, _fade_s)
    {
        var entry = ds_map_create();
        ds_map_add(entry, "boss_room", _boss_room_name);
        ds_map_add(entry, "end_s", _end_s);
        ds_map_add(entry, "warn_s", _warn_s);
        ds_map_add(entry, "fade_s", _fade_s);

        ds_map_add(global.level_end_cfg, _level_room_name, entry);
    } 

    // ------------------------------------------------------------
    // EDIT THESE TIMES (seconds in chart time)
    // end_s = transition time, warn_s = warning lead, fade_s = fade length
    // ------------------------------------------------------------
    _reg("rm_level01", "rm_boss_1", 189.23, 190.41, 191.09);
    _reg("rm_level03", "rm_boss_3", 195.79, 195.45, 196.39);

    // Add more as needed:
    // _reg("rm_level05", "rm_boss_5", 120.0, 135.0, 155.0);

    global.level_end_cfg_init = true;
}

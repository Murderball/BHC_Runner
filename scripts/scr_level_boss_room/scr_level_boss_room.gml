/// scr_level_boss_room_key(level_key) -> room asset index or -1
function scr_level_boss_room_key(_level_key)
{
    scr_level_end_config_init();

    if (!variable_global_exists("level_end_cfg_init") || !global.level_end_cfg_init)
        return -1;

    if (!variable_global_exists("level_end_cfg"))
        return -1;

    var key = is_string(_level_key) ? _level_key : room_get_name(room);

    if (!ds_map_exists(global.level_end_cfg, key))
        return -1;

    var cfg = global.level_end_cfg[? key];

    if (!ds_map_exists(cfg, "boss_room"))
        return -1;

    var boss_key = cfg[? "boss_room"];

    if (!is_string(boss_key))
        return -1;

    var r = asset_get_index(boss_key);
    return is_real(r) ? r : -1;
}

/// scr_level_boss_room([level_key]) -> room asset index or -1
function scr_level_boss_room(_level_key = undefined)
{
    var key = _level_key;
    if (is_undefined(key) || !is_string(key) || key == "") {
        key = room_get_name(room);
    }

    return scr_level_boss_room_key(key);
}

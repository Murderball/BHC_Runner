/// scr_level_end_time_s([level_key]) -> seconds or -1
function scr_level_end_time_s(_level_key)
{
    scr_level_end_config_init();

    var key = is_string(_level_key) ? _level_key : room_get_name(room);

    if (!variable_global_exists("level_end_cfg_init") || !global.level_end_cfg_init) return -1;
    if (!variable_global_exists("level_end_cfg") || !is_struct(global.level_end_cfg)) return -1;
    if (!variable_struct_exists(global.level_end_cfg, key)) return -1;

    var cfg = global.level_end_cfg?[key];
    if (!is_struct(cfg)) return -1;

    var t = cfg.end_s;
    return is_real(t) ? t : -1;
}

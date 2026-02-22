/// scr_level_boss_room([level_key]) -> room asset index or -1
function scr_level_boss_room(_level_key)
{
    scr_level_end_config_init();

    var key = is_string(_level_key) ? _level_key : scr_level_key_current();
    if (!is_struct(global.level_end_cfg)) return -1;
    if (!variable_struct_exists(global.level_end_cfg, key)) return -1;

    var cfg = variable_struct_get(global.level_end_cfg, key);
    if (!is_struct(cfg)) return -1;

    var r = cfg.boss_room;
    return is_real(r) ? r : -1;
}

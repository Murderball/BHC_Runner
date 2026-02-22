/// scr_level_end_config_init()
function scr_level_end_config_init()
{
    if (variable_global_exists("level_end_cfg") && is_struct(global.level_end_cfg)) return;

    global.level_end_cfg = {};

    function _reg(_level_room_name, _boss_room_name, _easy_s, _norm_s, _hard_s)
    {
        var boss_rm = asset_get_index(_boss_room_name); // -1 if missing
        global.level_end_cfg[@ _level_room_name] = {
            boss_room: boss_rm,
            end_s: [ _easy_s, _norm_s, _hard_s ]
        };
    }

    // ------------------------------------------------------------
    // EDIT THESE TIMES (seconds in chart time) PER DIFFICULTY
    // end_s = [easy, normal, hard]
    // ------------------------------------------------------------
    _reg("rm_level01", "rm_boss_1", 189.23, 190.41, 191.09);
    _reg("rm_level03", "rm_boss_3", 195.79, 195.45, 196.39);

    // Add more as needed:
    // _reg("rm_level05", "rm_boss_5", 120.0, 135.0, 155.0);
}

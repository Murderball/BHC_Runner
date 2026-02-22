/// scr_boss_room_for_level(level_key)
function scr_boss_room_for_level(_level_key)
{
    var lk = string_lower(string(_level_key));

    if (variable_global_exists("BOSS_DEF_BY_LEVEL") && is_struct(global.BOSS_DEF_BY_LEVEL)) {
        if (variable_struct_exists(global.BOSS_DEF_BY_LEVEL, lk)) {
            var _def = global.BOSS_DEF_BY_LEVEL[$ lk];
            if (is_struct(_def) && variable_struct_exists(_def, "room")) return _def.room;
        }
    }

    if (lk == "level01") return rm_boss_1;
    if (lk == "level03") return rm_boss_3;

    if (variable_global_exists("BOSS_ROOM")) return global.BOSS_ROOM;
    return rm_boss_3;
}

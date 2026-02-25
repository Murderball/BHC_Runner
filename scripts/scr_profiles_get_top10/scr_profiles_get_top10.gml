/// scr_profiles_get_top10(level_key, difficulty_key) -> array
function scr_profiles_get_top10(_level_key, _difficulty_key)
{
    var p = script_exists(scr_profiles_get_active) ? scr_profiles_get_active() : undefined;
    if (!is_struct(p)) return [];

    var lk = string(_level_key);
    var dk = string_lower(string(_difficulty_key));

    if (!variable_struct_exists(p.arcade.leaderboards, lk)) return [];
    var level_board = p.arcade.leaderboards[$ lk];
    if (!is_struct(level_board) || !variable_struct_exists(level_board, dk) || !is_array(level_board[$ dk])) return [];

    return level_board[$ dk];
}

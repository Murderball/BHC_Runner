/// scr_profiles_record_run(level_key, difficulty_key, accuracy01)
function scr_profiles_record_run(_level_key, _difficulty_key, _accuracy01)
{
    var p = script_exists(scr_profiles_get_active) ? scr_profiles_get_active() : undefined;
    if (!is_struct(p)) return false;

    var lk = string(_level_key);
    if (lk == "") lk = room_get_name(room);
    var dk = string_lower(string(_difficulty_key));
    if (dk == "") dk = "normal";

    var acc01 = real(_accuracy01);
    acc01 = clamp(acc01, 0, 1);

    if (!variable_struct_exists(p.arcade.leaderboards, lk) || !is_struct(p.arcade.leaderboards[$ lk])) {
        p.arcade.leaderboards[$ lk] = {};
    }
    var level_board = p.arcade.leaderboards[$ lk];
    if (!variable_struct_exists(level_board, dk) || !is_array(level_board[$ dk])) level_board[$ dk] = [];

    var entries = level_board[$ dk];
    array_push(entries, { name: p.name, accuracy: acc01, t: current_time });

    var n = array_length(entries);
    for (var i = 0; i < n - 1; i++) {
        for (var j = i + 1; j < n; j++) {
            var ai = entries[i].accuracy;
            var aj = entries[j].accuracy;
            if (aj > ai) {
                var tmp = entries[i];
                entries[i] = entries[j];
                entries[j] = tmp;
            }
        }
    }
    while (array_length(entries) > 10) array_pop(entries);

    level_board[$ dk] = entries;
    p.arcade.leaderboards[$ lk] = level_board;
    p.updated_at = current_time;

    for (var k = 0; k < array_length(global.profiles_data.profiles); k++) {
        if (global.profiles_data.profiles[k].id == p.id) {
            global.profiles_data.profiles[k] = p;
            break;
        }
    }
    return true;
}

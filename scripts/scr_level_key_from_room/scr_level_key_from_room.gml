/// scr_level_key_from_room([room_id]) -> "level01", "level03", etc.
function scr_level_key_from_room(_room_id)
{
    var rid = (argument_count >= 1) ? _room_id : room;
    var rn = room_get_name(rid);
    if (!is_string(rn) || rn == "") return "";

    rn = string_lower(rn);

    var level_num = -1;

    // Primary gameplay naming convention: rm_levelNN...
    var p = string_pos("rm_level", rn);
    if (p == 1) {
        var i = p + string_length("rm_level");
        var digits = "";
        while (i <= string_length(rn)) {
            var ch = string_char_at(rn, i);
            if (ch >= "0" && ch <= "9") {
                digits += ch;
                i += 1;
            } else {
                break;
            }
        }
        if (digits != "") level_num = real(digits);
    }

    // Boss naming convention: rm_boss_<n>
    if (level_num < 0 && string_pos("rm_boss_", rn) == 1) {
        var j = string_length("rm_boss_") + 1;
        var d2 = "";
        while (j <= string_length(rn)) {
            var ch2 = string_char_at(rn, j);
            if (ch2 >= "0" && ch2 <= "9") {
                d2 += ch2;
                j += 1;
            } else {
                break;
            }
        }
        if (d2 != "") level_num = real(d2);
    }

    if (level_num < 1) return "";

    var ns = string(level_num);
    if (string_length(ns) < 2) ns = "0" + ns;
    return "level" + ns;
}

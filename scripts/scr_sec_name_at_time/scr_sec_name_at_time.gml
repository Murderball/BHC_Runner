/// scr_sec_name_at_time(t)
/// Safe section lookup (won't crash if sections aren't initialized yet)

function scr_sec_name_at_time(t)
{
    scr_level_master_sections_init();

    if (!variable_global_exists("master_sections") || !is_array(global.master_sections)) {
        return "intro";
    }

    var arr = global.master_sections;
    if (array_length(arr) <= 0) return "intro";

    if (t < arr[0].t0) return arr[0].name;

    for (var i = 0; i < array_length(arr); i++) {
        var s = arr[i];
        if (t >= s.t0 && t < s.t1) return s.name;
    }

    return arr[array_length(arr) - 1].name;
}

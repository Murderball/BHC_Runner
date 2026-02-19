/// scr_sec_to_stem(name) -> string
function scr_sec_to_stem(name)
{
    var s = string_lower(string(name));

    // normalize spaces (just in case)
    s = string_replace_all(s, " ", "");

    // Level 1 special-case:
    // "Intro_1" should map to "intro" to match rm1_chunk_intro_00..04
    if (variable_global_exists("LEVEL_KEY") && global.LEVEL_KEY == "level01") {
        if (string_pos("intro_", s) == 1) return "intro";
    }

    return s;
}

function scr_sfx_play(_name_or_enum)
{
    static warned = {};
    var key = string(_name_or_enum);
    if (!variable_struct_exists(warned, key)) {
        warned[$ key] = true;
        show_debug_message("[FMOD] SFX not mapped: " + key);
    }
}

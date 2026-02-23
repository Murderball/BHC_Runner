/// scr_fmod_event_play(event_path, start_ms=0, volume=1.0)
/// Returns: instance id (real) or 0 on failure
function scr_fmod_event_play(_event_path, _start_ms = 0, _volume = 1.0)
{
    if (!variable_global_exists("fmod_ready") || !global.fmod_ready) return 0;
    if (!is_string(_event_path) || string_length(_event_path) == 0) return 0;

    var ed = fmod_studio_system_get_event(_event_path);
    if (ed == 0) return 0;

    var inst = fmod_studio_event_description_create_instance(ed);
    if (inst == 0) return 0;

    if (_start_ms > 0) fmod_studio_event_instance_set_timeline_position(inst, _start_ms);

    fmod_studio_event_instance_set_volume(inst, _volume);
    fmod_studio_event_instance_start(inst);

    return inst;
}

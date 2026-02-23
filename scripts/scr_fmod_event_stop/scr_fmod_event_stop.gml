/// scr_fmod_event_stop(inst, allow_fadeout=true, release=true)
function scr_fmod_event_stop(_inst, _allow_fadeout = true, _release = true)
{
    if (_inst == 0) return;
    if (!fmod_studio_event_instance_is_valid(_inst)) return;

    var mode = _allow_fadeout ? FMOD_STUDIO_STOP_MODE.ALLOWFADEOUT : FMOD_STUDIO_STOP_MODE.IMMEDIATE;
    fmod_studio_event_instance_stop(_inst, mode);

    if (_release) fmod_studio_event_instance_release(_inst);
}

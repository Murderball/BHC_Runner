/// scr_boss_timeline_update()
/// Boss-room-only timeline driver.
/// - If boss music is playing, lock timeline to scr_song_time()
/// - If music isn't available, advance using delta_time so notes still scroll
function scr_boss_timeline_update()
{
    // Only run in boss mode + boss room
    if (!variable_global_exists("LEVEL_MODE")) return;
    if (global.LEVEL_MODE != "boss") return;

    if (!variable_global_exists("BOSS_ROOM")) return;
    if (room != global.BOSS_ROOM) return;

    // Editor always owns time
    if (variable_global_exists("editor_on") && global.editor_on) return;

    if (!variable_global_exists("BOSS_TIMELINE_S")) global.BOSS_TIMELINE_S = 0.0;

    var use_audio = (variable_global_exists("song_playing") && global.song_playing
                     && variable_global_exists("song_handle") && global.song_handle >= 0);

    if (use_audio)
    {
        // Lock to audio time (your canonical gameplay clock)
        global.BOSS_TIMELINE_S = scr_song_time();
    }
    else
    {
        // Fallback: keep advancing even if audio isn't ready for a moment
        var dt = delta_time * 0.000001; // microseconds -> seconds
        if (!is_real(dt) || is_nan(dt) || dt < 0) dt = 0;
        global.BOSS_TIMELINE_S += dt;
    }
}

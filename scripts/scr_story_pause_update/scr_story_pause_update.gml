function scr_story_pause_update()
{
    if (!variable_global_exists("story_events") || !is_array(global.story_events)) return;
    if (!variable_global_exists("story_idx")) global.story_idx = 0;

    if (global.story_state == "idle") {
        if (global.story_idx >= array_length(global.story_events)) return;
        var now_t = scr_song_time();
        var evp = global.story_events[global.story_idx];
        if (!is_struct(evp) || evp.done) { global.story_idx += 1; return; }
        if (now_t < evp.t) return;

        global.STORY_PAUSED = true;
        global.story_song_was_playing = variable_global_exists("song_playing") && global.song_playing;
        global.story_state = "npc_playing";
        global.story_timer = max(0, evp.fade_out_ms) / 1000.0;

        if (variable_struct_exists(evp, "event_name") && string(evp.event_name) != "") {
            if (evp.event_name == "Pause_Loop") {
                scr_fmod_pause_loop_set(true);
            } else {
                scr_sfx_play(evp.event_name);
            }
        }
        return;
    }

    if (global.story_state == "npc_playing") {
        var evp2 = global.story_events[global.story_idx];
        var looping = variable_struct_exists(evp2, "loop") && (evp2.loop == true);
        if (variable_struct_exists(evp2, "event_name") && evp2.event_name == "Pause_Loop") looping = true;

        var has_choices = variable_struct_exists(evp2, "choices") && is_array(evp2.choices) && array_length(evp2.choices) > 0;
        if (has_choices) {
            scr_story_choice_begin(evp2);
            global.story_state = "choice";
            return;
        }

        if (looping) {
            if (global.in_confirm || global.in_cancel) scr_story_pause_resume(evp2);
            return;
        }

        if (variable_struct_exists(evp2, "wait_confirm") && evp2.wait_confirm == true) {
            global.story_state = "wait_input";
        } else {
            scr_story_pause_resume(evp2);
        }
        return;
    }

    if (global.story_state == "choice") {
        // leave existing choice handler in place via old script logic if any
        return;
    }

    if (global.story_state == "wait_input") {
        var evp3 = global.story_events[global.story_idx];
        if (global.in_confirm || global.in_cancel) scr_story_pause_resume(evp3);
        return;
    }

    if (global.story_state == "fade_in") {
        global.story_timer -= delta_time / 1000000.0;
        if (global.story_timer <= 0) {
            global.story_state = "idle";
            global.STORY_PAUSED = false;
            if (global.story_idx < array_length(global.story_events)) {
                global.story_events[global.story_idx].done = true;
                global.story_idx += 1;
            }
        }
    }
}

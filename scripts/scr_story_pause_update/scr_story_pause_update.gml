/// scr_story_pause_update()
function scr_story_pause_update()
{
    // Don't run during editor
    if (global.editor_on) return;

    // Safety: ignore story triggers right after start
    if (!variable_global_exists("STORY_IGNORE_BEFORE_S")) global.STORY_IGNORE_BEFORE_S = 1.50;

    // No events? nothing to do
    if (!is_array(global.story_events)) return;
    var n = array_length(global.story_events);
    if (n <= 0) return;

    // Only trigger if song is actually playing
    if (!global.song_playing || global.song_handle < 0) return;

    var t_now = scr_song_time();
    if (t_now < global.STORY_IGNORE_BEFORE_S) return;

    // ------------------------------------------------------------
    // 1) If not paused, check whether we should trigger next event
    // ------------------------------------------------------------
    if (!global.STORY_PAUSED)
    {
        // Find next non-done event
        var next_i = -1;
        for (var i = 0; i < n; i++) {
            if (!global.story_events[i].done) { next_i = i; break; }
        }
        if (next_i < 0) return;

        var ev = global.story_events[next_i];

        // Trigger when we reach/past the time.
        if (t_now >= ev.t) {
            global.story_idx = next_i;
            global.story_events[next_i].done = true;
            scr_story_pause_start(ev);
        }

        return;
    }

    // ------------------------------------------------------------
    // 2) We ARE paused: advance state machine
    // ------------------------------------------------------------
    var idx = clamp(global.story_idx, 0, n - 1);
    var evp = global.story_events[idx];

    // Countdown timers
    if (global.story_timer > 0) {
        global.story_timer -= (1.0 / game_get_speed(gamespeed_fps));
        if (global.story_timer < 0) global.story_timer = 0;
    }

    switch (global.story_state)
    {
        case "choice":
        {
            // If no options, fall back to wait_input behavior
            if (!is_array(global.story_choice_options) || array_length(global.story_choice_options) <= 0) {
                global.story_state = "wait_input";
                break;
            }

            // Navigation
            var left  = keyboard_check_pressed(vk_left);
            var right = keyboard_check_pressed(vk_right);
            var up    = keyboard_check_pressed(vk_up);
            var down  = keyboard_check_pressed(vk_down);

            if (left || up) {
                global.story_choice_sel--;
                if (global.story_choice_sel < 0) global.story_choice_sel = array_length(global.story_choice_options) - 1;
            }

            if (right || down) {
                global.story_choice_sel++;
                if (global.story_choice_sel >= array_length(global.story_choice_options)) global.story_choice_sel = 0;
            }

            // Confirm
            if (global.in_confirm)
            {
                global.story_choice_last_idx = global.story_choice_sel;
                global.story_choice_last = string(global.story_choice_options[global.story_choice_sel]);
                global.story_choice_active = false;
                scr_story_pause_resume(evp);
            }

            // Cancel
            if (global.in_cancel)
            {
                global.story_choice_last_idx = -1;
                global.story_choice_last = "cancel";
                global.story_choice_active = false;
                scr_story_pause_resume(evp);
            }
        } break;

        case "fade_out":
        {
            if (global.story_timer <= 0)
            {
                if (global.story_song_was_playing) {
                    audio_pause_sound(global.song_handle);
                }

                // Play NPC audio
                global.story_npc_handle = -1;
                if (variable_struct_exists(evp, "snd") && evp.snd != -1)
                {
                    // Marker-controlled loop, BUT snd_pause always loops (your pause music)
                    var do_loop = false;
                    if (variable_struct_exists(evp, "loop")) do_loop = (evp.loop == true);

                    // Force loop for pause bed even if marker lost the flag
                    if (evp.snd == snd_pause) do_loop = true;

                    global.story_npc_handle = audio_play_sound(evp.snd, 1, do_loop);
                }

                global.story_state = "npc_playing";
            }
        } break;

        case "npc_playing":
        {
            var looping = false;
            if (variable_struct_exists(evp, "loop")) looping = (evp.loop == true);
            if (variable_struct_exists(evp, "snd") && evp.snd == snd_pause) looping = true;

            var wait_confirm = variable_struct_exists(evp, "wait_confirm") && (evp.wait_confirm == true);

            var has_choices = variable_struct_exists(evp, "choices")
                && is_array(evp.choices)
                && array_length(evp.choices) > 0;

            // Choice events go straight to choice state
            if (has_choices) {
                scr_story_choice_begin(evp);
                global.story_state = "choice";
                break;
            }

            // Looping: allow confirm/cancel to resume anytime
            if (looping) {
                if (global.in_confirm || global.in_cancel) {
                    scr_story_pause_resume(evp);
                }
                break;
            }

            // Non-looping: wait until clip ends
            var npc_done = true;
            if (global.story_npc_handle >= 0) {
                npc_done = !audio_is_playing(global.story_npc_handle);
            }

            if (npc_done)
            {
                if (wait_confirm) global.story_state = "wait_input";
                else scr_story_pause_resume(evp);
            }
        } break;

        case "wait_input":
        {
            if (global.in_confirm || global.in_cancel) {
                scr_story_pause_resume(evp);
            }
        } break;

        case "fade_in":
        {
            if (global.story_timer <= 0) {
                global.story_state = "idle";
                global.STORY_PAUSED = false;
            }
        } break;
    }
}

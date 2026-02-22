function scr_master_keybind_debug_update()
{
    if (!variable_global_exists("DEBUG_KEYBINDS") || !global.DEBUG_KEYBINDS) return;

    var _markers = (variable_global_exists("markers") && is_array(global.markers)) ? global.markers : [];
    var _sel_i = variable_global_exists("editor_marker_sel") ? global.editor_marker_sel : -1;

    var _find_room_goto_ahead = function() {
        var _best = -1;
        var _best_dt = 999999999;
        var _now_t = script_exists(scr_chart_time) ? scr_chart_time() : current_time / 1000;

        for (var i = 0; i < array_length(_markers); i++) {
            var m = _markers[i];
            if (!is_struct(m)) continue;
            var _kind = variable_struct_exists(m, "kind") ? string(m.kind) : (variable_struct_exists(m, "type") ? string(m.type) : "");
            if (_kind != "room_goto") continue;
            if (!variable_struct_exists(m, "t")) continue;

            var dt = real(m.t) - _now_t;
            if (dt < 0) continue;
            if (dt < _best_dt) {
                _best_dt = dt;
                _best = i;
            }
        }

        return _best;
    };

    if (keyboard_check_pressed(vk_f6))
    {
        var _i6 = _find_room_goto_ahead();
        if (_i6 >= 0) {
            var m6 = _markers[_i6];
            var idx6 = variable_struct_exists(m6, "side_idx") ? floor(real(m6.side_idx)) : 0;
            var dst6 = script_exists(scr_side_room_name_from_index) ? scr_side_room_name_from_index(idx6) : ("rm_side_" + string(idx6));
            scr_request_room_transition(dst6, { source: "room_goto", side_idx: idx6, reason: "debug_f6" });
        }
    }

    if (keyboard_check_pressed(vk_f7))
    {
        var _target_i = _sel_i;
        if (_target_i < 0 || _target_i >= array_length(_markers)) _target_i = _find_room_goto_ahead();

        if (_target_i >= 0)
        {
            var m7 = _markers[_target_i];
            var kind7 = variable_struct_exists(m7, "kind") ? string(m7.kind) : (variable_struct_exists(m7, "type") ? string(m7.type) : "");
            if (kind7 == "room_goto")
            {
                var dir = keyboard_check(vk_shift) ? -1 : 1;
                var idx7 = variable_struct_exists(m7, "side_idx") ? floor(real(m7.side_idx)) : 0;

                if (script_exists(scr_marker_room_goto_set_idx)) scr_marker_room_goto_set_idx(m7, idx7 + dir);
                else m7.side_idx = idx7 + dir;

                global.markers[_target_i] = m7;
            }
        }
    }

    if (keyboard_check_pressed(vk_f8))
    {
        if (!global.GAME_PAUSED)
        {
            global.GAME_PAUSED = true;
            if (variable_global_exists("song_handle") && global.song_handle >= 0) audio_pause_sound(global.song_handle);
            if (variable_global_exists("story_npc_handle") && global.story_npc_handle >= 0) audio_pause_sound(global.story_npc_handle);
            if (script_exists(scr_song_time)) global.pause_song_time = scr_song_time();
        }
        else
        {
            global.GAME_PAUSED = false;
            if (variable_global_exists("song_handle") && global.song_handle >= 0) audio_resume_sound(global.song_handle);
            if (variable_global_exists("story_npc_handle") && global.story_npc_handle >= 0) audio_resume_sound(global.story_npc_handle);
            scr_countdown_begin("unpause");
        }
    }

    if (keyboard_check_pressed(vk_f9))
    {
        var _router = variable_global_exists("STORY_ROUTER") ? json_stringify(global.STORY_ROUTER) : "{}";
        var _return = variable_global_exists("STORY_RETURN") ? json_stringify(global.STORY_RETURN) : "{}";
        show_debug_message("[debug:f9] router=" + _router);
        show_debug_message("[debug:f9] return=" + _return);
        show_debug_message("[debug:f9] countdown active=" + string(global.COUNTDOWN_ACTIVE)
            + " t=" + string(global.COUNTDOWN_TIMER_S)
            + " reason=" + string(global.COUNTDOWN_REASON));
    }
    if (keyboard_check_pressed(vk_f10))
    {
        var m = scr_room_gate_make(scr_chart_time() + 2, "rm_miniboss_1");

        if (variable_global_exists("CHART_MARKERS") && is_array(global.CHART_MARKERS))
        {
            array_push(global.CHART_MARKERS, m);
        }

        if (variable_global_exists("markers") && is_array(global.markers))
        {
            array_push(global.markers, m);
        }

        show_debug_message("Added room_gate marker.");
    }

}

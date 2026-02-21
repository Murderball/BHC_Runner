/// obj_input_recorder_machine : Step
var shift_down = keyboard_check(vk_shift);
if (shift_down && keyboard_check_pressed(ord("R")))
{
    recording_enabled = !recording_enabled;

    if (recording_enabled)
    {
        current_take = [];
        take_start_time = scr_chart_time();
        prev_chart_time = take_start_time;
    }
    else
    {
        if (array_length(current_take) > 0)
        {
            var path = variable_global_exists("chart_file") ? string(global.chart_file) : "";
            var chart_struct = { notes: global.chart };

            if (path != "" && file_exists(path))
            {
                var fh = file_text_open_read(path);
                if (fh >= 0)
                {
                    var txt = "";
                    while (!file_text_eof(fh)) {
                        txt += file_text_read_string(fh);
                        file_text_readln(fh);
                    }
                    file_text_close(fh);
                    txt = string_trim(txt);
                    if (txt != "") {
                        var parsed = json_parse(txt);
                        if (is_struct(parsed)) {
                            chart_struct = parsed;
                        } else if (is_array(parsed)) {
                            chart_struct = { notes: parsed };
                        }
                    }
                }
            }

            chart_struct = scr_recorder_merge_take_into_chart(current_take, chart_struct);
            scr_recorder_save_chart(chart_struct);
            global.recorder_last_take_path = scr_recorder_save_take(current_take);
            global.recorder_take_index += 1;
        }
    }
}

var song_is_playing = false;
if (variable_global_exists("song_playing") && global.song_playing
    && variable_global_exists("song_handle") && global.song_handle >= 0)
{
    song_is_playing = audio_is_playing(global.song_handle);
}

var now_t = scr_chart_time();
var chart_advancing = (prev_chart_time >= 0 && now_t > prev_chart_time + 0.00001);
var bpm_now = scr_recorder_get_bpm();

if (recording_enabled && song_is_playing && chart_advancing && bpm_now > 0)
{
    var pushed = scr_recorder_event_from_keypress(now_t);
    for (var i = 0; i < array_length(pushed); i++) {
        array_push(current_take, pushed[i]);
    }
}

prev_chart_time = now_t;

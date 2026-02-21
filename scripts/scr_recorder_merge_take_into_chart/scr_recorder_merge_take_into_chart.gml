function scr_recorder_merge_take_into_chart(take_events, chart_struct)
{
    if (!is_struct(chart_struct)) chart_struct = { notes: [] };

    if (!variable_struct_exists(chart_struct, "notes") || !is_array(chart_struct.notes))
    {
        if (variable_struct_exists(chart_struct, "chart") && is_array(chart_struct.chart)) {
            chart_struct.notes = chart_struct.chart;
        } else {
            chart_struct.notes = [];
        }
    }

    var bpm = (variable_struct_exists(chart_struct, "bpm") && is_real(chart_struct.bpm) && chart_struct.bpm > 0)
        ? chart_struct.bpm
        : ((variable_global_exists("chart_bpm") && is_real(global.chart_bpm) && global.chart_bpm > 0)
            ? global.chart_bpm
            : ((variable_global_exists("BPM") && is_real(global.BPM) && global.BPM > 0) ? global.BPM : 120));

    var notes = chart_struct.notes;
    var slot_map = ds_map_create();

    var kind_for_act = function(_a) {
        switch (string(_a)) {
            case "jump": return "jump";
            case "duck": return "duck";
            case "atk1": return "atk1";
            case "atk2": return "atk2";
            case "atk3": return "atk3";
            case "ult":
            case "ultimate": return "ult";
        }
        return "";
    };

    for (var i = 0; i < array_length(notes); i++)
    {
        var n = notes[i];
        if (!is_struct(n) || !variable_struct_exists(n, "t") || !variable_struct_exists(n, "act")) continue;

        var nkind = kind_for_act(n.act);
        if (nkind == "") continue;

        var qn = scr_recorder_quantize_to_eighth(n.t, bpm);
        var lane = (variable_struct_exists(n, "lane") && is_real(n.lane)) ? floor(n.lane) : -1;
        var slot_key = nkind + ":" + string(qn.grid8) + ":" + string(lane);

        if (!ds_map_exists(slot_map, slot_key)) {
            ds_map_set(slot_map, slot_key, i);
        } else {
            var prev_i = ds_map_find_value(slot_map, slot_key);
            var prev_n = notes[prev_i];
            var prev_err = variable_struct_exists(prev_n, "_rec_err") ? real(prev_n._rec_err) : abs(prev_n.t - qn.grid_time);
            var cur_err = variable_struct_exists(n, "_rec_err") ? real(n._rec_err) : abs(n.t - qn.grid_time);
            if (cur_err < prev_err) ds_map_set(slot_map, slot_key, i);
        }
    }

    for (var t = 0; t < array_length(take_events); t++)
    {
        var ev = take_events[t];
        if (!is_struct(ev)) continue;

        var lane_new = (variable_struct_exists(ev, "lane") && is_real(ev.lane)) ? floor(ev.lane) : -1;
        var slot_key_new = string(ev.kind) + ":" + string(ev.grid8) + ":" + string(lane_new);

        var note_new = {
            t: ev.t,
            lane: lane_new,
            type: "tap",
            act: ev.act,
            _rec_err: ev.err,
            _rec_grid8: ev.grid8,
            _rec_kind: ev.kind
        };

        if (ds_map_exists(slot_map, slot_key_new))
        {
            var idx_old = ds_map_find_value(slot_map, slot_key_new);
            var nold = notes[idx_old];
            var old_err = variable_struct_exists(nold, "_rec_err") ? real(nold._rec_err) : abs(nold.t - ev.grid_time);
            if (ev.err < old_err) {
                notes[idx_old] = note_new;
            }
        }
        else
        {
            array_push(notes, note_new);
            ds_map_set(slot_map, slot_key_new, array_length(notes) - 1);
        }
    }

    ds_map_destroy(slot_map);

    chart_struct.notes = notes;
    chart_struct.chart = notes;
    return chart_struct;
}

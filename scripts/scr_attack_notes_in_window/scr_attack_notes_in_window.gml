/// scr_attack_notes_in_window(action_id, t0, t1)
function scr_attack_notes_in_window(action_id, t0, t1) {

    var lst = global.atk_times_1;
    if (action_id == global.ACT_ATK2) lst = global.atk_times_2;
    if (action_id == global.ACT_ATK3) lst = global.atk_times_3;

    if (!ds_exists(lst, ds_type_list)) return 0;

    // linear scan is fine for now; optimize later with binary search if needed
    var c = 0;
    for (var i = 0; i < ds_list_size(lst); i++) {
        var tt = ds_list_find_value(lst, i);
        if (tt < t0) continue;
        if (tt > t1) break;
        c++;
    }
    return c;
}

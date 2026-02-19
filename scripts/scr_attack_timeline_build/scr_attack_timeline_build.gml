/// scr_attack_timeline_build()
function scr_attack_timeline_build() {

    if (variable_global_exists("atk_times_1")) ds_list_destroy(global.atk_times_1);
    if (variable_global_exists("atk_times_2")) ds_list_destroy(global.atk_times_2);
    if (variable_global_exists("atk_times_3")) ds_list_destroy(global.atk_times_3);

    global.atk_times_1 = ds_list_create();
    global.atk_times_2 = ds_list_create();
    global.atk_times_3 = ds_list_create();

    if (!variable_global_exists("chart") || !is_array(global.chart)) return;

    for (var i = 0; i < array_length(global.chart); i++) {
        var n = global.chart[i];
        if (!is_struct(n)) continue;
        if (!variable_struct_exists(n, "t")) continue;
        if (!variable_struct_exists(n, "act")) continue;

        // act is a STRING: "atk1" / "atk2" / "atk3"
        if (n.act == "atk1") ds_list_add(global.atk_times_1, n.t);
        else if (n.act == "atk2") ds_list_add(global.atk_times_2, n.t);
        else if (n.act == "atk3") ds_list_add(global.atk_times_3, n.t);
    }

    ds_list_sort(global.atk_times_1, true);
    ds_list_sort(global.atk_times_2, true);
    ds_list_sort(global.atk_times_3, true);

    show_debug_message("[atk_timeline] atk1=" + string(ds_list_size(global.atk_times_1)) +
                       " atk2=" + string(ds_list_size(global.atk_times_2)) +
                       " atk3=" + string(ds_list_size(global.atk_times_3)));
}

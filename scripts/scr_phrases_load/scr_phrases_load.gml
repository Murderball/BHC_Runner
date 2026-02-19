function scr_phrases_load()
{
    // SAFETY: phrases_file must exist
    if (!variable_global_exists("phrases_file")) {
        show_debug_message("[scr_phrases_load] global.phrases_file not set; skipping load.");
        return;
    }
    if (is_undefined(global.phrases_file) || global.phrases_file == "") {
        show_debug_message("[scr_phrases_load] global.phrases_file empty; skipping load.");
        return;
    }

    if (!file_exists(global.phrases_file)) {
        show_debug_message("[scr_phrases_load] Missing file: " + string(global.phrases_file));
        return;
    }

    // ... keep the rest of your existing loader code below ...

    // Normalize
    for (var i = 0; i < array_length(global.phrases); i++) {
        var p = global.phrases[i];
        if (!is_struct(p)) {
            global.phrases[i] = { kind:"phrase", t:0.0, steps:[] };
        } else {
            if (!variable_struct_exists(p,"kind")) p.kind = "phrase";
            if (!variable_struct_exists(p,"t")) p.t = 0.0;
            if (!variable_struct_exists(p,"steps") || !is_array(p.steps)) p.steps = [];
        }
    }

    scr_phrases_sort();
}

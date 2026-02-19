function scr_editor_selection_remove(index) {
    var out = [];
    for (var i = 0; i < array_length(global.sel); i++) {
        if (global.sel[i] != index) array_push(out, global.sel[i]);
    }
    global.sel = out;
}

function scr_editor_selection_has(index) {
    for (var i = 0; i < array_length(global.sel); i++) {
        if (global.sel[i] == index) return true;
    }
    return false;
}

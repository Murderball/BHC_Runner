function scr_editor_selection_add(index) {
    if (index < 0) return;
    if (scr_editor_selection_has(index)) return;
    array_push(global.sel, index);
}

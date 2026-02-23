/// @function scr_note_sprite(_action_key_or_id)
/// @param _action_key_or_id Action key string/id
/// @returns Sprite asset index or -1 when none is available.
function scr_note_sprite(_action_key_or_id)
{
    static note_map = {
        jump:      { new_name: "spr_jump_note" },
        duck:      { new_name: "spr_duck_note"},
        atk1:      { new_name: "spr_attack_1_note"},
        atk2:      { new_name: "spr_attack_2_note"},
        atk3:      { new_name: "spr_attack_3_note"},
        ult:       { new_name: "spr_ultimate_note"},
        ultimate:  { new_name: "spr_ultimate_note"}
    };

    if (!variable_global_exists("NOTE_SPR")) {
        global.NOTE_SPR = note_map;
    }

    var key = string_lower(string(_action_key_or_id));
    if (variable_global_exists("ACT_JUMP") && _action_key_or_id == global.ACT_JUMP) key = "jump";
    if (variable_global_exists("ACT_DUCK") && _action_key_or_id == global.ACT_DUCK) key = "duck";
    if (variable_global_exists("ACT_ATK1") && _action_key_or_id == global.ACT_ATK1) key = "atk1";
    if (variable_global_exists("ACT_ATK2") && _action_key_or_id == global.ACT_ATK2) key = "atk2";
    if (variable_global_exists("ACT_ATK3") && _action_key_or_id == global.ACT_ATK3) key = "atk3";
    if (variable_global_exists("ACT_ULT")  && _action_key_or_id == global.ACT_ULT)  key = "ult";

    if (key == "attk2" || key == "attack2") key = "atk2";
    if (key == "attack1") key = "atk1";
    if (key == "attack3") key = "atk3";

    if (!variable_struct_exists(note_map, key)) key = "atk1";

    var row = variable_struct_get(note_map, key);
    var spr_new = scr_asset_get_index_safe(row.new_name, -1);
    if (spr_new != -1 && asset_get_type(spr_new) == asset_sprite) return spr_new;

    var spr_old = scr_asset_get_index_safe(row.old_name, -1);
    if (spr_old != -1 && asset_get_type(spr_old) == asset_sprite) return spr_old;

    return -1;
}

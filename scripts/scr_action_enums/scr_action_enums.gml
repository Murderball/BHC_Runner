/// scr_action_enums.gml
/// Discovery notes:
/// - Player gameplay objects: obj_player_guitar / obj_player_vocals / obj_player_bass / obj_player_drums.
/// - Existing action input path: scr_input_update + scr_note_trigger_inputs_update => global.in_* flags.
/// - Existing projectile + ultimate adapters found in player Step blocks and scr_player_ultimate_guitar.
/// - Existing jump/duck runtime vars: grounded, duck_timer. Timing uses game_get_speed(gamespeed_fps).

enum ACT {
    ATK1,
    ATK2,
    ATK3,
    JUMP,
    DUCK,
    ULT,
    COUNT
}

enum CHAR {
    GUITAR,
    VOCAL,
    BASS,
    DRUM,
    COUNT
}

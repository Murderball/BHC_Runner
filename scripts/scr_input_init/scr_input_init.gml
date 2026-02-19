function scr_input_init()
{
    // Default pad index
    global.pad = 0;
    global.use_gamepad = gamepad_is_connected(global.pad);

    // One-frame gameplay presses
    global.in_jump  = false;
    global.in_duck  = false;
    global.in_atk1  = false;
    global.in_atk2  = false;
    global.in_atk3  = false;

    // Ultimate is NOTE-ONLY (manual input is tracked separately)
    global.in_ult        = false; // set by notes only
    global.in_ult_manual = false; // for UI/debug (NOT used for gameplay)

    // Holds (useful for duck)
    global.hold_duck = false;

    // UI / menus
    global.in_pause   = false;
    global.in_confirm = false;
    global.in_cancel  = false;
}

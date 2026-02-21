function scr_input_update()
{
    // Choose pad index (default 0)
    var pad = 0;
    if (variable_global_exists("pad")) pad = global.pad;

    global.use_gamepad = gamepad_is_connected(pad);

    // ----------------------------
    // Reset one-frame inputs
    // ----------------------------
    global.in_jump       = false;
    global.in_duck       = false;
    global.in_atk1       = false;
    global.in_atk2       = false;
    global.in_atk3       = false;

    global.in_ult        = false; // NOTE-ONLY (set elsewhere)
    global.in_ult_manual = false; // debug/UI only

    global.in_pause      = false;
    global.in_confirm    = false;
    global.in_cancel     = false;

    // Holds
    global.hold_duck     = false;

    // ----------------------------
    // Read inputs (mapped to Control Schemes.txt)
    // ----------------------------
    if (global.use_gamepad)
    {
        // PS5 Controller Default
        // Jump     = X        (gp_face1)
        // Attack 1 = Square   (gp_face3)
        // Attack 2 = Circle   (gp_face2)
        // Attack 3 = Triangle (gp_face4)
        // Duck     = R2       (gp_triggerright)
        // Pause    = Start    (gp_start)

        global.in_jump = gamepad_button_check_pressed(pad, gp_face1);

        global.in_atk1 = gamepad_button_check_pressed(pad, gp_face3);
        global.in_atk2 = gamepad_button_check_pressed(pad, gp_face2);
        global.in_atk3 = gamepad_button_check_pressed(pad, gp_face4);

        global.in_duck   = gamepad_button_check_pressed(pad, gp_triggerright);
        global.hold_duck = gamepad_button_check(pad, gp_triggerright);

        // Ultimate (L2+R2) - MANUAL press (edge-triggered)
        // Fire when the second trigger is pressed while the other is held.
        global.in_ult_manual =
            (gamepad_button_check_pressed(pad, gp_triggerleft)  && gamepad_button_check(pad, gp_triggerright)) ||
            (gamepad_button_check_pressed(pad, gp_triggerright) && gamepad_button_check(pad, gp_triggerleft));


        // Pause
        global.in_pause = gamepad_button_check_pressed(pad, gp_start);

        // Confirm / Cancel
        global.in_confirm = gamepad_button_check_pressed(pad, gp_face1); // X
        global.in_cancel  = gamepad_button_check_pressed(pad, gp_face2); // Circle
    }
    else
    {
        // Keyboard Default
        // Jump     = Space
        // Attack 1 = 1
        // Attack 2 = 2
        // Attack 3 = 3
        // Ultimate = 4 (NOTE-ONLY; tracked as manual)
        // Duck     = Shift
        // Pause    = ESC / P

        global.in_jump = keyboard_check_pressed(vk_space);

        global.in_atk1 = keyboard_check_pressed(ord("1"));
        global.in_atk2 = keyboard_check_pressed(ord("2"));
        global.in_atk3 = keyboard_check_pressed(ord("3"));

        global.in_duck   = keyboard_check_pressed(vk_shift);
        global.hold_duck = keyboard_check(vk_shift);

        global.in_ult_manual = keyboard_check_pressed(ord("4"));

        // Pause
        global.in_pause = keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("P"));

        // Confirm / Cancel
        global.in_confirm = keyboard_check_pressed(vk_enter);
        global.in_cancel  = keyboard_check_pressed(vk_escape);

        // Optional: allow SPACE as confirm ONLY while story-paused
        if (variable_global_exists("STORY_PAUSED") && global.STORY_PAUSED) {
            if (keyboard_check_pressed(vk_space)) global.in_confirm = true;
        }
    }
 // Allow manual ultimate to drive the real gameplay flag too.
    // Note-trigger system can still set global.in_ult later in the frame.
    global.in_ult = global.in_ult || global.in_ult_manual;

    // ----------------------------
    // If story is paused: block gameplay actions, keep pause/confirm/cancel
    // ----------------------------
    if (variable_global_exists("STORY_PAUSED") && global.STORY_PAUSED)
    {
        global.in_jump = false;
        global.in_duck = false;
        global.in_atk1 = false;
        global.in_atk2 = false;
        global.in_atk3 = false;
        global.hold_duck = false;

        // NOTE: do NOT clear global.in_pause/global.in_confirm/global.in_cancel
    }
}

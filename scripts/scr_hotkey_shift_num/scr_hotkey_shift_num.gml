/// @function scr_hotkey_shift_num(_n)
/// @description Returns true when SHIFT is held and number-row key (_n 1..9) is pressed this step.
/// @param _n Number key to test (1..9)
function scr_hotkey_shift_num(_n)
{
    if (!is_real(_n)) return false;

    var key_num = floor(_n);
    if (key_num < 1 || key_num > 9) return false;

    var shift_down = keyboard_check(vk_shift)
        || keyboard_check(vk_lshift)
        || keyboard_check(vk_rshift);

    if (!shift_down) return false;

    var key_code = ord(string(key_num));
    return keyboard_check_pressed(key_code);
}

/// scr_bg_set_by_difficulty()
/// Sets up animated BG sequence using numbered sprite assets:
/// spr_bg_easy_00..44, spr_bg_normal_00..44, spr_bg_hard_00..44

function scr_bg_set_by_difficulty()
{
    // Must be called from within bg_manager instance (so we can set its vars)
    var d = (variable_global_exists("DIFFICULTY")) ? string_lower(string(global.DIFFICULTY)) : "normal";
    if (d != "easy" && d != "normal" && d != "hard") d = "normal";

    // Store current sequence prefix on the bg_manager instance
    bg_seq_prefix = "spr_bg_" + d + "_";

    // Figure out how many frames exist by scanning until we miss
    // (fast enough at create / difficulty swap)
    var count = 0;
    for (var i = 0; i < 999; i++)
    {
        var name = bg_seq_prefix + string_format(i, 2, 0); // 00,01,02...
        var spr = asset_get_index(name);
        if (spr == -1) break;
        count++;
    }

    bg_seq_count = count;

    // Fallback: if nothing found, don't crash
    if (bg_seq_count <= 0)
    {
        sprite_index = -1;
        image_index = 0;
        exit;
    }

    // Ensure current frame is valid
    if (!variable_instance_exists(id, "bg_seq_frame")) bg_seq_frame = 0;
    bg_seq_frame = clamp(bg_seq_frame, 0, bg_seq_count - 1);

    // Apply the sprite for the current frame immediately
    var first_name = bg_seq_prefix + string_format(bg_seq_frame, 2, 0);
    sprite_index = asset_get_index(first_name);

    // We are controlling the animation ourselves
    image_speed = 0;
}
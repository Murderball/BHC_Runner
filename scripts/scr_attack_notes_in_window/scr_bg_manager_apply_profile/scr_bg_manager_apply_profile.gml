/// scr_bg_manager_apply_profile(inst)
/// Rebuilds bg_map + resets state using instance variables:
///   bg_profile, parallax, fade_s, target_depth

function scr_bg_manager_apply_profile(_inst)
{
    if (!instance_exists(_inst)) return;

    with (_inst)
    {
        // Ensure master sections exist (safe to call multiple times)
        scr_level3_master_sections_init();
        scr_chunk_build_section_sequences();

        sections = global.level3_master_sections;

        // Defaults (only if not set on the instance)
        if (is_undefined(bg_profile)) bg_profile = "near";
        if (!is_real(parallax)) parallax = 1.0;
        if (!is_real(fade_s)) fade_s = 0.15;

        // Optional: set depth from instance var
        if (is_real(target_depth)) depth = target_depth;

        // Rebuild bg_map safely
        if (!is_undefined(bg_map) && ds_exists(bg_map, ds_type_map)) ds_map_destroy(bg_map);
        bg_map = scr_bg_map_build(bg_profile);

        // Reset transition state
        cur_i = 0;
        prev_i = -1;
        fade  = 1.0;
    }
}
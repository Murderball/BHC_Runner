/// scr_tileset_prewarm_textures()
/// Forces tileset textures to upload to GPU before gameplay starts.
/// Version-safe: does NOT use tileset_get_sprite().
function scr_tileset_prewarm_textures()
{
    // Create a tiny surface to force texture upload
    var surf = surface_create(32, 32);
    if (!surface_exists(surf)) return;

    surface_set_target(surf);
    draw_clear_alpha(c_black, 0);

    // ------------------------------------------------------------
    // OPTION A (recommended): You explicitly list the tileset sprites
    // ------------------------------------------------------------
    // Put the sprites that your tilesets are built from here.
    // If you only have 1 tileset sprite, just include it once.
    var spr_list = [];

    // If you have globals with these sprite indices already, push them here.
    // Example:
    // array_push(spr_list, spr_tileset_easy);
    // array_push(spr_list, spr_tileset_normal);
    // array_push(spr_list, spr_tileset_hard);

    // ------------------------------------------------------------
    // OPTION B: If you only have ONE tileset sprite in your project,
    // put it directly here and delete the rest.
    // ------------------------------------------------------------
    // array_push(spr_list, spr_tileset_main);

    // ------------------------------------------------------------
    // OPTION C (fallback): try to prewarm by known sprite name strings
    // (only works if you know the sprite asset names)
    // ------------------------------------------------------------
    // array_push(spr_list, asset_get_index("spr_tileset_easy"));
    // array_push(spr_list, asset_get_index("spr_tileset_normal"));
    // array_push(spr_list, asset_get_index("spr_tileset_hard"));

    // --- SAFETY: if you forgot to fill spr_list, do nothing cleanly
    if (array_length(spr_list) > 0)
    {
        for (var i = 0; i < array_length(spr_list); i++)
        {
            var spr = spr_list[i];
            if (spr != -1 && sprite_exists(spr))
            {
                draw_sprite(spr, 0, 0, 0);
            }
        }
    }

    surface_reset_target();
    surface_free(surf);
}

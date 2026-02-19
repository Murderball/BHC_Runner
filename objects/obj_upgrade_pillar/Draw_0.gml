/// obj_upgrade_pillar : Draw

// Draw normal sprite
draw_self();

// ----------------------------------------------------
// EDGE GLOW (ON HOVER)
// ----------------------------------------------------
if (glow_alpha > 0.01)
{
    gpu_set_blendmode(bm_add);
    draw_set_alpha(0.15 * glow_alpha);
    draw_set_color(c_purple); // change if you want

    var off = 1; // glow thickness

    // Draw sprite offset in 8 directions for outline glow
    for (var xx = -1; xx <= 1; xx++)
    for (var yy = -1; yy <= 1; yy++)
    {
        if (xx == 0 && yy == 0) continue;
        draw_sprite(sprite_index, image_index, x + xx * off, y + yy * off);
    }
	var pulse = 1 + sin(current_time * 0.008) * 0.08;
	draw_sprite_ext(
	    sprite_index, image_index,
	    x, y,
	    pulse, pulse,
	    0,
	    c_purple,
	    0.25 * glow_alpha
	);

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}

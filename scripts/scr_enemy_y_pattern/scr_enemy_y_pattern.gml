/// scr_enemy_y_pattern(mode, i, t_s, seed)
/// Returns a y_gui value. lane-free.
/// mode: "random" | "alt" | "sine" | "stairs" | "centerburst"
function scr_enemy_y_pattern(mode, i, t_s, seed)
{
    var h   = display_get_gui_height();
    var top = 140;
    var bot = h - 140;

    // fract helper (avoids any confusion if 'frac' isn't available / behaves oddly)
    function _fract(v) { return v - floor(v); }

    // deterministic-ish noise in 0..1
    var n = _fract(sin((i + seed) * 12.9898) * 43758.5453);

    if (mode == "random") {
        return lerp(top, bot, n);
    }

    if (mode == "alt") {
        var high = top + 80;
        var low  = bot - 80;
        return (i & 1) ? low : high;
    }

    if (mode == "sine") {
        var mid = (top + bot) * 0.5;
        var amp = (bot - top) * 0.35;
        return mid + sin((t_s * 2.0) + i * 0.7) * amp;
    }

    if (mode == "stairs") {
        var steps = 5;
        var k = i mod steps;
        return lerp(top, bot, k / (steps - 1));
    }

    if (mode == "centerburst") {
        var mid    = (top + bot) * 0.5;
        var spread = (bot - top) * 0.15;

        // Use 'yy' (NOT 'y') to avoid built-in variable collisions
        var yy = mid + (n - 0.5) * 2.0 * spread;

        // occasional outlier
        if (n > 0.85) yy = lerp(top, bot, _fract(n * 7.3));

        return clamp(yy, top, bot);
    }

    // default
    return (top + bot) * 0.5;
}

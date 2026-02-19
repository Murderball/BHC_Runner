/// @function scr_enemy_kind_normalize(kind)
/// @param kind any
/// @returns normalized kind string used for lookups
function scr_enemy_kind_normalize(kind)
{
    var k = string_lower(string(kind));
    k = string_replace_all(k, " ", "_");
    k = string_replace_all(k, "-", "_");


    // allow user to pass sprite name directly
    if (string_copy(k, 1, 4) == "spr_")
        k = string_delete(k, 1, 4); // strip "spr_"

    return k;
}


/// @function scr_enemy_kinds_list()
/// @returns array of enemy kinds (strings)
function scr_enemy_kinds_list()
{
    // This is the current contents of your Sprites/Enemy folder (singular "Enemy")
    static kinds = [
        "boss",
        "desyncr",
        "drone",
        "heckler",
        "lavaguy",
        "micguy",
        "poptart",
        "popunktart",
        "shadowguy",
        "snakeguy",
        "snareguy",
    ];

    return kinds;
}


/// @function scr_enemy_kind_next(cur_kind, dir)
/// @param cur_kind any
/// @param dir real (usually 1 or -1)
/// @returns next kind string (wraps)
function scr_enemy_kind_next(cur_kind, dir)
{
    var kinds = scr_enemy_kinds_list();
    var n = array_length(kinds);
    if (n <= 0) return "poptart";

    var k = scr_enemy_kind_normalize(cur_kind);

    var idx = -1;
    for (var i = 0; i < n; i++)
    {
        if (kinds[i] == k) { idx = i; break; }
    }

    if (idx < 0) return kinds[0];

    if (!is_real(dir)) dir = 1;
    dir = (dir >= 0) ? 1 : -1;

    idx = (idx + dir) mod n;
    if (idx < 0) idx += n;

    return kinds[idx];
}


/// @function scr_enemy_sprite_from_kind(kind)
/// @param kind string
/// @returns sprite index or -1
function scr_enemy_sprite_from_kind(kind)
{
    var k = scr_enemy_kind_normalize(kind);

    // "random" picks from the list
    if (k == "random")
    {
        var kinds = scr_enemy_kinds_list();
        if (array_length(kinds) > 0)
            k = kinds[irandom(array_length(kinds) - 1)];
    }

    // primary lookup: spr_<kind>
    var s = asset_get_index("spr_" + k);
    if (s != -1) return s;

    // fallback: if someone passed "spr_<kind>" already, normalize stripped it,
    // so this is mostly just extra safety:
    s = asset_get_index(string(kind));
    if (s != -1) return s;

    return -1;
}

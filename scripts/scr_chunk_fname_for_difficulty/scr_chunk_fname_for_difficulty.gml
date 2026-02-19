/// scr_chunk_fname_for_difficulty(base_fname)
/// If "chunk_x.json" has a matching "chunk_x__easy.json" (or normal/hard), use it.
function scr_chunk_fname_for_difficulty(_base)
{
    var base = string(_base);
    if (base == "") return base;

    if (!variable_global_exists("DIFFICULTY")) return base;

    var d = global.DIFFICULTY;
    if (d != "easy" && d != "normal" && d != "hard") return base;

    // Insert suffix before .json
    var suff = string_replace(base, ".json", "__" + d + ".json");

    // Check sandbox first, then datafiles fallback (like your loaders do)
    if (file_exists(suff)) return suff;
    if (file_exists("datafiles/" + suff)) return suff;

    return base;
}
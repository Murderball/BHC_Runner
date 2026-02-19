/// scr_pickup_kind_next(curr_kind, dir)
/// Cycles pickup kinds: chart -> eyes -> shard
function scr_pickup_kind_next(curr_kind, dir)
{
    var kinds = ["chart", "eyes", "shard"];

    var k = string_lower(string(curr_kind));
    var idx = 0;
    for (var i = 0; i < array_length(kinds); i++)
    {
        if (k == kinds[i]) { idx = i; break; }
    }

    var d = (is_real(dir) ? dir : 1);
    if (d >= 0) idx++; else idx--;

    if (idx < 0) idx = array_length(kinds) - 1;
    if (idx >= array_length(kinds)) idx = 0;

    return kinds[idx];
}

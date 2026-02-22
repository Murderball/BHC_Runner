function scr_story_room_id(_target)
{
    if (is_real(_target))
    {
        var rid = floor(_target);
        if (room_exists(rid)) return rid;
        return -1;
    }

    if (is_string(_target))
    {
        var idx = asset_get_index(_target);
        if (asset_get_type(idx) == asset_room) return idx;
        return -1;
    }

    return -1;
}

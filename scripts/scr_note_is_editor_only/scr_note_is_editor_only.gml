function scr_note_is_editor_only(kind)
{
    var k = string_lower(string(kind));
    return (k == "jump" || k == "duck");
}

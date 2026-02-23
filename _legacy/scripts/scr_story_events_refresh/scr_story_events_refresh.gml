/// scr_story_events_refresh()
function scr_story_events_refresh()
{
    // Only rebuild story events from PAUSE markers
    if (script_exists(scr_story_events_from_markers)) scr_story_events_from_markers();
}

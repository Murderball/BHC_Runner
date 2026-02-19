function scr_level3_master_sections_init()
{
    // Legacy wrapper. Keep so any stray references don't crash.
    global.LEVEL_KEY = "level03";
    scr_level_master_sections_init("level03");
    global.level3_master_sections = global.master_sections;
}

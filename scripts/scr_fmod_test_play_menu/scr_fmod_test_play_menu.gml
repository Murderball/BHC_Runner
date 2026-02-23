/// scr_fmod_test_play_menu()
function scr_fmod_test_play_menu()
{
    var path = "event:/Menu_Sounds/Start_Menu";
    show_debug_message("[FMOD] TEST PLAY -> " + path);

    // Replace these lines with YOUR extension’s play calls
    // Example patterns (your names will differ):
    // var ev = fmod_studio_system_get_event(global.fmod_system, path);
    // var inst = fmod_studio_event_create_instance(ev);
    // fmod_studio_event_instance_start(inst);
    // global.__fmod_test_inst = inst;

    show_debug_message("[FMOD] TEST PLAY done (check for errors above)");
}
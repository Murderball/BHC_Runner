function scr_fmod_event_path_build(_bank_name, _event_name)
{
    var bank_name = string(_bank_name);
    var event_name = string(_event_name);
    if (bank_name == "" || event_name == "") return "";
    return "event:/" + bank_name + "/" + event_name;
}

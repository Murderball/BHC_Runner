function scr_story_choice_begin(evp)
{
    global.story_choice_active = true;

    global.story_choice_caption = "";
    if (variable_struct_exists(evp, "caption")) global.story_choice_caption = string(evp.caption);

    global.story_choice_options = [];
    if (variable_struct_exists(evp, "choices") && is_array(evp.choices)) {
        global.story_choice_options = evp.choices;
    }

    global.story_choice_sel = 0;
}

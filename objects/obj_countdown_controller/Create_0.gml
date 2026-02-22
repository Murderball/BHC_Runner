/// obj_countdown_controller : Create
persistent = true;
if (!variable_global_exists("COUNTDOWN_ACTIVE")) global.COUNTDOWN_ACTIVE = false;
if (!variable_global_exists("COUNTDOWN_TIMER_S")) global.COUNTDOWN_TIMER_S = 0;
if (!variable_global_exists("COUNTDOWN_TOTAL_S")) global.COUNTDOWN_TOTAL_S = 0;
if (!variable_global_exists("COUNTDOWN_REASON")) global.COUNTDOWN_REASON = "";

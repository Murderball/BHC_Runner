/// obj_countdown_controller : Step
if (!global.COUNTDOWN_ACTIVE) exit;

var dt = delta_time * 0.000001;
global.COUNTDOWN_TIMER_S = max(0, global.COUNTDOWN_TIMER_S - dt);

if (global.COUNTDOWN_TIMER_S <= 0)
{
    global.COUNTDOWN_ACTIVE = false;
    global.COUNTDOWN_REASON = "";
}

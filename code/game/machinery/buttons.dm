/obj/machinery/button
	name = "button"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for something."
	var/id = null
	var/active = 0
	var/operating = 0
	anchored = 1.0
	idle_power_usage = 2
	active_power_usage = 4
	var/_wifi_id
	var/datum/wifi/sender/wifi_sender

/obj/machinery/button/Initialize()
	. = ..()
	update_icon()
	if(_wifi_id && !wifi_sender)
		wifi_sender = new/datum/wifi/sender/button(_wifi_id, src)

/obj/machinery/button/Destroy()
	qdel(wifi_sender)
	wifi_sender = null
	return ..()

/obj/machinery/button/attack_ai(mob/user as mob)
	if(!ai_can_interact(user))
		return
	return attack_hand(user)

/obj/machinery/button/attackby(obj/item/W, mob/user as mob)
	return attack_hand(user)

/obj/machinery/button/attack_hand(mob/living/user)
	if(..()) return 1
	user.visible_message("<b>[user]</b> hits \the [src] button.")
	activate(user)
	intent_message(BUTTON_FLICK, 5)

/obj/machinery/button/proc/activate(mob/living/user)
	if(operating || !istype(wifi_sender))
		return

	operating = 1
	active = 1
	use_power_oneoff(5)
	update_icon()
	wifi_sender.activate(user)
	sleep(10)
	active = 0
	update_icon()
	operating = 0

/obj/machinery/button/update_icon()
	if(active)
		icon_state = "launcheract"
	else
		icon_state = "launcherbtt"

//alternate button with the same functionality, except has a lightswitch sprite instead
/obj/machinery/button/switch
	icon = 'icons/obj/power.dmi'
	icon_state = "light0"

/obj/machinery/button/switch/update_icon()
	icon_state = "light[active]"

/obj/machinery/button/switch/attack_hand()
	playsound(src, /singleton/sound_category/switch_sound, 30)
	intent_message(BUTTON_FLICK, 5)

//alternate button with the same functionality, except has a door control sprite instead
/obj/machinery/button/alternate
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"

/obj/machinery/button/alternate/update_icon()
	if(active)
		icon_state = "doorctrl0"
	else
		icon_state = "doorctrl2"

//Toggle button with two states (on and off) and calls seperate procs for each state
/obj/machinery/button/toggle/activate(mob/living/user)
	if(operating || !istype(wifi_sender))
		return

	operating = 1
	active = !active
	use_power_oneoff(5)
	if(active)
		wifi_sender.activate(user)
	else
		wifi_sender.deactivate(user)
	update_icon()
	operating = 0

//alternate button with the same toggle functionality, except has a lightswitch sprite instead
/obj/machinery/button/toggle/switch
	icon = 'icons/obj/power.dmi'
	icon_state = "light0"

/obj/machinery/button/toggle/switch/update_icon()
	icon_state = "light[active]"

//alternate button with the same toggle functionality, except has a door control sprite instead
/obj/machinery/button/toggle/alternate
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"

/obj/machinery/button/toggle/alternate/update_icon()
	if(active)
		icon_state = "doorctrl0"
	else
		icon_state = "doorctrl2"

//-------------------------------
// Mass Driver Button
//  Passes the activate call to a mass driver wifi sender
//-------------------------------
/obj/machinery/button/mass_driver
	name = "mass driver button"

/obj/machinery/button/mass_driver/Initialize()
	. = ..()
	if(_wifi_id)
		wifi_sender = new/datum/wifi/sender/mass_driver(_wifi_id, src)

/obj/machinery/button/mass_driver/activate(mob/living/user)
	if(active || !istype(wifi_sender))
		return

	active = 1
	if(use_power)
		use_power_oneoff(active_power_usage)
	update_icon()
	wifi_sender.activate()
	active = 0
	update_icon()


//-------------------------------
// Door Button
//-------------------------------

// Bitmasks for door switches.
#define OPEN   0x1
#define IDSCAN 0x2
#define BOLTS  0x4
#define SHOCK  0x8
#define SAFE   0x10

/obj/machinery/button/toggle/door
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"

	var/_door_functions = 1
/*	Bitflag, 	1 = open
				2 = idscan
				4 = bolts
				8 = shock
				16 = door safties  */

/obj/machinery/button/toggle/door/update_icon()
	if(active)
		icon_state = "doorctrl0"
	else
		icon_state = "doorctrl2"

/obj/machinery/button/toggle/door/Initialize()
	if(_wifi_id)
		wifi_sender = new/datum/wifi/sender/door(_wifi_id, src)
	. = ..()

/obj/machinery/button/toggle/door/activate(mob/living/user)
	if(operating || !istype(wifi_sender))
		return

	operating = 1
	active = !active
	use_power_oneoff(5)
	update_icon()
	if(active)
		if(_door_functions & IDSCAN)
			wifi_sender.activate("enable_idscan")
		if(_door_functions & SHOCK)
			wifi_sender.activate("electrify")
		if(_door_functions & SAFE)
			wifi_sender.activate("enable_safeties")
		if(_door_functions & BOLTS)
			wifi_sender.activate("unlock")
		if(_door_functions & OPEN)
			wifi_sender.activate("open")
	else
		if(_door_functions & IDSCAN)
			wifi_sender.activate("disable_idscan")
		if(_door_functions & SHOCK)
			wifi_sender.activate("unelectrify")
		if(_door_functions & SAFE)
			wifi_sender.activate("disable_safeties")
		if(_door_functions & OPEN)
			wifi_sender.activate("close")
		if(_door_functions & BOLTS)
			wifi_sender.activate("lock")
	operating = 0

#undef OPEN
#undef IDSCAN
#undef BOLTS
#undef SHOCK
#undef SAFE

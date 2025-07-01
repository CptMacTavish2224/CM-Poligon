/// @function scr_hit
/// @description Returns true if mouse is hovering on the specified rectangle area.
/// @returns {bool}
function scr_hit(x1=0, y1=0, x2=0, y2=0) {
	var mouse_consts = return_mouse_consts();
	if (is_array(x1)){
		return point_in_rectangle(mouse_consts[0],mouse_consts[1],x1[0],x1[1],x1[2],x1[3]);
	} else {
		return point_in_rectangle(mouse_consts[0],mouse_consts[1],x1, y1, x2, y2);
	}
	return false;

}

function scr_hit_relative(x1, relative = [0,0]){
	var mouse_consts = return_mouse_consts();
	return point_in_rectangle(mouse_consts[0],mouse_consts[1],relative[0] + x1[0],relative[1] + x1[1],relative[0] + x1[2],relative[1] + x1[3]);
}

/// @function point_and_click
/// @description Returns true if left mouse button was clicked on the desired rectangle area.
/// @param {array} rect x1, y1, x2, y2 array.
/// @returns {bool}
function point_and_click(rect, cooldown = 60, lock_bypass = false) {
	if (lock_bypass == false && global.ui_click_lock == true) {
		return false;
	}

	var _mouse_clicked = event_number==ev_gui ? device_mouse_check_button_pressed(0,mb_left) : mouse_check_button_pressed(mb_left);
	if (!_mouse_clicked) {
		return false;
	}

	var _point_check = scr_hit(rect[0], rect[1],rect[2], rect[3]);
	if (!_point_check) {
		return false;
	}

	var controller_exist = instance_exists(obj_controller);
	var main_menu_exists = instance_exists(obj_main_menu);
	var creation_screen_exists = instance_exists(obj_creation);
	if (controller_exist && obj_controller.cooldown > 0) {
		log_warning("Ignored click for cooldown, {obj_controller.cooldown} steps remaining!");
		log_warning($"Click callstack: \n{array_to_string_list(debug_get_callstack(), true)}");
		return false;
	} else if (main_menu_exists) {
		if (main_menu_exists) {
			if (obj_main_menu.cooldown > 0) {
				log_warning($"Ignored click for cooldown, {obj_main_menu.cooldown} steps remaining!");
				log_warning($"Click callstack: \n{array_to_string_list(debug_get_callstack(), true)}");
				return false;
			}
		} else if (creation_screen_exists) {
			if (obj_creation.cooldown > 0) {
				log_warning($"Ignored click for cooldown, {obj_creation.cooldown} steps remaining!");
				log_warning($"Click callstack: \n{array_to_string_list(debug_get_callstack(), true)}");
				return false;
			}
		}
	}

	var mouse_consts = return_mouse_consts();
	var point_check = point_in_rectangle(mouse_consts[0], mouse_consts[1], rect[0], rect[1],rect[2], rect[3]);
	if (point_check && cooldown > 0) {
		if (controller_exist) {
			obj_controller.cooldown = cooldown * delta_time/1000000;
			if(is_debug_overlay_open()){
				show_debug_message($"Cooldown Set! {array_to_string_list(debug_get_callstack(), true)}");
			}
		}  if (main_menu_exists) {
			obj_main_menu.cooldown = cooldown * delta_time/1000000;
			if(is_debug_overlay_open()){
				show_debug_message($"Cooldown Set! {array_to_string_list(debug_get_callstack(), true)}");
			}
		} else if (creation_screen_exists) {
			obj_creation.cooldown = cooldown * delta_time/1000000;
			if(is_debug_overlay_open()){
				show_debug_message($"Cooldown Set! {array_to_string_list(debug_get_callstack(), true)}");
			}
		}
		// log_message("scr_click_left: clicked and set cooldown!");
		// show_debug_message($"{array_to_string_list(debug_get_callstack())}");
	}

	if(is_debug_overlay_open()){
		show_debug_message($"Mouse Clicked at: x: {mouse_consts[0]} y: {mouse_consts[1]} {array_to_string_list(debug_get_callstack(), true)}!");
	}

	return true;
}

function point_and_click_sprite(x1, y1, sprite, x_scale = 1, y_scale = 1){
	var _width = sprite_get_width(sprite) * x_scale;
	var _height = sprite_get_height(sprite) * y_scale;
	return point_and_click([x1, y1, x1 +_width, y1 + _height]);
}

function scr_click_left(cooldown = 60, lock_bypass = false){
	if (lock_bypass == false && global.ui_click_lock == true) {
		return false;
	}

	var mouse_clicked = event_number==ev_gui ? device_mouse_check_button_pressed(0,mb_left) : mouse_check_button_pressed(mb_left);
	if (!mouse_clicked) {
		return false;
	}

	var controller_exist = instance_exists(obj_controller);
	if (controller_exist && obj_controller.cooldown > 0) {
		log_warning($"Ignored click for cooldown, {obj_controller.cooldown} steps remaining!");
		log_warning($"Click callstack: \n{array_to_string_list(debug_get_callstack(), true)}");
		return false;
	} else if (controller_exist && cooldown > 0) {
		// log_message("scr_click_left: clicked and set cooldown!");
		// show_debug_message($"{array_to_string_list(debug_get_callstack())}");
		obj_controller.cooldown = cooldown * delta_time/1000000;
		if(is_debug_overlay_open()){
			show_debug_message($"Cooldown Set! {array_to_string_list(debug_get_callstack(), true)}");
		}
	} else if (!controller_exist) {
		var main_menu_exists = instance_exists(obj_main_menu);
		var creation_screen_exists = instance_exists(obj_creation);
		if (main_menu_exists) {
			if (obj_main_menu.cooldown > 0) {
				log_warning($"Ignored click for cooldown, {obj_main_menu.cooldown} steps remaining!");
				log_warning($"Click callstack: \n{array_to_string_list(debug_get_callstack(), true)}");
				return false;
			} else if (cooldown > 0) {
				obj_main_menu.cooldown = cooldown * delta_time/1000000;
				if(is_debug_overlay_open()){
					show_debug_message($"Cooldown Set! {array_to_string_list(debug_get_callstack(), true)}");
				}
			}
		} else if (creation_screen_exists) {
			if (obj_creation.cooldown > 0) {
				log_warning($"Ignored click for cooldown, {obj_creation.cooldown} steps remaining!");
				log_warning($"Click callstack: \n{array_to_string_list(debug_get_callstack(), true)}");
				return false;
			} else if (cooldown > 0) {
				obj_creation.cooldown = cooldown * delta_time/1000000;
				if(is_debug_overlay_open()){
					show_debug_message($"Cooldown Set! {array_to_string_list(debug_get_callstack(), true)}");
				}
			}
		}
	}

	if(is_debug_overlay_open()){
		show_debug_message($"Mouse Clicked! {array_to_string_list(debug_get_callstack(), true)}");
	}

	return mouse_clicked;
}

function mouse_button_held(_button = mb_left) {
	var mouse_held = event_number==ev_gui ? device_mouse_check_button(0,_button) : mouse_check_button(_button);
	if (!mouse_held) {
		return false;
	}

	var controller_exist = instance_exists(obj_controller);
	if (controller_exist && obj_controller.cooldown > 0) {
		log_warning($"Ignored click for cooldown, {obj_controller.cooldown} steps remaining!");
		log_warning($"Click callstack: \n{array_to_string_list(debug_get_callstack(), true)}");
		return false;
	} else if (!controller_exist) {
		var main_menu_exists = instance_exists(obj_main_menu);
		var creation_screen_exists = instance_exists(obj_creation);
		if (main_menu_exists) {
			if (obj_main_menu.cooldown > 0) {
				log_warning($"Ignored click for cooldown, {obj_main_menu.cooldown} steps remaining!");
				log_warning($"Click callstack: \n{array_to_string_list(debug_get_callstack(), true)}");
				return false;
			}
		} else if (creation_screen_exists) {
			if (obj_creation.cooldown > 0) {
				log_warning($"Ignored click for cooldown, {obj_creation.cooldown} steps remaining!");
				log_warning($"Click callstack: \n{array_to_string_list(debug_get_callstack(), true)}");
				return false;
			}
		}
	}

	return mouse_held;
}

function return_mouse_consts(){
	if (event_number==ev_gui){
		var mouse_const_x = device_mouse_x_to_gui(0);
		var mouse_const_y = device_mouse_y_to_gui(0);
	} else {
		mouse_const_x = mouse_x;
		mouse_const_y = mouse_y;
	}
	return [mouse_const_x,mouse_const_y]
}

function mouse_distance_less(xx, yy, distance){
	var mouse_consts = return_mouse_consts();
	return (point_distance(xx,yy,mouse_consts[0],mouse_consts[1])<=distance)
}

function return_mouse_consts_tooltip(){
	var consts = return_mouse_consts();
	return [consts[0], consts[1]]
}

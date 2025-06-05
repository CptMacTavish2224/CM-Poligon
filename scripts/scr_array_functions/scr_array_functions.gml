

function array_iter_length(choice_array, offset, length){
	if (length == 0){
		if (offset==0){
			length = array_length(choice_array);
		}
		else if (offset){
			length = array_length(choice_array) - offset;
		} else {
			length = offset*-1;
		}
	}
	return length;
}
function array_sum(choice_array,start_value=0, offset=0,length=0){
	function arraysum(_prev, _curr, _index) {
	    return _prev + _curr;
	}

	length = array_iter_length(choice_array,offset,length);

	return array_reduce(choice_array,arraysum,start_value,offset,length)
}

function array_join(){
	var new_array = [];
	var add_array;
    for (var i = 0; i < argument_count; i ++)
    {
        add_array = argument[i];
        for (var r=0;r<array_length(add_array);r++){
        	array_push(new_array, add_array[r]);
        }
    }
    return 	new_array;
}

function array_find_value(search_array, value){
	var loc = -1;
	for (var i=0;i<array_length(search_array);i++){
		if (search_array[i] == value){
			loc = i;
			break;
		}
	}
	return loc;
}

function array_set_value(choice_array, value){
	for (var i=0;i<array_length(choice_array);i++){
		choice_array[@ i] = value;
	}
}

function array_replace_value(choice_array, value, r_value){
	for (var i=0;i<array_length(choice_array);i++){
		if (choice_array[i] == value ){
			choice_array[@ i] = r_value;
		}
	}
}

function array_delete_value(choice_array, value){
	// Iterate backwards to avoid index shifting problems
	for (var i = array_length(choice_array) - 1; i >= 0; i--) {
		if (choice_array[i] == value) {
			array_delete(choice_array, i, 1);
		}
	}
}

function array_random_element(choice_array){
	return choice_array[irandom(array_length(choice_array) - 1)];
}

function array_random_index(choice_array){
	return irandom(array_length(choice_array) - 1);
}

/// @function array_to_string_list
/// @description Converts an array into a string, with each element on a newline.
/// @param {array} stacktrace stacktrace.
/// @return {string}
function array_to_string_list(_array, _pop_last = false) {
    var _string_list = "";

    if (!is_array(_array)) {
        return;
    }

    if (_pop_last) {
        array_pop(_array);
    }

    for (var i = 0; i < array_length(_array); i++) {
        _string_list += string(_array[i]);
        if (i < array_length(_array) - 1) {
            _string_list += "\n";
        }
    }

    return _string_list;
}

/// @function array_to_string_order
/// @description Converts an array into a string, with "," after each member and "and" before the last one.
/// @param {array} _strings_array An array of strings.
/// @return {string}
function array_to_string_order(_strings_array, _use_and = false, _dot_end = true) {
    var result = "";
    var length = array_length(_strings_array);

    // Loop through the array
    for (var i = 0; i < length; i++) {
        // Append the current string
        result += _strings_array[i];
        
        // Check if it's the last string
        if (i < length - 1) {
            // If it's the second last item, add " and " before the last one
            if (_use_and && i == length - 2) {
                result += " and ";
            } else {
                result += ", ";
            }
        } else if (_dot_end) {
			result += ".";
		}
    }

    return result;
}

/// @description Converts two parallel arrays into a formatted string with pluralized counts
/// @param {array} _names_array Array of strings representing item names
/// @param {array} _counts_array Array of integers representing counts for each name
/// @param {bool} _exclude_null Whether to exclude entries with zero count
/// @param {bool} _dot_end Whether to end the string with a period
/// @return {string}
function arrays_to_string_with_counts(_names_array, _counts_array, _exclude_null = false, _dot_end = true) {
    var _array_length = array_length(_names_array);
	var _result_string = "";

    for(var i = 0; i < _array_length; i++) {
        if (_exclude_null && _counts_array[i] == 0) {
            continue;
        }
        _result_string += string_plural_count(_names_array[i], _counts_array[i]);
		_result_string += smart_delimeter_sign(_array_length, i, _dot_end);
    }

	return _result_string;
}

/// @description Converts the equipment struct into a formatted string with pluralized counts
/// @param {struct} _equipment The equipment struct
/// @param {bool} _exclude_null Whether to exclude entries with zero total
/// @param {bool} _dot_end Whether to end the string with a period
/// @return {string}
function equipment_struct_to_string(_equipment, _exclude_null = false, _dot_end = true) {
	var _names_array = [];
	var _counts_array = [];

	var _item_keys = variable_struct_get_names(_equipment);
	var _count = 0;

	for (var i = 0; i < array_length(_item_keys); i++) {
		var _item_name = _item_keys[i];
		var _item_data = _equipment[$ _item_name];

		if (!is_struct(_item_data) || !struct_exists(_item_data, "quantity")) {
			continue;
		}

		var _quantities = _item_data.quantity;
		var _quality_keys = variable_struct_get_names(_quantities);
		var _total = 0;

		for (var q = 0; q < array_length(_quality_keys); q++) {
			_total += _quantities[$ _quality_keys[q]];
		}

		if (_exclude_null && _total == 0) {
			continue;
		}

		array_push(_names_array, _item_name);
		array_push(_counts_array, _total);
		_count++;
	}

	if (_count == 0) {
		return "";
	}

	return arrays_to_string_with_counts(_names_array, _counts_array, false, _dot_end);
}

/// @function alter_deep_array
/// @description Modifies a value in a deeply nested array structure.
/// @param {array} array The array to modify
/// @param {array} accessors Array of indices for traversing the nested structure
/// @param {any} value The value to set at the specified location
function alter_deep_array(array, accessors, value){
	var _array_step = array;
	var accessors_length = array_length(accessors);
	for (var i=0;i <accessors_length-1; i++){
		_array_step = _array_step[accessors[i]];
	}
	_array_step[@ accessors[accessors_length-1]] = value;
}

/// @function fetch_deep_array
/// @description Retrieves a value from a deeply nested array structure.
/// @param {array} array The array to retrieve from
/// @param {array} accessors Array of indices for traversing the nested structure
/// @return {any} The value at the specified location
function fetch_deep_array(array, accessors){
	var _array_step = array;
	var accessors_length = array_length(accessors);
	for (var i=0; i <accessors_length; i++){
		_array_step = _array_step[accessors[i]];
	}	
	return _array_step;
}

/// @description Choose either `.` or `,` based on the array length and current loop iteration.
/// @param {array|real} _array_or_length Array or its length.
/// @param {real} _loop_iteration Current loop iteration.
/// @param {bool} _dot_end Whether to end with a period for the last element
/// @return {string}
function smart_delimeter_sign(_array_or_length, _loop_iteration, _dot_end = true) {
    var _delimeter = "";
	var _array_length = is_array(_array_or_length) ? array_length(_array_or_length) : _array_or_length;

    if (_loop_iteration < _array_length - 1) {
        _delimeter += ", ";
    } else if (_dot_end) {
        _delimeter += ".";
    }

    return _delimeter;
}

/// @description Checks whether an array is "simple," meaning it does not exceed a specified depth and contains only simple variables. Recursively evaluates nested arrays.
/// @param {array} _array - The array to check.
/// @param {real} _max_depth - The maximum allowed depth for the array.
/// @param {real} _current_depth (DON'T PASS ANYTHING) The current recursion depth, used internally.
/// @returns {bool}
function is_basic_array(_array, _max_depth = 1, _current_depth = 1) {
    if (_current_depth > _max_depth) {
        return false;
    }

    for (var i = 0, _len = array_length(_array); i < _len; i++) {
        var _var = _array[i];
        if (is_array(_var)) {
            if (!is_basic_array(_var, _max_depth, _current_depth + 1)) {
                return false;
            }
        } else if (!is_basic_variable(_var)) {
            return false;
        }
    }

    return true;
}

/// @description Sets a range of elements in an array to a specific value.
/// @param {Array} _array The array to modify.
/// @param {Real} _start_index The starting index (inclusive).
/// @param {Real} _end_index The ending index (inclusive).
/// @param {Any} _value The value to set for the elements.
function array_set_range(_array, _start_index, _end_index, _value) {
	for (var i = _start_index; i <= _end_index; i++) {
		_array[@ i] = _value;
	}
}

/// @description Similar to array_create, but uses `variable_clone()` to clone the default if it's a complex type (array/struct). Supports default with nesting.
/// @param {Real} _size The size of the array to create.
/// @param {Any} _default The value to set for the elements.
function array_create_advanced(_size = 1, _default = 0) {
	var _array = array_create(_size);

	for (var i = 0; i < _size; i++) {
		_array[@ i] = variable_clone(_default);
	}

	return _array;
}

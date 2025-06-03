// Creates all variables, sets up default variables for different planets and if there is a fleet orbiting a system/planet
craftworld=0;// orbit_angle=0;orbit_radius=0;
space_hulk=0;
old_x=0;
old_y=0;

if (((x>=(room_width-150)) and (y<=450)) or (y<100)) and (global.load==-1){// was 300
    instance_destroy();
}

scale = 1;
var run=0;
name="";
star="";
planets=0;
owner = eFACTION.Imperium;
image_speed=0;
image_alpha=0;
x2=0;
y2=0;
warp_lanes=[];
if (global.load==-1) then alarm[0]=1;
storm=0;
storm_image=0;
trader=0;
visited=0;
stored_owner = -1;
star_surface = 0;

// sets up default planet variables
var _planet_array_size = 9;
planet = array_create(_planet_array_size, 0);
dispo = array_create(_planet_array_size, -50);
p_type = array_create(_planet_array_size, "");
p_owner = array_create(_planet_array_size, 0);
p_first = array_create(_planet_array_size, 0);
p_population = array_create(_planet_array_size, 0);
p_max_population = array_create(_planet_array_size, 0);
p_large = array_create(_planet_array_size, 0);
p_pop = array_create(_planet_array_size, "");
p_guardsmen = array_create(_planet_array_size, 0);
p_pdf = array_create(_planet_array_size, 0);
p_fortified = array_create(_planet_array_size, 0);
p_station = array_create(_planet_array_size, 0);
p_player = array_create(_planet_array_size, 0);
p_lasers = array_create(_planet_array_size, 0);
p_silo = array_create(_planet_array_size, 0);
p_defenses = array_create(_planet_array_size, 0);
p_orks = array_create(_planet_array_size, 0);
p_tau = array_create(_planet_array_size, 0);
p_eldar = array_create(_planet_array_size, 0);
p_tyranids = array_create(_planet_array_size, 0);
p_traitors = array_create(_planet_array_size, 0);
p_chaos = array_create(_planet_array_size, 0);
p_demons = array_create(_planet_array_size, 0);
p_sisters = array_create(_planet_array_size, 0);
p_necrons = array_create(_planet_array_size, 0);
p_halp = array_create(_planet_array_size, 0);
p_heresy = array_create(_planet_array_size, 0);
p_hurssy = array_create(_planet_array_size, 0);
p_hurssy_time = array_create(_planet_array_size, 0);
p_heresy_secret = array_create(_planet_array_size, 0);
p_raided = array_create(_planet_array_size, 0);
p_governor = array_create(_planet_array_size, "");
p_operatives = array_create_advanced(_planet_array_size, []);
p_feature = array_create_advanced(_planet_array_size, []);
p_upgrades = array_create_advanced(_planet_array_size, []);
p_influence = array_create_advanced(_planet_array_size, array_create(15, 0));
p_problem = array_create_advanced(_planet_array_size, array_create(8, ""));
p_problem_other_data = array_create_advanced(_planet_array_size, array_create_advanced(8, {}));
p_timer = array_create_advanced(_planet_array_size, array_create(8, -1));

system_player_ground_forces = 0;
garrison = false;

for(run=8; run<=30; run++){
    present_fleet[run]=0;
}
vision=1;
// present_fleets=0;
// tau_fleets=0;

ai_a=-1;
ai_b=-1;
ai_c=-1;
ai_d=-1;
ai_e=-1;

global.star_name_colors = [
	c_gray,
	c_white, //player
	c_gray, //imperium
	c_red, // toaster fuckers
	38144, //nothing for inquisition
	c_white, //ecclesiarchy
	#FF8000, //Hi, I'm Elfo
	#009500, // waagh
	#FECB01, // the greater good
	#AD5272,// bug boys
	c_dkgray, // chaos
	38144, //nothing for heretics either
	#AD5272, //why 12 is skipped in general, we will never know
	#80FF00 // Sleepy robots
]


#region save/load serialization 

/// Called from save function to take all object variables and convert them to a json savable format and return it 
serialize = function(){
    var object_star = self;

    var planet_data = [];

    for(var p = 1; p <= object_star.planets; p++){
        planet_data[p] = {
            dispo: object_star.dispo[p],
            planet: object_star.planet[p],
        };
        var var_names = variable_struct_get_names(object_star);
        for(var n = 0; n < array_length(var_names); n++){
            var var_name = var_names[n];
            if(string_starts_with(var_name, "p_")){
                var val = object_star[$var_name][p];
                variable_struct_set(planet_data[p], var_name, val);
            }
        }
    }


    var save_data = {
        obj: object_get_name(object_index),
        x,
        y,
        present_fleet: object_star.present_fleet,
        planet_data: planet_data,
    }
    if(struct_exists(object_star, "system_garrison")){
        save_data.system_garrison = object_star.system_garrison;
    }
    if(struct_exists(object_star, "system_sabatours")){
        save_data.system_sabatours = object_star.system_sabatours;
    }

      
    var excluded_from_save = ["temp", "serialize", "deserialize", "arraysum"];
    var excluded_from_save_start = ["p_"];

    copy_serializable_fields(object_star, save_data, excluded_from_save, excluded_from_save_start);

    return save_data;
}

function deserialize(save_data){
    var exclusions = ["id", "present_fleet", "planet_data"]; // skip automatic setting of certain vars, handle explicitly later

    // Automatic var setting
    var all_names = struct_get_names(save_data);
    var _len = array_length(all_names);
    for(var i = 0; i < _len; i++){
        var var_name = all_names[i];
        if(array_contains(exclusions, var_name)){
            continue;
        }
        var loaded_value =  struct_get(save_data, var_name);
        variable_struct_set(self, var_name, loaded_value);	
    }

    // Set explicit vars here
    if(struct_exists(save_data, "present_fleet")){
        variable_struct_set(self, "present_fleet", save_data.present_fleet);
    }

    if(struct_exists(save_data, "planet_data")){
        var planet_arr = save_data.planet_data;
        var _len = array_length(planet_arr);
        for(var p = 1; p < _len; p++){
            var planet = planet_arr[p];
            var var_names = struct_get_names(planet);
            for(var v = 0; v < array_length(var_names); v++){
                var var_name = var_names[v];
                var val = planet[$var_name];
                // var_name = "p_type"
                // planet = {"p_type":"hive"};
                // val = planet[$var_name] = "hive"

                self[$var_name][p] = val;
                // variable_struct_set(self, var_name, planet[$var_name]);
            }
        }
    }

     if(struct_exists(save_data, "system_sabatours")){
        variable_struct_set(self, "system_sabatours", save_data.system_sabatours);
    }
     if(struct_exists(save_data, "system_garrison")){
        variable_struct_set(self, "system_garrison", save_data.system_garrison);
    }

}

#endregion
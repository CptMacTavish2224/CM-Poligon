// // Global singletons
// global.NameGenerator = new NameGenerator();
show_debug_message("Creating obj_ini");

// // normal stuff
specials=0;firsts=0;seconds=0;thirds=0;fourths=0;fifths=0;
sixths=0;sevenths=0;eighths=0;ninths=0;tenths=0;commands=0;

heh1=0;heh2=0;

// strin="";
// strin2="";
companies=10;
progenitor=ePROGENITOR.NONE;
aspirant_trial = 0;
obj_ini.custom_advisors  = {};

//default sector name to prevent potential crash
sector_name = "Terra Nova";
//default
load_to_ships=[2,0,0];
if (instance_exists(obj_creation)){load_to_ships=obj_creation.load_to_ships;}

penitent=0;
penitent_max=0;
penitent_current=0;
penitent_end=0;
man_size=0;
home_planet = 2;
artifact_struct = array_create(200);

// Equipment- maybe the bikes should go here or something?          yes they should
equipment = {};

var _artifact_array_size = 200;
artifact = array_create(_artifact_array_size, "");
artifact_equipped = array_create(_artifact_array_size, false);
artifact_tags = array_create_advanced(_artifact_array_size, []);
artifact_identified = array_create(_artifact_array_size, 0);
artifact_condition = array_create(_artifact_array_size, 100);
artifact_quality = array_create(_artifact_array_size, "artifact");
artifact_loc = array_create(_artifact_array_size, "");
artifact_sid = array_create(_artifact_array_size, 0);
artifact_struct = array_create(_artifact_array_size);
for (var i = 0; i < _artifact_array_size; i++) {
    artifact_struct[i] = new ArtifactStruct(i);
}

init_player_fleet_arrays();
ship_id = [];

var v;
var company=-1;
repeat(11){
    company+=1;v=-1;// show_message("v company: "+string(company));
    repeat(205){v+=1;// show_message(string(company)+"."+string(v));
        last_ship[company,v] = {uid : "", name : ""};
        veh_race[company,v]=0;
        veh_loc[company,v]="";
        veh_name[company,v]="";
        veh_role[company,v]="";
        veh_wep1[company,v]="";
        veh_wep2[company,v]="";
        veh_wep3[company,v]="";
        veh_upgrade[company,v]="";
        veh_acc[company,v]="";
        veh_hp[company,v]=100;
        veh_chaos[company,v]=0;
        veh_pilots[company,v]=0;
        veh_lid[company,v]=-1;
        veh_wid[company,v]=2;
        veh_uid[company,v]=0;
    }
}

/*if (obj_creation.fleet_type=3){
    obj_controller.penitent=1;
    obj_controller.penitent_max=(obj_creation.maximum_size*1000)+300;
    if (obj_creation.chapter_name="Lamenters") then obj_controller.penitent_max=100300;
    obj_controller.penitent_current=300;
}*/

check_number=0;
year_fraction=0;
year=0;
millenium=0;
company_spawn_buffs = [];
role_spawn_buffs ={};
previous_forge_masters = [];
recruit_trial = 0;
recruiting_type="Death";

gene_slaves = [];

adv = [];
dis = [];


if (instance_exists(obj_creation)) then custom=obj_creation.custom;

if (global.load==-1) then scr_initialize_custom();

#region save/load serialization 

/// Called from save function to take all object variables and convert them to a json savable format and return it 
serialize = function(){
    var object_ini = self;
    
    var marines = array_create(0);
    for(var coy = 0; coy <=10; coy++){
        for(var mar = 0; mar <=500; mar++){
            var marine_json;
            if(obj_ini.name[coy][mar] != ""){
                marine_json = jsonify_marine_struct(coy, mar, false);
                array_push(marines, marine_json);
            } else if(mar > 0){
                break;
            }
        }
    }
    var squads = [];
    if (array_length(object_ini.squads)> 0){
        for (var i = 0;i < array_length(object_ini.squads);i++){
            array_push(squads, object_ini.squads[i].jsonify(false));
        }
    }

    var artifact_struct_trimmed = [];
    for(var i = 0; i < array_length(artifact_struct); i++){
        if(artifact_struct[i].name != ""){
            array_push(artifact_struct_trimmed, artifact_struct[i]);
        }
    }
    

    var save_data = {
        obj: object_get_name(object_index),
        x,
        y,
        custom_advisors,
        full_liveries: full_liveries,
        company_liveries : company_liveries,
        complex_livery_data: complex_livery_data,
        squad_types: squad_types,
        artifact_struct: artifact_struct_trimmed,
        marine_structs: marines,
        squad_structs: squads,
        equipment: equipment,
        gene_slaves: gene_slaves
        // marines,
        // squads
    }

    if(struct_exists(object_ini, "last_ship")){
        save_data.last_ship = object_ini.last_ship;
    }
    
    var excluded_from_save = ["temp", "serialize", "deserialize", "load_default_gear", "role_spawn_buffs", "TTRPG", "squads", "squad_types", "marines", "last_ship"];

    copy_serializable_fields(object_ini, save_data, excluded_from_save);

    return save_data;
}

deserialize = function(save_data){
    var exclusions = ["complex_livery_data", "full_liveries","company_liveries", "squad_types", "marine_structs", "squad_structs"]; // skip automatic setting of certain vars, handle explicitly later

    // Automatic var setting
    var all_names = struct_get_names(save_data);
    var _len = array_length(all_names);
    for(var i = 0; i < _len; i++){
        var var_name = all_names[i];
        if(array_contains(exclusions, var_name)){
            continue;
        }
        
        var loaded_value = struct_get(save_data, var_name);
        // show_debug_message($"obj_ini var: {var_name}  -  val: {loaded_value}");
        try {
            variable_struct_set(obj_ini, var_name, loaded_value);	
        } catch (e){
            show_debug_message(e);
        }
    }

    // Set explicit vars here
    var livery_picker = new ColourItem(0,0);
    livery_picker.scr_unit_draw_data();
    if(struct_exists(save_data, "full_liveries")){
        variable_struct_set(obj_ini, "full_liveries", save_data.full_liveries)
    } else {
        variable_struct_set(obj_ini, "full_liveries", array_create(21,variable_clone(livery_picker.map_colour)));
    }

    livery_picker.scr_unit_draw_data(-1);
    if(struct_exists(save_data, "company_liveries")){
        variable_struct_set(obj_ini, "company_liveries", save_data.company_liveries)
    } else {
        variable_struct_set(obj_ini, "company_liveries", array_create(11,variable_clone(livery_picker.map_colour)));
    }

    livery_picker.scr_unit_draw_data();

    if(struct_exists(save_data, "complex_livery_data")){
        variable_struct_set(obj_ini, "complex_livery_data", save_data.complex_livery_data);
    }
    if(struct_exists(save_data, "squad_types")){
        variable_struct_set(obj_ini, "squad_types", save_data.squad_types);
    }

    if(struct_exists(save_data, "marine_structs")){
        obj_ini.TTRPG = array_create(11, []);
        var marines_encoded_arr = save_data.marine_structs;
        var _m_ar_len = array_length(marines_encoded_arr);
        for(var m = 0; m < _m_ar_len; m++){
                var marine_json = marines_encoded_arr[m];
                var coy = marine_json.company;
                var mar = marine_json.marine_number;
                load_marine_struct(coy, mar, marine_json); 
        }
        for(var coy = 0; coy < 11; coy++){
            var mar_start = array_length(obj_ini.TTRPG[coy]);
            for(var mar = mar_start; mar < 501; mar++){
                obj_ini.TTRPG[coy][mar] = new TTRPG_stats("chapter",coy, mar, "blank");
            }
        }
    }

    if(struct_exists(save_data, "squad_structs")){
        obj_ini.squads = [];
        var squad_fetch = save_data.squad_structs;
        for (i=0;i<array_length(squad_fetch);i++){
            var sq = new UnitSquad();
            sq.load_json_data(squad_fetch[i]);
            array_push(obj_ini.squads, sq);
        }
    }

    if(struct_exists(save_data, "artifact_struct")){
        obj_ini.artifact_struct = [];
        var artifact_str_arr = save_data.artifact_struct;
        var _len = array_length(artifact_str_arr);
        for(var i = 0; i < 200; i++){ // 200 is the max number of artifacts
            var arti_struct = new ArtifactStruct(i);
            if(i < _len){ // still within the save_data array
                var arti = artifact_str_arr[i];
                if(arti != -1){ // in the serializer we trim out empty slots so there will be nothing to load
                    arti_struct.load_json_data(arti);
                }
                array_push(obj_ini.artifact_struct, arti_struct);
            } else {
                array_push(obj_ini.artifact_struct, arti_struct); //load empty ones into the rest of the slots
            }
        }
    }

    if(struct_exists(save_data, "gene_slaves")){
        variable_struct_set(obj_ini, "gene_slaves", save_data.gene_slaves);
    }
}


#endregion

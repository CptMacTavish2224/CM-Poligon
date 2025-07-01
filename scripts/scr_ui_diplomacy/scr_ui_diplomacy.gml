function draw_character_diplomacy_base_page(){
	obj_controller.menu_lock = true;
	if (!audience){
		with (diplo_buttons){
			trade.draw();
			demand.draw();
			discuss.draw();
			alliance.draw();
			denounce.draw();
			praise.draw();			
			declare_war.draw_shutter(praise.x1,alliance.y2,"WAR",0.4);
		}
	} else {
		if (!valid_diplomacy_options()){
			diplo_buttons.denounce.draw();
			diplo_buttons.praise.draw();
		}
	}
	if (!valid_diplomacy_options() || force_goodbye){
		diplo_buttons.exit_button.draw();
	}
}

function intro_to_diplomacy(faction_enum){
	with (obj_controller){
	    var _new_diag = "intro";
	    if  (faction_enum!=4){
	        if (known[faction_enum]==1) {
	            known[diplomacy]=2;
	            faction_justmet=1;
	        }
	        else if (known[faction_enum]>=2)  {
	            _new_diag = "hello";
	        }
	    } else {
	        if (known[eFACTION.Inquisition]==1)  {
	            known[diplomacy]=2;
	            faction_justmet=1;
	            obj_controller.last_mission=turn+1;
	        }
	        else if (known[eFACTION.Inquisition]==3)  {
	            known[faction_enum]=4;
	            faction_justmet=1;
	            obj_controller.last_mission=turn+1;
	        }
	        else if (known[faction_enum]>=4)  {
	            _new_diag = "hello";
	        }	
	    }
	    scr_dialogue(_new_diag);	
	}
}

function draw_diplomacy_diplo_text(){
    draw_set_font(fnt_40k_14);
    draw_set_alpha(1);
    draw_set_color(38144);
    draw_set_halign(fa_left);
    draw_text_ext(336+16,209,string_hash_to_newline(string(diplo_txt)),-1,536);
    draw_set_halign(fa_center);
    draw_line(xx+429,yy+710,xx+800,yy+710);	
}
function set_up_diplomacy_buttons(){
	diplo_buttons = {};
	set_up_diplomacy_persons();
	//Trade button setup
	diplo_buttons.trade = new UnitButtonObject({
		x1 : 400,
		y1 : 720,
		label : "Trade",
		bind_scope : obj_controller,
		style:"pixel"
	});
	diplo_buttons.trade.bind_method = function(){
    	if ((audience==0) and (force_goodbye==0)){
            trading=1;
            scr_dialogue("open_trade");
            cooldown=8;
            click2=1;
            trade_attempt = new TradeAttempt(diplomacy);
    	}		
	}


	//Demand button setup
	diplo_buttons.demand = new UnitButtonObject({
		x1 : 600,
		y1 : 720,
		label : "Demand",
		bind_scope : obj_controller,
		style:"pixel"
	});
	diplo_buttons.demand.bind_method = function(){
    	if ((audience==0) and (force_goodbye==0)){
            cooldown=8;
            click2=1;
            trading_demand=diplomacy;
            scr_dialogue("trading_demand");
    	}		
	}

	//Discuss button setup	
	diplo_buttons.discuss = new UnitButtonObject({
		x1 : 800,
		y1 : 720,
		label : "Discuss",
		tooltip : "Unfinished",
		bind_scope : obj_controller,
		style:"pixel"
	});


	//denounce button setup
	diplo_buttons.denounce = new UnitButtonObject({
		x1 : 400,
		y1 : diplo_buttons.trade.y2,
		label : "Denounce",
		bind_scope : obj_controller,
		style:"pixel"
	});

	diplo_buttons.denounce.bind_method = function(){
        if (diplo_last!="denounced"){
            scr_dialogue("denounced");
            cooldown=8;
            click2=1;
        }		
	}

	diplo_buttons.praise = new UnitButtonObject({
		x1 : 600,
		y1 : diplo_buttons.trade.y2,
		label : "Praise",
		bind_scope : obj_controller,
		style:"pixel"
	});

	diplo_buttons.praise.bind_method = function(){
        if (diplo_last!="praised"){
            scr_dialogue("praised");
            cooldown=8;
            click2=1;
        }			
	}

	diplo_buttons.alliance = new UnitButtonObject({
		x1 : 800,
		y1 : diplo_buttons.trade.y2,
		label : "Propose\nAlliance",
		bind_scope : obj_controller,
		style:"pixel"
	});


	diplo_buttons.alliance.bind_method = function(){
        if (diplo_last!="propose_alliance"){
            cooldown=8;
            click2=1;
            scr_dialogue("propose_alliance");
        }			
	}

	diplo_buttons.exit_button = new UnitButtonObject({
		x1 : 818,
		y1 : 795,
		label : "Exit",
		bind_scope : obj_controller,
		color : CM_RED_COLOR,
	});

	diplo_buttons.exit_button.bind_method = function(){
		obj_controller.menu_lock = false;
		if (audio_is_playing(snd_blood)==true) then scr_music("royal",2000);

		var _close_diplomacy = true;
        if (complex_event==true) and (instance_exists(obj_temp_meeting)){
            complex_event=false;
            with(obj_temp_meeting){
            	instance_destroy();
            }
            if (instance_exists(obj_turn_end)){
                obj_turn_end.alarm[1]=1;
            }
        }
        if (trading_artifact!=0){
            clear_diplo_choices();
            cooldown=8;
            if (trading_artifact==2) and (instance_exists(obj_ground_mission)){
                obj_ground_mission.alarm[2]=1;
            }// 135 this might not be needed
            trading_artifact=0;
            with(obj_popup){
                obj_ground_mission.alarm[1]=1;
                instance_destroy();
            }
        }
        if (force_goodbye==5){
            clear_diplo_choices();
        }
        if (liscensing==2) and (repair_ships==0){
            cooldown=8;
            var cru=instance_create(mouse_x,mouse_y,obj_crusade);
            cru.owner=diplomacy;
            cru.placing=true;
            exit_all=0;
            liscensing=0;
            if (zoomed==0) then scr_zoom();
        }
        if (exit_all!=0){
            exit_all=0;
        }
        if (diplo_last=="artifact_thanks") and (force_goodbye!=0){

			scr_toggle_armamentarium();
			_close_diplomacy = false;
        }
        // Exits back to diplomacy thing
        if (audience==0){
            cooldown=8;
            diplomacy=0;
            force_goodbye=0;
            _close_diplomacy = false;
        }
        // No need to check for next audience
        if (audience>0) and (instance_exists(obj_turn_end)){
            if (complex_event==false){

                obj_turn_end.alarm[1]=1;
                show_debug_message("next_audience");
            }
            if (complex_event=true){
                // TODO
            }
        }
        if (_close_diplomacy){
        	scr_toggle_diplomacy();
        }
	}


	diplo_buttons.declare_war = new ShutterButton();
	var _war = diplo_buttons.declare_war;
	_war.XX= 640;
	_war.YY= diplo_buttons.alliance.y2;
	_war.label = "DECLARE WAR";
	_war.tooltip = "Unfinished";
	_war.color = CM_RED_COLOR;
	_war.cover_text= "Declare War";
	_war.bind_scope = obj_controller;
}

function set_up_diplomacy_persons(){
	diplo_persons = {
	}
	diplo_persons.imperium = new ShutterButton();
	var _imp = diplo_persons.imperium;
	_imp.image = known[eFACTION.Imperium] ? 3 : 4;
	_imp._faction_enum = eFACTION.Imperium;

	diplo_persons.mechanicus = new ShutterButton();
	var _mechs = diplo_persons.mechanicus;
	_mechs.image = known[eFACTION.Mechanicus] ? 5 : 6;
	_mechs._faction_enum = eFACTION.Mechanicus;

	diplo_persons.inquisition = new ShutterButton();
	var _inquis = diplo_persons.inquisition;
	_inquis.image = known[eFACTION.Inquisition] ? 7 : 8;
	_inquis._faction_enum = eFACTION.Inquisition;

	diplo_persons.sisters = new ShutterButton();
	var _sisters = diplo_persons.sisters;
	_sisters.image = known[eFACTION.Ecclesiarchy] ? 9 : 10;
	_sisters._faction_enum = eFACTION.Ecclesiarchy;



	diplo_persons.eldar = new ShutterButton();
	var _eldar = diplo_persons.eldar;
	if (faction_gender[eFACTION.Eldar]=1){
		_eldar.image = known[eFACTION.Eldar] ? 9 : 10;
	} else {
		_eldar.image = known[eFACTION.Eldar] ? 21 : 22;
	}
	_eldar._faction_enum = eFACTION.Eldar;


	diplo_persons.ork = new ShutterButton();
	var _orks = diplo_persons.ork;
	_orks.image = known[eFACTION.Ork] ? 13 : 14;
	_orks._faction_enum = eFACTION.Ork;

	diplo_persons.tau = new ShutterButton();
	var _tau = diplo_persons.tau;
	_tau.image = known[eFACTION.Tau] ? 15 : 16;
	_tau._faction_enum = eFACTION.Tau;

	diplo_persons.chaos = new ShutterButton();
	var imm=19;
	if (known[eFACTION.Chaos]>0 && faction_gender[eFACTION.Chaos]=2) then imm=27;
	if (known[eFACTION.Chaos]<1 && faction_gender[eFACTION.Chaos]=1) then imm=20;
	if (known[eFACTION.Chaos]<1 && faction_gender[eFACTION.Chaos]=2) then imm=28;
	var _chaos = diplo_persons.chaos;
	_chaos.image = imm;
	_chaos._faction_enum = eFACTION.Chaos;

	var _shutters = [_imp, _mechs, _inquis, _sisters, _eldar, _orks, _tau, _chaos];

	for (var i=0;i<array_length(_shutters);i++){
		var _button = _shutters[i];
		with (_button){
		    management_buttons = {
		        audience: new UnitButtonObject({
		            style: "pixel",
		            label: "Request Audience",
		            //tooltip: "."
		        }),
		        ignore: new UnitButtonObject({
		            style: "pixel",
		            label: "Ignore",
		            //tooltip: "."
		        }),
		        unignore: new UnitButtonObject({
		            style: "pixel",
		            label: "Unignore",
		            tooltip: "Click here or press B to Toggle Unit Biography."
		        }),
		        screen_slate : new DataSlate(),
		    };
		    var _screen_slate = management_buttons.screen_slate;
		    _screen_slate.XX = XX+10;
		    _screen_slate.YY = YY+141;
		   	_screen_slate.set_width = true;
			_screen_slate.style = "plain";
			_screen_slate.width = 153;
			_screen_slate.height = 135;
			_screen_slate.inside_method = function(){
				scr_image("diplomacy/icons",image,XX+10,YY+10,153,135);
			}
			cover_text = obj_controller.faction[_faction_enum];
			inside_method = function(){
				var yy = YY;
				var xx = XX;
			    draw_set_font(fnt_40k_14b);
				draw_set_halign(fa_left);
				draw_text(xx+169,yy+35,obj_controller.faction[_faction_enum]);
				management_buttons.screen_slate.draw_with_dimensions(xx+5, yy+5,);
			    draw_set_font(fnt_40k_14);
				draw_set_halign(fa_right);
			    draw_text_transformed(xx+420,yy+20,obj_controller.faction_status[_faction_enum],0.7,0.7,0);
			    draw_set_halign(fa_left);
				var txt;
			    txt="????";
				if (obj_controller.known[_faction_enum]>0){
					txt=$"{obj_controller.faction_title[_faction_enum]} {obj_controller.faction_leader[_faction_enum]}";
				}
				draw_text_transformed(xx+169,yy+50,txt,0.7,0.7,0);
				draw_text_transformed(xx+169,yy+65,$"Disposition: {obj_controller.disposition[_faction_enum]}",0.7,0.7,0);	
				scr_draw_rainbow(xx+250,yy+66,xx+400,yy+76,(obj_controller.disposition[_faction_enum]/200)+0.5);

			    if (obj_controller.known[_faction_enum]>0.7) and (obj_controller.faction_defeated[_faction_enum]=0) {
			    	var _audience = management_buttons.audience;
			    	_audience.update({
			            x1: xx+169,
			            y1: yy+85,			    		
			    	});
			    	_audience.bind_method = function(){
			            if (obj_controller.known[_faction_enum]!=0) and (obj_controller.turns_ignored[_faction_enum]==0){
			                obj_controller.diplomacy = _faction_enum;
			                intro_to_diplomacy(_faction_enum);	    
			            }
			            		
			    	}
			    	_audience.draw();
			    	var _ignore_status = obj_controller.ignore[_faction_enum] < 1 ? management_buttons.ignore : management_buttons.unignore;

			    	_ignore_status.update({
			            x1: _audience.x2+1,
			            y1: yy+85,			    		
			    	});
			    	_ignore_status.draw();
		        
		    
			        /*var fis;fis="[Request Audience]";
			        if (turns_ignored[2]>0) then fis="                  ";
			        if (ignore[eFACTION.Imperium]<1) then draw_text_transformed(xx+189,yy+354,string(fis)+"  [Ignore]",0.7,0.7,0);
			        if (ignore[eFACTION.Imperium]>=1) then draw_text_transformed(xx+189,yy+354,string(fis)+"[Unignore]",0.7,0.7,0);*/
			    }		
			}
		}
	}
}


function scr_ui_diplomacy() {
	if (menu != MENU.Diplomacy){
		return;
	}
	var xx,yy,show_stuff;
	xx=__view_get( e__VW.XView, 0 )+0;
	yy=__view_get( e__VW.YView, 0 )+0;
	var show_stuff=false;
	var warning=0;

	// This script draws all of the diplomacy stuff, up to and including trading.

	xx+=6;

	if (diplomacy=0){// Main diplomacy screen
	    draw_set_alpha(1);
		draw_set_color(0);
		draw_rectangle(xx,yy,xx+1600,yy+900,0);
	    draw_set_alpha(0.5);
		draw_sprite(spr_rock_bg,0,xx,yy);
		draw_set_alpha(1);

	    /*draw_set_color(38144);
	    draw_rectangle(xx+31,yy+281,xx+438,yy+416,0);
	    draw_rectangle(xx+31,yy+417,xx+438,yy+552,0);
	    draw_rectangle(xx+31,yy+553,xx+438,yy+688,0);
	    draw_rectangle(xx+31,yy+689,xx+438,yy+824,0);
	    // 
	    draw_rectangle(xx+451,yy+281,xx+858,yy+125,0);
	    draw_rectangle(xx+451,yy+417,xx+858,yy+125+91,0);
	    draw_rectangle(xx+451,yy+553,xx+858,yy+125+182,0);
	    draw_rectangle(xx+451,yy+689,xx+858,yy+125+273,0);*/
    
    
	    draw_set_color(38144);
	    draw_set_font(fnt_40k_30b);
	    draw_set_halign(fa_center);
	    draw_text(xx+800,yy+74,string_hash_to_newline("Diplomacy"));
    
    
	    xx+=55;yy-=20;
    
    	diplo_persons.imperium.draw_shutter(xx+31, yy+281, false, 1.5, known[eFACTION.Imperium]>0.7);

    	diplo_persons.mechanicus.draw_shutter(xx+31, yy+417, false, 1.5, known[eFACTION.Mechanicus]>0.7);

    	diplo_persons.inquisition.draw_shutter(xx+31, yy+553, false, 1.5, known[eFACTION.Inquisition]>0.7);

    	diplo_persons.sisters.draw_shutter(xx+31, yy+689, false, 1.5, known[eFACTION.Ecclesiarchy]>0.7);

    	diplo_persons.eldar.draw_shutter(xx+1041, yy+281, false, 1.5, known[eFACTION.Eldar]>0.7);

    	diplo_persons.ork.draw_shutter(xx+1041, yy+417, false, 1.5, known[eFACTION.Ork]>0.7);

    	diplo_persons.tau.draw_shutter(xx+1041, yy+553, false, 1.5, known[eFACTION.Tau]>0.7);

    	diplo_persons.chaos.draw_shutter(xx+1041, yy+689, false, 1.5, known[eFACTION.Chaos]>0.7);

    
	    scr_image("symbol",0,xx+138,yy+174,217,107);
	    scr_image("symbol",1,xx+525,yy+174,109,54);
	    scr_image("symbol",2,xx+1147,yy+174,217,107);
    
		

		//draws chapter diplomacy
		/*draw_rectangle(xx+451,yy+281,xx+675,yy+416,1);
		draw_line(xx+604,yy+281,xx+604,yy+416);
	    draw_rectangle(xx+451,yy+417,xx+675,yy+552,1);
		draw_line(xx+604,yy+417,xx+604,yy+553);
	    draw_rectangle(xx+451,yy+553,xx+675,yy+688,1);
		draw_line(xx+604,yy+553,xx+604,yy+689);
	    draw_rectangle(xx+451,yy+689,xx+675,yy+824,1);
		draw_line(xx+604,yy+689,xx+604,yy+824);
		*/
    
    
    
	    draw_set_font(fnt_40k_14b);
		draw_set_halign(fa_left);
		
		//draw faction names, etc
	    draw_text(xx+609,yy+285,"Chapter 1");
	    draw_text(xx+609,yy+421,"Chapter 2");
	    draw_text(xx+609,yy+557,"Chapter 3");
	    draw_text(xx+609,yy+693,"Chapter 4");
    
		//render status, i.e. whether at war, that stuff
	    draw_set_font(fnt_40k_14);
		draw_set_halign(fa_right);

    
	    draw_set_halign(fa_left);
		var txt;
    
   
    
	    /*draw_sprite(spr_disposition_small,round((disposition[2]+100)/10),xx+131,yy+74);
	    draw_sprite(spr_disposition_small,round((disposition[3]+100)/10),xx+131+286,yy+74);
    
	    draw_sprite(spr_disposition_small,round((disposition[4]+100)/10),xx+131,yy+74+91);
	    draw_sprite(spr_disposition_small,round((disposition[5]+100)/10),xx+131+286,yy+74+91);
    
	    draw_sprite(spr_disposition_small,round((disposition[6]+100)/10),xx+131,yy+74+182);
	    draw_sprite(spr_disposition_small,round((disposition[7]+100)/10),xx+131+286,yy+74+182);
    
	    draw_sprite(spr_disposition_small,round((disposition[8]+100)/10),xx+131,yy+74+273);
	    draw_sprite(spr_disposition_small,round((disposition[10]+100)/10),xx+131+286,yy+74+273);*/
    
    
		//draw the meet chaos button
	    draw_set_halign(fa_left);
	    draw_set_color(38144);
		draw_rectangle(xx+688,yy+240,xx+1028,yy+281,0);
	    draw_set_color(c_black);
		draw_text_transformed(xx+688,yy+241,string_hash_to_newline(" Meet Chaos Emmissary"),0.7,0.7,0);
		//color blending stuff if hovering over the meeting chaos icon
	    if (point_in_rectangle(mouse_x, mouse_y, xx+688,yy+240,xx+1028,yy+281)){
	        draw_set_alpha(0.2);
			draw_rectangle(xx+688,yy+240,xx+1028,yy+281,0);
			draw_set_alpha(1);
		};
	    var x6,y6,x7,y7;
	    x6=0;y6=0;x7=0;y7=0;
	    xx-=55;yy+=20;
		
		
		#region faction talks/ignore stuff

    
		#endregion

	    /*
	    faction_leader[0]="";faction_title[0]="";faction_status[0]="";faction_leader[1]="";faction_title[1]="";faction_status[1]="";
	    faction_leader[eFACTION.Imperium]="";faction_title[2]="Sector Commander";faction_status[eFACTION.Imperium]="Allied";
	    faction_leader[eFACTION.Mechanicus]="";faction_title[3]="Magos";faction_status[eFACTION.Mechanicus]="Allied";
	    faction_leader[eFACTION.Inquisition]="";faction_title[4]="Inquisitor Lord";faction_status[eFACTION.Inquisition]="Allied";
	    faction_leader[eFACTION.Ecclesiarchy]="";faction_title[5]="Prioress";faction_status[eFACTION.Ecclesiarchy]="Allied";
	    faction_leader[eFACTION.Eldar]="";faction_title[6]="Farseer";faction_status[eFACTION.Eldar]="War";
	    faction_leader[eFACTION.Ork]="";faction_title[7]="Warboss";faction_status[eFACTION.Ork]="War";
	    faction_leader[eFACTION.Tau]="";faction_title[8]="Diplomat";faction_status[eFACTION.Tau]="War";
	    faction_leader[eFACTION.Tyranids]="";faction_title[9]="";faction_status[eFACTION.Tyranids]="War";
	    faction_leader[eFACTION.Chaos]="";faction_title[10]="Master";faction_status[eFACTION.Chaos]="War";
	    */
    
    
    
	}


	xx=__view_get( e__VW.XView, 0 );
	yy=__view_get( e__VW.YView, 0 );


	if (diplomacy<-5) and (diplomacy>-6){
	    draw_sprite(spr_rock_bg,0,xx,yy);
	    // draw_sprite(spr_diplo_splash,diplomacy,xx+916,yy+33);
	    draw_set_alpha(0.75);
		draw_set_color(0);
		draw_rectangle(xx+326+16,yy+66,xx+887+16,yy+820,0);
	    draw_set_alpha(1);
		draw_set_color(38144);
		draw_rectangle(xx+326+16,yy+66,xx+887+16,yy+820,1);
    
	    var advi,fra;advi="";fra=0;
	    if (diplomacy=-5.1){advi="apoth";fra=1;}
	    if (diplomacy=-5.2){advi="chap";fra=2;if (global.chapter_name="Space Wolves") then fra=11;}
	    if (diplomacy=-5.3){advi="libr";fra=3;if (global.chapter_name="Space Wolves") then fra=10;}
	    if (diplomacy=-5.4){advi="tech";fra=4;}
	    if (diplomacy=-5.5){advi="recr";fra=5;}
	    if (diplomacy=-5.6){advi="flee";fra=6;}
    
	    // draw_sprite(spr_advisors,fra,xx+16,yy+43);
	    scr_image("advisor/splash",fra+1,xx+16,yy+43,310,828);
	    draw_set_halign(fa_center);
	    draw_set_color(38144);
	    draw_set_font(fnt_40k_30b);
    
	    var fac="";
	    var fac2=string(global.chapter_name)+" (Imperium)";
	    var fac3="";
	    var warning=0;
    
	    if (advi="flee") then fac="Master of the Fleet "+string(obj_ini.lord_admiral_name);
	    if (advi="apoth") then fac="Master of the Apothecarion "+string(obj_ini.name[0,4]);
	    if (advi="chap") then fac="Master of Sanctity "+string(obj_ini.name[0,3]);
	    if (advi="libr") then fac="Chief "+string(obj_ini.role[100,17])+" "+string(obj_ini.name[0,5]);
	    if (advi="tech") then fac="Forge Master "+string(obj_ini.name[0,2]);
	    if (advi="") then fac="First Sergeant "+string(recruiter_name); 
    
	    draw_text_transformed(xx+622,yy+66,fac2,1,1,0);
	    draw_text_transformed(xx+622,yy+104,fac,0.6,0.6,0);
    
	    show_stuff=true;
	}



	if (diplomacy>0){// Diplomacy - Speaking
	    var daemon;
		daemon=false;
		if (diplomacy>10) and (diplomacy<11) then daemon=true;
	    draw_sprite(spr_rock_bg,0,xx,yy);
	    // draw_sprite(spr_diplo_splash,diplomacy,xx+916,yy+33);
	    draw_set_alpha(0.75);
		draw_set_color(0);
		draw_rectangle(xx+326+16,yy+66,xx+887+16,yy+820,0);
	    draw_set_alpha(1);
		draw_set_color(38144);
		draw_rectangle(xx+326+16,yy+66,xx+887+16,yy+820,1);
		if (diplomacy==10.1){
	        // if (diplomacy=10.1) then draw_sprite(spr_diplomacy_dae,0,xx+16,yy+43);
	        daemon=true;
			scr_image("diplomacy_daemon",0,xx+16,yy+43,310,828);
			show_stuff=false;
			if (mouse_x>=xx+360) and (mouse_y>=yy+143) and (mouse_x<=xx+884) and (mouse_y<=yy+180) then warning=1;
		}
    
	    if (daemon=false){
	        if (diplomacy!=eFACTION.Eldar) then scr_image("diplomacy/splash",diplomacy,xx+16,yy+43,310,828);
	        if (diplomacy!=eFACTION.Eldar) or ((diplomacy==eFACTION.Eldar) and (faction_gender[eFACTION.Eldar]=1)) then scr_image("diplomacy/splash",diplomacy,xx+16,yy+16,310,828);
	        if (diplomacy==eFACTION.Eldar) and (faction_gender[eFACTION.Eldar]=2) then scr_image("diplomacy/splash",11,xx+16,yy+16,310,828);
	        if (diplomacy==eFACTION.Chaos) and (faction_gender[eFACTION.Chaos]=2) then scr_image("diplomacy/splash",12,xx+16,yy+43,310,828);
	    }
    
	    draw_set_halign(fa_center);
	    draw_set_color(38144);
	    draw_set_font(fnt_40k_30b);
    
	    var fac, fac2, fac3,warning;fac="";fac2=" (Imperium)";fac3="";warning=0;
	    if (diplomacy>=6) then fac2="";
    
    
	    if (diplomacy==eFACTION.Imperium) then fac="Imperium of Man";
	    if (diplomacy==eFACTION.Mechanicus) then fac="Adeptus Mechanicus";
	    if (diplomacy==eFACTION.Inquisition) then fac="Inquisition";
	    if (diplomacy==eFACTION.Ecclesiarchy) then fac="Ecclesiarchy";
	    if (diplomacy==eFACTION.Eldar) then fac="Eldar";
	    if (diplomacy==eFACTION.Ork) then fac="Orks";
	    if (diplomacy==eFACTION.Tau) then fac="Tau Empire";
	    if (diplomacy==eFACTION.Chaos) then fac="Heretics";
	    if (diplomacy>10) and (diplomacy<11) then fac="Chaos";
    
	    draw_text_transformed(xx+622,yy+66,string_hash_to_newline(string(fac)),1,1,0);
    
	    if (daemon=true){ draw_text_transformed(xx+622,yy+104,string_hash_to_newline("The Emmmisary"),0.6,0.6,0);show_stuff=true;};
	    if (daemon=false) then draw_text_transformed(xx+622,yy+104,string_hash_to_newline(string(faction_title[diplomacy])+" "+string(faction_leader[diplomacy])+string(fac2)),0.6,0.6,0);
    
	    draw_set_font(fnt_40k_14);
    
	    if (daemon=false){
	        fac3="Disposition: ";
	        if (disposition[diplomacy]<=-20) then fac3+="Hated";
	        if (disposition[diplomacy]>-20) and (disposition[diplomacy]<0) then fac3+="Hostile";
	        if (disposition[diplomacy]>=0) and (disposition[diplomacy]<10) then fac3+="Suspicious";
	        if (disposition[diplomacy]>=10) and (disposition[diplomacy]<20) then fac3+="Uneasy";
	        if (disposition[diplomacy]>=20) and (disposition[diplomacy]<40) then fac3+="Neutral";
	        if (disposition[diplomacy]>=40) and (disposition[diplomacy]<60) then fac3+="Allies";
	        if (disposition[diplomacy]>=60) and (disposition[diplomacy]<80) then fac3+="Close Allies";
	        if (disposition[diplomacy]>=80) then fac3+="Battle Brothers";
	        fac3+=" ("+string(disposition[diplomacy])+")";
	        // draw_set_halign(fa_center);
	        draw_text(xx+622,yy+144,string_hash_to_newline(string(fac3)));
	        scr_draw_rainbow(xx+366,yy+165,xx+871,yy+175,(disposition[diplomacy]/200)+0.5);
	    }
	    draw_set_color(c_gray);
	    draw_rectangle(xx+366,yy+165,xx+871,yy+175,1);
    
	    show_stuff=true;
	}
		
	if (warning=1) and (diplomacy>=6){
        var warn;
        if (diplomacy<10) and (warning=1) then warn="Consorting with xenos will cause your disposition with the Imperium to lower.";
        if (diplomacy>=10) and (warning=1) then warn="Consorting with heretics will cause your disposition with the Imperium to plummet.";

        draw_rectangle(mouse_x-2,mouse_y+20,mouse_x+2+string_width_ext(warn,-1,600),mouse_y+24+string_height_ext(warn,-1,600),0);
        draw_set_color(38144);
        draw_rectangle(mouse_x-2,mouse_y+20,mouse_x+2+string_width_ext(warn,-1,600),mouse_y+24+string_height_ext(warn,-1,600),1);
        draw_text_ext(mouse_x,mouse_y+22,warn,-1,600);
    }
    
	//scr_dialogue(diplomacy_pathway);
	basic_diplomacy_screen();

}

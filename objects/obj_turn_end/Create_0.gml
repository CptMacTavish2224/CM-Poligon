
instance_deactivate_object(obj_star_select);
instance_deactivate_object(obj_drop_select);
instance_deactivate_object(obj_bomb_select);

var i;i=-1;
keywords="";
last_open=1;

battles=0;
audiences=0;
popups=0;
alerts=0;
fadeout=0;
popups_end=0;

current_battle=1;
current_popup=0;

fast=0;// This is increased, once the alert[i]=1 and >=fast then it begins to fade in and get letters
info_mahreens=0;
info_vehicles=0;

first_x=obj_controller.x;// Return to this position once all the battles are done
first_y=obj_controller.y;
combating=0;
cooldown=10;

obj_controller.menu=999;// show nothing, click nothing

i=-1;repeat(11){i+=1;enemy_fleet[i]=0;allied_fleet[i]=0;ecap[i]=0;efri[i]=0;eesc[i]=0;acap[i]=0;afri[i]=0;aesc[i]=0;}

i=-1;
repeat(91){
    i+=1;
    
    popup[i]=0;
    popup_type[i]="";
    popup_text[i]="";
    popup_image[i]="";
    popup_special[i]="";
    
    alert[i]=0;
    alert_type[i]="";
    alert_text[i]="";
    
    alert_char[i]=0;
    alert_alpha[i]=0;
    alert_txt[i]="";
    alert_color[i]="";
    
    battle[i]=0;// Set to 0 for none, 1 for battle to do, and 2 for resolved
    battle_location[i]="";
    battle_world[i]=0;// Be like -50 for space battle
    battle_opponent[i]=0;// faction ID
    battle_object[i]=0;// faction object for the fleets
    battle_pobject[i]=0;// player object for the fleets
    battle_special[i]="";
    
    
    if (i<16) then strin[i]="";    
}

audiences = 0;
audience = 0;
audience_stack = [];

alert_alpha[1]=0.2;
alert_char[1]=1;
i=-1
for (var i=0;i<array_length(obj_controller.event);i++){
    if (obj_controller.event[i]!="") and (obj_controller.event_duration[i]=1) and (obj_controller.faction_status[eFACTION.Imperium]!="War"){
        if (obj_controller.event[i]="governor_assassination_1"){
            with(obj_star){
                var o=0;
                repeat(4){
                    o+=1;
                    if (dispo[o]>0) and (dispo[o]<90){
                        dispo[o]=max(dispo[o]-2,0);
                    }
                }
            }
            obj_controller.disposition[2]-=7;
            obj_controller.disposition[4]-=10;
            obj_controller.disposition[5]-=4;
            if (obj_controller.disposition[4]<=0) or (obj_controller.disposition[2]<=0){
                obj_controller.alarm[8]=1;
            }
            if (obj_controller.disposition[4]>0) and (obj_controller.disposition[2]>0){
                var top=string_replace(obj_controller.event[i],"governor_assassination_1","assassination_angryish");
                scr_audience(4,top,0,"",0,0);
            }
        }
        if (string_count("governor_assassination_2",obj_controller.event[i])>0) and (obj_controller.faction_status[eFACTION.Inquisition]!="War"){
            with(obj_star){
                var o=0;
                repeat(4){
                    o+=1;
                    if (dispo[o]>0) and (dispo[o]<90){
                        dispo[o]=max(dispo[o]-4,0);
                    }
                }
            }
            obj_controller.disposition[2]-=15;obj_controller.disposition[4]-=30;obj_controller.disposition[5]-=10;
            if (obj_controller.disposition[4]<=0) or (obj_controller.disposition[2]<=0) then obj_controller.alarm[8]=1;
            if (obj_controller.disposition[4]>0) and (obj_controller.disposition[2]>0){
                var top=string_replace(obj_controller.event[i],"governor_assassination_2","assassination_angry");
                scr_audience(4,top,0,"",0,0);
            }
        }
    }
}i=0;






if (audiences>0){// This is a one-off change all messages to declare war
    var i=0;
    var war;
    repeat(15){
        i+=1;
        war[i]=0;
    }
    for (var i=0;i<array_length(audience_stack);i++){
        var _audience = audience_stack[i];
         if (_audience.topic !="declare_war") and (_audience.topic!="gene_xeno") and (_audience.topic!="") and (war[_audience.faction]=0) and (obj_controller.faction_status[_audience.faction]!="War") and (_audience.faction!=10){
            if (obj_controller.disposition[_audience.faction]<=0) and (_audience.faction<6){
                _audience.topic="declare_war";
                war[_audience.faction]=1;
            }
        }       
    }
}

alerts=0;
fast=0;
show=0;


/* */
/*  */

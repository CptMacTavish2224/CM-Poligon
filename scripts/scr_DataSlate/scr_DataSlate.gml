function DataSlate() constructor{
	static_line=1;
	title="";
	sub_title="";
	body_text = "";
	inside_method = "";
	XX=0;
	YY=0;
	width=0;
	height=0;
	percent_cut=0;
	set_width = false;

	style = "default";

	tooltip_drawing = [];

	blend_col = 5998382;

	static entered = function(){
		return (scr_hit(
                    XX-4,
                    YY,
                    XX + width,
                    YY + height,
                ));
	}

	static draw_with_dimensions = function(xx = -1,yy = -1, Width=-1 , Height=-1){
		if (Width != -1){
			width = Width;
		}
		if (Height != -1){
			height = Height;
		}
		var _scale_x =  width/860;
		var _scale_y =  height/850;
		draw(xx,yy, _scale_x, _scale_y);
	}

	static draw = function(xx= -1,yy = -1, scale_x=1, scale_y=1){
		if (xx != -1){
			XX=xx;
		}
		if (yy != -1){
			YY=yy;
		}

		if (!set_width){
			width = 860*scale_x;
			height = 850*scale_y;
		}

		switch (style){
			case "default":
				draw_sprite_ext(spr_data_slate,1, XX,YY, scale_x, scale_y, 0, c_white, 1);
				break;
			case "decorated":
				draw_sprite_stretched(spr_data_slate_back, 0, XX,YY, width, height);
				draw_sprite_stretched(spr_slate_side, 0, XX,YY, width, height);
				draw_rectangle_color_simple(xx,YY, XX+width,YY+height, 0, blend_col, 0.05);
				break;

			case "plain":
				draw_sprite_stretched(spr_data_slate_back, 0, XX,YY, width, height);
				draw_rectangle_color_simple(xx,YY, XX+width,YY+height, 0, blend_col, 0.05);				
				break;
		}

		if (is_callable(inside_method)){
			inside_method();
		}
	    if (static_line<=10) then draw_set_alpha(static_line/10);
	    if (static_line>10) then draw_set_alpha(1-((static_line-10)/10));		
		draw_set_color(5998382);
		var line_move = YY+(70*scale_y)+((36*scale_y)*static_line);
		draw_line(XX+(30*scale_x),line_move,XX+(820*scale_x),line_move);
		draw_set_alpha(1);
		if (irandom(75)=0 && static_line>1){static_line--;}
		else{
			static_line+=0.1;
		}
		if (static_line>20) then static_line=1;
		draw_set_color(c_gray);
		draw_set_halign(fa_center);
		var draw_height = 5;
		if (title!=""){
			draw_text_transformed(XX+(0.5*width), YY+(50*scale_y), title, 3*scale_x, 3*scale_y, 0);
			draw_height += (string_height(title)*3)*scale_y;
		}
		if (sub_title!=""){
			draw_text_transformed(XX+(0.5*width), YY+(50*scale_y)+draw_height, sub_title, 2*scale_x, 2*scale_y, 0);
			draw_height+=(25*scale_y) +(string_height(sub_title)*2)*scale_y;
		}
		if (body_text!=""){
			draw_text_ext(XX+(0.5*width), YY+(50*scale_y)+draw_height, string_hash_to_newline(body_text), -1, width-60);
		}
		switch (style){
			case "decorated":
				var _slate_scalex = width/sprite_get_width(spr_slate_side);
				var _slate_scaley = height/sprite_get_height(spr_slate_side);
				draw_sprite(spr_data_slate_corner_decoration, 0,XX+width - (70*_slate_scalex), YY + (7*_slate_scaley));
				break;

		}
	}

	static draw_cut = function(xx,yy, scale_x=1, scale_y=1, middle_percent=percent_cut){
		XX=xx;
		YY=yy;
		draw_sprite_part_ext(spr_data_slate,1, 0, 0, 850, 69, XX, YY, scale_x, scale_y, c_white, 1);
		draw_sprite_part_ext(spr_data_slate,1, 0, 69, 850, 683*(middle_percent/100), XX, YY+(69*scale_y), scale_x, scale_y, c_white, 1);
		draw_sprite_part_ext(spr_data_slate,1, 0, 752, 850, 98, XX, YY+(69+683*((middle_percent/100)))*scale_y, scale_x, scale_y, c_white, 1);
		width = 860*scale_x;
		height = (69+(683*(middle_percent/100))+98 )*scale_y;
		if (is_callable(inside_method)){
			inside_method();
		}		
	}

	static percent_mod_draw_cut = function(xx,yy, scale_x=1, scale_y=1, mod_edit=1){
		percent_cut = min(percent_cut+mod_edit, 100);
		if (!percent_cut) then percent_cut=0;
		draw_cut(xx,yy, scale_x, scale_y);
	}
}





function draw_building_builder(xx, yy, req_require, building_sprite){
	var clicked =false;
	draw_sprite_ext(building_sprite, 0, xx, yy, 0.5, 0.5, 0, c_white, 1);
	var image_bottom = yy+50;
	var image_middle = xx-15;
	if (obj_controller.requisition>=req_require){
		if (scr_hit(image_middle+30, image_bottom+28, image_middle+78, image_bottom+44)){
			draw_sprite_ext(spr_slate_2, 5, image_middle-10, image_bottom, 1, 1, 0, c_white, 1);
			if (scr_click_left()){
				clicked=true;								
			}
		} else {
			draw_sprite_ext(spr_slate_2, 3, image_middle-10, image_bottom, 1, 1, 0, c_white, 1);
		}
	} else {
		draw_sprite_ext(spr_slate_2, 7, image_middle-10, image_bottom, 1, 1, 0, c_white, 1);
	}
	draw_sprite_ext(spr_requisition,0,image_middle+65,image_bottom+30,1,1,0,c_white,1);
	draw_set_halign(fa_left);
	draw_text(image_middle+32, image_bottom+30, req_require);
	return clicked;
}

function DataSlateMKTwo()constructor{
	height=0;
	width=0;
	XX=0;
	YY=0;
	static entered = function(){
		return scr_hit(XX, YY, XX+width, YY+height);
	}
	static draw = function(xx,yy,x_scale=1, y_scale=1){
		XX=xx;
		YY=yy;
		height = 250*y_scale;
		width=365*x_scale;
		draw_sprite_ext(spr_slate_2, 1, xx, yy, x_scale, y_scale, 0, c_white, 1);
		draw_sprite_ext(spr_slate_2, 0, xx, yy, x_scale, y_scale, 0, c_white, 1);
		draw_sprite_ext(spr_slate_2, 2, xx, yy, x_scale, y_scale, 0, c_white, 1);
		//draw_sprite_ext(spr_slate_2, 0, xx, yy, 1, 1, 0, c_white, 1)
	}
}

function RackAndPinion(Type="forward", scale = 1) constructor{
	reverse =false;
	rack_y=0;
	rotation = 360;
	type=Type
	if (type="forward"){
		draw = function(x, y, freeze=false, Reverse=""){
			x+=19;
			if (!freeze){
				if (Reverse != ""){
					if (Reverse){
						reverse=true;
					} else {
						reverse=false;
					}
				}
				draw_sprite_ext(spr_cog_pinion, 0, x, y, 1, 1, rotation, c_white, 1)
				if (!reverse){
					rotation-=4;
				} else {
					rotation+=4;
				}
				rack_y = (75.3982236862/360)*(360-rotation);
				if (rack_y > 70){
					reverse = true;
				} else if (rack_y < 2){
					reverse = false;
				}
				draw_sprite_ext(spr_rack, 0, x-13, y-rack_y, 1, 1, 0, c_white, 1)
			} else {
				draw_sprite_ext(spr_cog_pinion, 0, x, y, 1, 1, rotation, c_white, 1)
				draw_sprite_ext(spr_rack, 0, x-13, y-rack_y, 1, 1, 0, c_white, 1)
			}		
		}
	} else if (type="backward"){
		draw = function(x, y, freeze=false, Reverse=""){
			x-=19;
			if (!freeze){
				if (Reverse != ""){
					if (Reverse){
						reverse=true;
					} else {
						reverse=false;
					}
				}
				draw_sprite_ext(spr_cog_pinion, 0, x, y, 1, 1, rotation, c_white, 1)
				if (!reverse){
					rotation+=4;
				} else {
					rotation-=4;
				}
				rack_y = (75.3982236862/360)*(360-rotation)
				if (rack_y > 70){
					reverse = true;
				} else if (rack_y < 2){
					reverse = false;
				}
				draw_sprite_ext(spr_rack, 0, x+13, y+rack_y, -1, 1, 0, c_white, 1)
			} else {
				draw_sprite_ext(spr_cog_pinion, 0, x, y, 1, 1, rotation, c_white, 1)
				draw_sprite_ext(spr_rack, 0, x+13, y+rack_y, -1, 1, 0, c_white, 1)
			}		
		}		
	}
}
function SpeedingDot(XX,YY, limit) constructor{
	bottom_limit = limit;
	stack = 0;
	yyy=YY;
	xxx=XX;
	draw = function(xx,yy){
		if (bottom_limit+(48*0.7)<stack){
			stack=0;
		}
		var top_cut = 36-stack>0 ? 36-stack :0;
		var bottom_cut = bottom_limit<stack? 46-stack-bottom_limit:46;
		draw_sprite_part_ext(spr_research_bar, 2, 0, top_cut, 200, bottom_cut, xx-105, yy+stack, 1, 0.7, c_white, 1);
		stack+=3;
	}
	current_y = function(){
		return yy+stack;
	}
}
function GlowDot() constructor{
	flash = 0
	flash_size = 5;
	flash_modifier = 1;
	one_flash_finished = true;
	draw = function(xx, yy){
		draw_set_color(c_green);
		for (var i=0; i<=flash_size;i++){
			draw_set_alpha(1 - ((1/40)*i))
			draw_circle(xx, yy, (i/3), 1);
		}
		if (flash==0){
			if (flash_size * flash_modifier<40*flash_modifier){
				flash_size+=flash_modifier;
			} else {
				flash = 1;
				flash_size-=flash_modifier;
			}
		} else {
			if (flash_size * flash_modifier > 1*flash_modifier){
				flash_size-=flash_modifier;
			}else {
				flash_size+=flash_modifier;
				flash = 0;
			}
		}
		draw_set_alpha(1);		
	}
	draw_one_flash = function(xx, yy){
		if (one_flash_finished) then exit;
		draw_set_color(c_green);
		for (var i=0; i<=flash_size;i++){
			draw_set_alpha(1 - ((1/40)*i))
			draw_circle(xx, yy, (i/3), 1);
		}
		if (flash==0){
			if (flash_size<40){
				flash_size++;
			} else {
				flash = 1;
				flash_size--;
			}
		} else {
			if (flash_size > 1){
				flash_size--;
			}else {
				flash_size++;
				flash = 0;
				one_flash_finished = true;
			}
		}		
	}
}

function ShutterButton() constructor{
	time_open = 0;
	click_timer = 0;
	Width = 315;
	Height = 90;
	XX=0;
	YY=0;
	width=0;
	height=0;
	cover_text = "";
	tooltip = "";

	/*cover_sprite = spr_shutter_button_cover;
	static make_custom_cover(){

	}*/
	right_rack = new RackAndPinion();
	left_rack = new RackAndPinion("backward");
	background = new DataSlate();
	background.inside_method = function(){
		var yy = YY;
		var xx = XX;
		var text_draw = xx+(width/2)-(string_width(text)*(3*scale)/2);
		if (scr_hit(xx, yy, xx+width, yy+height)){
			draw_rectangle_color_simple(xx, yy, xx+width, yy+height, false, CM_GREEN_COLOR, 0.35)
		}
		draw_set_halign(fa_left);
		draw_set_color(c_red);
		if (click_timer>0){
			draw_text_transformed(text_draw, yy+(24*scale), text, 3*scale, 3*scale, 0);
		} else {
			draw_text_transformed(text_draw, yy+(20*scale), text, 3*scale, 3*scale, 0);
		}
	}

	background.style = "plain";
	style = "plain";

	/*draw_with_dimensions = function(xx,yy, ,width, entered){
		draw_shutter();
	}*/
	inside_method = function(){
		var yy = YY;
		var xx = XX;
		var text_draw = xx+(width/2)-(string_width(text)*(3*scale)/2);		
		if (point_and_click([XX, YY, XX+width, YY+height]) || click_timer>0 ){
			shutter_backdrop = 7;
			click_timer++;
		} else {
			shutter_backdrop = 6;
		}
		draw_sprite_ext(spr_shutter_button, shutter_backdrop, XX, YY, scale, scale, 0, c_white, 1);
		draw_set_halign(fa_left);
		draw_set_color(c_red);
		if (click_timer>0){
			draw_text_transformed(text_draw, yy+(24*scale), text, 3*scale, 3*scale, 0);
		} else {
			draw_text_transformed(text_draw, yy+(20*scale), text, 3*scale, 3*scale, 0);
		}
	}

	draw_shutter = function(xx=-1,yy=-1,text, scale=1, entered = ""){
		if (xx != -1){
			XX=xx;
		}
		if (yy != -1){
			YY=yy;
		}
        draw_set_alpha(1);
        self.scale = scale;
        self.text = text;
        draw_set_font(fnt_40k_12);
        draw_set_halign(fa_left);
        draw_set_color(c_gray);		
		width = Width *scale;
		height = Height *scale;
		if (text=="") then entered = false;

		if (entered==""){
			entered = scr_hit(xx, yy, xx+width, yy+height);
		} else {
			entered=entered;
		}

		if (tooltip!= "" && scr_hit(xx, yy, xx+width, yy+height)){
			tooltip_draw(tooltip);
		}
		var shutter_backdrop = 6;
		if (entered || click_timer>0){
			if (time_open<24){
				time_open++;
				right_rack.draw(xx+width, yy, false, false);
				left_rack.draw(xx, yy, false, false);
			} else {
				right_rack.draw(xx+width, yy, true);
				left_rack.draw(xx, yy, true);
			}
		} else if (time_open>0){
			time_open--;
			right_rack.draw(xx+width, yy, false, true);
			left_rack.draw(xx, yy, false, true);
		} else {
			right_rack.draw(xx+width, yy, true);
			left_rack.draw(xx, yy, true);
		}

		var main_sprite = 0;
		if (time_open<2){
			draw_sprite_ext(spr_shutter_button, main_sprite, xx, yy, scale, scale, 0, c_white, 1);
			if (cover_text != ""){
				draw_set_font(fnt_Embossed_metal);
				var _cover_scale = 3*scale;
				while (string_width(cover_text) * _cover_scale > width-(5*scale)){
					_cover_scale -= 0.1;
				}
				var text_draw = xx+(width/2)-((string_width(cover_text)*(_cover_scale))/2);
				draw_set_color(c_black);
				draw_text_transformed(text_draw, yy+(_cover_scale*1), cover_text, _cover_scale, _cover_scale, 0);
			}
		} else if (time_open>=2){

			main_sprite=floor(time_open/6) + 1;

			if (style == "plain"){
				inside_method();
			} else if (style == "slate"){
				background.draw_with_dimensions(xx, yy, width, height);
			}
			draw_sprite_ext(spr_shutter_button, main_sprite, xx, yy, scale, scale, 0, c_white, 1);
		}
		draw_set_color(c_grey);
		if (click_timer>7){
			click_timer = 0;
			return true;
		} else {
			return false;
		}
	}
}




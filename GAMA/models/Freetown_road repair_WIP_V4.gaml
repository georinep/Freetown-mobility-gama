/**
* Name: Freetownroadrepair
* Based on the internal empty template. 
* Author: georinepierre
* Tags: 
*/


model Freetownroadrepair

global {
	file shape_file_buildings <- file("../includes/CBD_Buildings.shp");
	file shape_file_roads <- file("../includes/CBD_Roads.shp");
	file shape_file_bounds <- file("../includes/CBD_Bounds.shp");
	file shape_file_transit_stops <- file("../includes/CBD_stops.shp");
	file shape_file_cable_stations <- file("../includes/CBD_Cable_Station.shp");
	file shape_file_transit_morning <- file("../includes/Freetown_Morning.shp");
	file shape_file_transit_offpeak <- file("../includes/Freetown_Off Peak.shp");
	file shape_file_transit_evening <- file("../includes/Freetown_Evening.shp");
	file shape_file_transit_weekend <- file("../includes/Freetown_Weekends.shp");
	geometry shape <- envelope(shape_file_bounds);
	float step <- 10 #mn;
	date starting_date <- date("2019-09-02-00-00-00");	
	int nb_people <- 1700;
	int nb_transit_commuters <- 15000;
	int min_work_start <- 6;
	int max_work_start <- 8;
	int min_work_end <- 16; 
	int max_work_end <- 20; 
	float min_speed <- 1.0 #km / #h;
	float max_speed <- 5.0 #km / #h; 
	float destroy <- 0.02;
	int repair_time <- 0 ;
	int morning_peak_start <- 6;
	int morning_peak_end <- 10;
	int evening_peak_start <- 16;
	int evening_peak_end <- 20;
	float transit_expansion_share <- 0.0;
	list<string> traffic_periods <- ["morning","offpeak","evening","weekend"];
	map<string,float> speed_class_weights <- ["slow"::1.25,"medium"::1.0,"fast"::0.75];
	string current_traffic_period;
	list<int> weekday_days <- [1,2,3,4,5];
	list<int> weekend_days <- [6,7];
	list<string> day_names <- ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"];
	string current_day_label <- "";
	bool is_weekend <- false;
	float base_travel_time_per_km <- 12.0; // minutes per km when destruction_coeff = 1
float avg_travel_time_per_km <- 0.0;
float avg_destruction_coeff <- 0.0;
int nb_cable_commuters_actual <- 0;
int nb_regular_commuters_actual <- 0;
float actual_transit_expansion_share <- 0.0;
float baseline_avg_travel_time_per_km <- -1.0;
float baseline_avg_destruction_coeff <- -1.0;
float applied_transit_expansion_share <- -1.0;
	graph the_graph;
	
	init {
		create building from: shape_file_buildings with: [type::string(read ("NATURE"))] {
			if type="office" {
				color <- #blue ;
			} else if type = "R" {
				color <- #darkgrey;
			}
		}
		create road from: shape_file_roads ;
		create transit_segment from: shape_file_transit_morning with: [
			period::"morning",
			speed_class::(read("speed_clas") = unknown ? "medium" : string(read("speed_clas"))),
			speed_kph::(read("speed_kph") = unknown ? 0.0 : float(read("speed_kph"))),
			segment_length::(read("length_m") = unknown ? 0.0 : float(read("length_m")))
		];
		create transit_segment from: shape_file_transit_offpeak with: [
			period::"offpeak",
			speed_class::(read("speed_clas") = unknown ? "medium" : string(read("speed_clas"))),
			speed_kph::(read("speed_kph") = unknown ? 0.0 : float(read("speed_kph"))),
			segment_length::(read("length_m") = unknown ? 0.0 : float(read("length_m")))
		];
		create transit_segment from: shape_file_transit_evening with: [
			period::"evening",
			speed_class::(read("speed_clas") = unknown ? "medium" : string(read("speed_clas"))),
			speed_kph::(read("speed_kph") = unknown ? 0.0 : float(read("speed_kph"))),
			segment_length::(read("length_m") = unknown ? 0.0 : float(read("length_m")))
		];
		create transit_segment from: shape_file_transit_weekend with: [
			period::"weekend",
			speed_class::(read("speed_clas") = unknown ? "medium" : string(read("speed_clas"))),
			speed_kph::(read("speed_kph") = unknown ? 0.0 : float(read("speed_kph"))),
			segment_length::(read("length_m") = unknown ? 0.0 : float(read("length_m")))
		];
		ask transit_segment {
			if (speed_class in speed_class_weights) {
				damage_factor <- speed_class_weights[speed_class];
			} else {
				damage_factor <- 1.0;
			}
		}
		create transit_stop from: shape_file_transit_stops with: [
			stop_id::(read("stop_id") = unknown ? "" : string(read("stop_id"))),
			stop_name::(read("stop_name") = unknown ? "" : string(read("stop_name"))),
			is_cable::false
		];
		create transit_stop from: shape_file_cable_stations with: [
			stop_id::(read("stop_id") = unknown ? "" : string(read("stop_id"))),
			stop_name::(read("stop_name") = unknown ? "" : string(read("stop_name"))),
			is_cable::true
		];
		map<road,float> weights_map <- road as_map (each:: (each.destruction_coeff * each.shape.perimeter));
		the_graph <- as_edge_graph(road) with_weights weights_map;
		
		
		list<building> residential_buildings <- building where (each.type="R");
		list<building> office_buildings <- building  where (each.type="office") ;
		list<transit_stop> regular_commuter_origins <- transit_stop where (not each.is_cable);
		list<transit_stop> cable_commuter_origins <- transit_stop where (each.is_cable);
		float requested_share <- min([1.0, max([0.0, transit_expansion_share / 100.0])]);
		int nb_cable_commuters <- round(nb_transit_commuters * requested_share);
		if empty(cable_commuter_origins) {
			nb_cable_commuters <- 0;
		} else if empty(regular_commuter_origins) {
			nb_cable_commuters <- nb_transit_commuters;
		}
		nb_cable_commuters <- min([nb_transit_commuters, max([0, nb_cable_commuters])]);
		int nb_regular_commuters <- nb_transit_commuters - nb_cable_commuters;
		nb_cable_commuters_actual <- nb_cable_commuters;
		nb_regular_commuters_actual <- nb_regular_commuters;
		actual_transit_expansion_share <- (nb_transit_commuters = 0 ? 0.0 : float(nb_cable_commuters) / nb_transit_commuters);
		create people number: nb_people {
			speed <- rnd(min_speed, max_speed);
			start_work <- rnd (min_work_start, max_work_start);
			end_work <- rnd(min_work_end, max_work_end);
			living_place <- one_of(residential_buildings) ;
			working_place <- one_of(office_buildings) ;
			objective <- "resting";
			location <- any_location_in (living_place); 
		}
		if (nb_cable_commuters > 0) and (not empty(cable_commuter_origins)) {
			create transit_commuter number: nb_cable_commuters {
				speed <- rnd(min_speed, max_speed);
				start_work <- rnd (min_work_start, max_work_start);
				end_work <- rnd(min_work_end, max_work_end);
				origin_stop <- one_of(cable_commuter_origins);
				working_place <- one_of(office_buildings);
				objective <- "waiting";
				location <- origin_stop.location;
				uses_cable <- true;
			}
		}
		if (nb_regular_commuters > 0) and (not empty(regular_commuter_origins)) {
			create transit_commuter number: nb_regular_commuters {
				speed <- rnd(min_speed, max_speed);
				start_work <- rnd (min_work_start, max_work_start);
				end_work <- rnd(min_work_end, max_work_end);
				origin_stop <- one_of(regular_commuter_origins);
				working_place <- one_of(office_buildings);
				objective <- "waiting";
				location <- origin_stop.location;
				uses_cable <- false;
			}
		}
		do refresh_current_traffic_period;
		do assign_transit_impacts_to_roads;
		do update_avg_travel_time;
		do apply_transit_expansion_share;
	}
	
	reflex update_graph{
		map<road,float> weights_map <- road as_map (each:: (each.destruction_coeff * each.shape.perimeter));
		the_graph <- the_graph with_weights weights_map;
	}
	reflex repair_road when: every(repair_time #hour ) {
		road the_road_to_repair <- road with_max_of (each.destruction_coeff) ;
		ask the_road_to_repair {
			destruction_coeff <- 1.0 ;
		}
	}

	action assign_transit_impacts_to_roads {
		ask road {
				map<string,float> factors <- map<string,float>([]);
			loop period over: traffic_periods {
				factors[period] <- 1.0;
				list<transit_segment> segments <- transit_segment where (each.period = period);
				if not empty(segments) {
					transit_segment seg <- segments with_min_of (each.shape distance_to (self.shape));
					if seg != nil {
						factors[period] <- seg.damage_factor;
					}
				}
			}
			time_period_factor <- factors;
		}
	}

	action refresh_current_traffic_period {
		int day_index <- current_date.day_of_week;
		current_day_label <- day_names[max([1,day_index]) - 1];
		bool weekend <- (day_index in weekend_days);
		is_weekend <- weekend;
		if weekend {
			current_traffic_period <- "weekend";
		} else if (day_index in weekday_days) {
			int hour <- current_date.hour;
			if (hour >= morning_peak_start) and (hour < morning_peak_end) {
				current_traffic_period <- "morning";
			} else if (hour >= evening_peak_start) and (hour < evening_peak_end) {
				current_traffic_period <- "evening";
			} else {
				current_traffic_period <- "offpeak";
			}
		} else {
			current_traffic_period <- "offpeak";
		}
	}

	reflex update_traffic_period {
		do refresh_current_traffic_period;
	}

action update_avg_travel_time {
	if (length(road) > 0) {
		avg_destruction_coeff <- mean (road collect each.destruction_coeff);
		avg_travel_time_per_km <- base_travel_time_per_km * avg_destruction_coeff;
	} else {
		avg_destruction_coeff <- 0.0;
		avg_travel_time_per_km <- 0.0;
	}
	if (baseline_avg_travel_time_per_km < 0.0) or (actual_transit_expansion_share <= 0.01) {
		baseline_avg_travel_time_per_km <- avg_travel_time_per_km;
		baseline_avg_destruction_coeff <- avg_destruction_coeff;
	}
}

	reflex refresh_travel_time_metric {
		do update_avg_travel_time;
	}

	action apply_transit_expansion_share {
		list<transit_stop> cable_stops <- transit_stop where (each.is_cable);
		list<transit_stop> regular_stops <- transit_stop where (not each.is_cable);
		list<transit_commuter> commuters <- list(transit_commuter);
		int total_commuters <- length(commuters);
		if total_commuters = 0 {
			nb_cable_commuters_actual <- 0;
			nb_regular_commuters_actual <- 0;
			actual_transit_expansion_share <- 0.0;
			applied_transit_expansion_share <- 0.0;
			return;
		}
		float requested_share <- min([1.0,max([0.0,transit_expansion_share/100.0])]);
		if empty(cable_stops) {
			requested_share <- 0.0;
		} else if empty(regular_stops) {
			requested_share <- 1.0;
		}
		int target_cable <- round(total_commuters * requested_share);
		list<transit_commuter> current_cable <- commuters where (each.uses_cable);
		list<transit_commuter> current_regular <- commuters where (not each.uses_cable);
		if (target_cable > length(current_cable)) and (not empty(cable_stops)) {
			int need_more <- target_cable - length(current_cable);
			list<transit_commuter> candidates <- shuffle(current_regular);
			need_more <- min([need_more, length(candidates)]);
			loop i from: 0 to: need_more - 1 {
				ask candidates[i] {
					uses_cable <- true;
					origin_stop <- one_of(cable_stops);
					objective <- "waiting";
					the_target <- nil;
					if origin_stop != nil {
						location <- origin_stop.location;
					}
				}
			}
		} else if (target_cable < length(current_cable)) and (not empty(regular_stops)) {
			int need_less <- length(current_cable) - target_cable;
			list<transit_commuter> candidates <- shuffle(current_cable);
			need_less <- min([need_less, length(candidates)]);
			loop i from: 0 to: need_less - 1 {
				ask candidates[i] {
					uses_cable <- false;
					origin_stop <- one_of(regular_stops);
					objective <- "waiting";
					the_target <- nil;
					if origin_stop != nil {
						location <- origin_stop.location;
					}
				}
			}
		}
		nb_cable_commuters_actual <- length(transit_commuter where (each.uses_cable));
		nb_regular_commuters_actual <- total_commuters - nb_cable_commuters_actual;
		actual_transit_expansion_share <- total_commuters = 0 ? 0.0 : nb_cable_commuters_actual / total_commuters;
		applied_transit_expansion_share <- requested_share;
	}

	reflex sync_transit_expansion {
		float requested_share <- min([1.0,max([0.0,transit_expansion_share/100.0])]);
		if empty(transit_stop where (each.is_cable)) {
			requested_share <- 0.0;
		}
		if abs(requested_share - applied_transit_expansion_share) > 0.01 {
			do apply_transit_expansion_share;
		}
	}
}

species building {
	string type; 
	rgb color <- #gray  ;
	
	aspect base {
		draw shape color: color ;
	}
}

species road  {
	float destruction_coeff <- rnd(1.0,2.0) max: 2.0;
	int colorValue <- int(255*(destruction_coeff - 1)) update: int(255*(destruction_coeff - 1));
	rgb color <- rgb(min([255, colorValue]),max ([0, 255 - colorValue]),0)  update: rgb(min([255, colorValue]),max ([0, 255 - colorValue]),0) ;
	map<string,float> time_period_factor <- ["morning"::1.0,"offpeak"::1.0,"evening"::1.0,"weekend"::1.0];
	
	aspect base {
		draw shape color: color ;
	}
}

species transit_stop {
	string stop_id <- "";
	string stop_name <- "";
	bool is_cable <- false;
	
	aspect base {
		draw circle(4) color: (is_cable ? rgb(0,255,255) : #red) border: #white;
	}
}

species transit_segment {
	string period <- "offpeak";
	string speed_class <- "medium";
	float speed_kph <- 0.0;
	float segment_length <- 0.0;
	float damage_factor <- 1.0;

	aspect base {
		rgb seg_color <- (speed_class = "slow" ? #red : (speed_class = "fast" ? #green : #yellow));
		draw shape color: seg_color width: 1 depth: 0.5;
	}
}

species people skills:[moving] {
	rgb color <- #yellow ;
	building living_place <- nil ;
	building working_place <- nil ;
	int start_work ;
	int end_work  ;
	string objective ; 
	point the_target <- nil ;
		
	reflex time_to_work when: (not is_weekend) and (current_date.hour = start_work) and (objective = "resting"){
		objective <- "working" ;
		the_target <- any_location_in (working_place);
	}
		
	reflex time_to_go_home when: (not is_weekend) and (current_date.hour = end_work) and (objective = "working"){
		objective <- "resting" ;
		the_target <- any_location_in (living_place); 
	} 
	
	reflex weekend_home_reset when: is_weekend and (objective != "resting" or the_target != nil){
		objective <- "resting";
		the_target <- nil;
		location <- any_location_in(living_place);
	}
	 
	reflex move when: (not is_weekend) and (the_target != nil) {
		path path_followed <- goto(target:the_target, on:the_graph, return_path: true);
		list<geometry> segments <- path_followed.segments;
		loop line over: segments {
			float dist <- line.perimeter;
			ask road(path_followed agent_from_geometry line) { 
				float tod_factor <- time_period_factor[current_traffic_period];
				destruction_coeff <- destruction_coeff + (destroy * dist / shape.perimeter) * tod_factor;
			}
		}
		if the_target = location {
			the_target <- nil ;
		}
	}
	
	aspect base {
		if not is_weekend {
			draw circle(4) color: color border: #black;
		}
	}
}

species transit_commuter skills:[moving] {
	rgb color <- #orange;
	transit_stop origin_stop <- nil;
	building working_place <- nil;
	int start_work;
	int end_work;
	string objective <- "waiting";
	point the_target <- nil;
	float speed <- 3.0 #km / #h;
	bool uses_cable <- false;
	
	reflex go_to_work when: (not is_weekend) and (current_date.hour = start_work) and (objective = "waiting") {
		objective <- "working";
		the_target <- any_location_in(working_place);
	}
	
	reflex return_to_stop when: (not is_weekend) and (current_date.hour = end_work) and (objective = "working") {
		objective <- "waiting";
		if origin_stop != nil {
			the_target <- origin_stop.location;
		}
	}
	
	reflex weekend_reset when: is_weekend and (objective != "waiting" or the_target != nil) {
		objective <- "waiting";
		the_target <- nil;
		if origin_stop != nil {
			location <- origin_stop.location;
		}
	}
	
	reflex move when: (not is_weekend) and (the_target != nil) {
		path path_followed <- goto(target: the_target, on: the_graph, return_path: true);
		list<geometry> segments <- path_followed.segments;
		loop line over: segments {
			float dist <- line.perimeter;
			ask road(path_followed agent_from_geometry line) {
				float tod_factor <- time_period_factor[current_traffic_period];
				destruction_coeff <- destruction_coeff + (destroy * dist / shape.perimeter) * tod_factor;
			}
		}
		if the_target = location {
			the_target <- nil;
		}
	}
	
		aspect base {
		rgb disp_color <- (uses_cable ? rgb(0,255,255) : #orange);
			draw circle(4) color: disp_color border: #black;
		}
}

experiment road_traffic type: gui {
	parameter "Shapefile for the buildings:" var: shape_file_buildings category: "GIS" ;
	parameter "Shapefile for the roads:" var: shape_file_roads category: "GIS" ;
	parameter "Shapefile for the bounds:" var: shape_file_bounds category: "GIS" ;
	parameter "Shapefile for transit stops:" var: shape_file_transit_stops category: "GIS" ;
	parameter "Number of people agents" var: nb_people category: "People" ;
	parameter "Number of transit commuters" var: nb_transit_commuters category: "People" ;
	parameter "Earliest hour to start work" var: min_work_start category: "People" min: 2 max: 8;
	parameter "Latest hour to start work" var: max_work_start category: "People" min: 8 max: 12;
	parameter "Earliest hour to end work" var: min_work_end category: "People" min: 12 max: 16;
	parameter "Latest hour to end work" var: max_work_end category: "People" min: 16 max: 23;
	parameter "minimal speed" var: min_speed category: "People" min: 0.1 #km/#h ;
	parameter "maximal speed" var: max_speed category: "People" max: 10 #km/#h;
	parameter "Value of destruction when a people agent takes a road" var: destroy category: "Road" ;
	parameter "Number of hours between two road repairs" var: repair_time category: "Road" ;
	parameter "Morning peak start hour" var: morning_peak_start category: "Traffic" min: 0 max: 23;
	parameter "Morning peak end hour" var: morning_peak_end category: "Traffic" min: 1 max: 24;
	parameter "Evening peak start hour" var: evening_peak_start category: "Traffic" min: 0 max: 23;
	parameter "Evening peak end hour" var: evening_peak_end category: "Traffic" min: 1 max: 24;
	parameter "Transit expansion share (%)" var: transit_expansion_share category: "Transit expansion" min: 0 max: 100;
	
	output {
		display city_display type:3d background: #black {
			species building aspect: base ;
			species road aspect: base ;
			species transit_stop aspect: base ;
			species people aspect: base ;
				species transit_commuter aspect: base ;
				graphics "time" {
					draw current_day_label color: #white font: font("Helvetica", 20, #bold)
						 at: {world.shape.width*0.9, world.shape.height*0.63};
					draw string(current_date.hour) + "h " + string(current_date.minute) + "m"
						 color: #white font: font("Helvetica", 25, #italic)
						 at: {world.shape.width*0.9, world.shape.height*0.57};
					float avg_time_display <- round(avg_travel_time_per_km * 100) / 100.0;
					float avg_destruction_display <- round(avg_destruction_coeff * 100) / 100.0;
					float baseline_time_display <- (baseline_avg_travel_time_per_km < 0.0 ? avg_time_display : round(baseline_avg_travel_time_per_km * 100) / 100.0);
					float baseline_destruction_display <- (baseline_avg_destruction_coeff < 0.0 ? avg_destruction_display : round(baseline_avg_destruction_coeff * 100) / 100.0);
					float delta_time <- avg_travel_time_per_km - (baseline_avg_travel_time_per_km < 0.0 ? avg_travel_time_per_km : baseline_avg_travel_time_per_km);
					float delta_destruction <- avg_destruction_coeff - (baseline_avg_destruction_coeff < 0.0 ? avg_destruction_coeff : baseline_avg_destruction_coeff);
					float delta_time_display <- round(delta_time * 100) / 100.0;
					float delta_destruction_display <- round(delta_destruction * 100) / 100.0;
					draw "Avg travel time (1 km): " + string(avg_time_display) + " min"
						 color: #white font: font("Helvetica", 10, #plain)
						 at: {world.shape.width*0.9, world.shape.height*0.5};
					draw "Baseline (0% expansion): " + string(baseline_time_display) + " min"
						 color: #white font: font("Helvetica", 10, #plain)
						 at: {world.shape.width*0.9, world.shape.height*0.47};
					draw "Δ travel time vs baseline: " + string(delta_time_display) + " min"
						 color: (delta_time_display > 0 ? #red : #green) font: font("Helvetica", 10, #plain)
						 at: {world.shape.width*0.9, world.shape.height*0.44};
					draw "Mean destruction coeff: " + string(avg_destruction_display)
						 color: #white font: font("Helvetica", 10, #plain)
						 at: {world.shape.width*0.9, world.shape.height*0.41};
					draw "Baseline destruction coeff: " + string(baseline_destruction_display)
						 color: #white font: font("Helvetica", 10, #plain)
						 at: {world.shape.width*0.9, world.shape.height*0.38};
					draw "Δ destruction vs baseline: " + string(delta_destruction_display)
						 color: (delta_destruction_display > 0 ? #red : #green) font: font("Helvetica", 10, #plain)
						 at: {world.shape.width*0.9, world.shape.height*0.35};
				}

				overlay position: { 5#px, 5#px } size: { 130#px, 190#px } background: #black transparency: 0.0 border: #white {
					rgb text_color <- #white;
					float y <- 30#px;
					draw "Building Usage" at: { 40#px, y } color: text_color font: font("Helvetica", 18, #bold) perspective: false;
					y <- y + 25#px;
					draw square(12#px) at: { 20#px, y } color: #blue border: #white;
					draw "Office" at: { 45#px, y + 4#px } color: text_color font: font("Helvetica", 14, #plain) perspective: false;
					y <- y + 22#px;
					draw square(12#px) at: { 20#px, y } color: #darkgrey border: #white;
					draw "Residential" at: { 45#px, y + 4#px } color: text_color font: font("Helvetica", 14, #plain) perspective: false;

					y <- y + 35#px;
					draw "People" at: { 40#px, y } color: text_color font: font("Helvetica", 18, #bold) perspective: false;
					y <- y + 25#px;
					draw square(12#px) at: { 20#px, y } color: #yellow border: #white;
					draw "Residents" at: { 45#px, y + 4#px } color: text_color font: font("Helvetica", 14, #plain) perspective: false;
					y <- y + 22#px;
					draw square(12#px) at: { 20#px, y } color: #orange border: #white;
					draw "Commuters" at: { 45#px, y + 4#px } color: text_color font: font("Helvetica", 14, #plain) perspective: false;
					y <- y + 22#px;
					draw square(12#px) at: { 20#px, y } color: rgb(0,255,255) border: #white;
					draw "Cable commuters" at: { 45#px, y + 4#px } color: text_color font: font("Helvetica", 14, #plain) perspective: false;
					y <- y + 30#px;
					draw "Transit Expansion" at: { 40#px, y } color: text_color font: font("Helvetica", 18, #bold) perspective: false;
					y <- y + 22#px;
					float disp_share <- round(actual_transit_expansion_share * 1000) / 10.0;
					draw "Cable share: " + string(disp_share) + "%" at: { 20#px, y } color: text_color font: font("Helvetica", 14, #plain) perspective: false;
					y <- y + 20#px;
					draw "Cable commuters: " + string(nb_cable_commuters_actual) at: { 20#px, y } color: text_color font: font("Helvetica", 14, #plain) perspective: false;
					y <- y + 20#px;
					draw "Other commuters: " + string(nb_regular_commuters_actual) at: { 20#px, y } color: text_color font: font("Helvetica", 14, #plain) perspective: false;
				}
			}
		monitor "Time of day (hours)" value: (current_date.hour + (current_date.minute / 60.0));
		monitor "Day of week (ISO 1=Mon)" value: current_date.day_of_week;
		monitor "Active traffic period" value: current_traffic_period;
		monitor "Cable commuter share (%)" value: actual_transit_expansion_share * 100.0;
		monitor "Cable commuters count" value: nb_cable_commuters_actual;
		monitor "Other commuters count" value: nb_regular_commuters_actual;
			display chart_display refresh: every(10#cycles)  type: 2d { 
			chart "Road Status" type: series size: {1, 0.5} position: {0, 0} {
				data "Mean road destruction" value: mean (road collect each.destruction_coeff) style: line color: #green ;
				data "Max road destruction" value: road max_of each.destruction_coeff style: line color: #red ;
			}
				chart "Agent Objectives" type: pie style: exploded size: {1, 0.5} position: {0, 0.5}{
					data "Residents working" value: people count (each.objective="working") color: #yellow ;
					data "Residents resting" value: people count (each.objective="resting") color: #purple ;
					data "Commuters working" value: transit_commuter count (each.objective="working") color: #orange ;
					data "Commuters waiting" value: transit_commuter count (each.objective="waiting") color: #magenta ;
				}
			}
	}
}

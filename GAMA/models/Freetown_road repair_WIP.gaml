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
	geometry shape <- envelope(shape_file_bounds);
	float step <- 10 #mn;
	date starting_date <- date("2019-09-01-00-00-00");	
	int nb_people <- 1700;
	int nb_transit_commuters <- 3600;
	int min_work_start <- 6;
	int max_work_start <- 8;
	int min_work_end <- 16; 
	int max_work_end <- 20; 
	float min_speed <- 1.0 #km / #h;
	float max_speed <- 5.0 #km / #h; 
	float destroy <- 0.02;
	int repair_time <- 2 ;
	graph the_graph;
	
	init {
		create building from: shape_file_buildings with: [type::string(read ("NATURE"))] {
			if type="office" {
				color <- #blue ;
			}
		}
		create road from: shape_file_roads ;
		create transit_stop from: shape_file_transit_stops with: [
			stop_id::(read("stop_id") = unknown ? "" : string(read("stop_id"))),
			stop_name::(read("stop_name") = unknown ? "" : string(read("stop_name")))
		];
		map<road,float> weights_map <- road as_map (each:: (each.destruction_coeff * each.shape.perimeter));
		the_graph <- as_edge_graph(road) with_weights weights_map;
		
		
		list<building> residential_buildings <- building where (each.type="R");
		list<building> office_buildings <- building  where (each.type="office") ;
		list<transit_stop> commuter_origins <- list(transit_stop);
		create people number: nb_people {
			speed <- rnd(min_speed, max_speed);
			start_work <- rnd (min_work_start, max_work_start);
			end_work <- rnd(min_work_end, max_work_end);
			living_place <- one_of(residential_buildings) ;
			working_place <- one_of(office_buildings) ;
			objective <- "resting";
			location <- any_location_in (living_place); 
		}
		if not (empty(commuter_origins)) {
			create transit_commuter number: nb_transit_commuters {
				speed <- rnd(min_speed, max_speed);
				start_work <- rnd (min_work_start, max_work_start);
				end_work <- rnd(min_work_end, max_work_end);
				origin_stop <- one_of(commuter_origins);
				working_place <- one_of(office_buildings);
				objective <- "waiting";
				location <- origin_stop.location;
			}
		}
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
	
	aspect base {
		draw shape color: color ;
	}
}

species transit_stop {
	string stop_id <- "";
	string stop_name <- "";
	
	aspect base {
		draw circle(4) color: #red border: #white;
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
		
	reflex time_to_work when: current_date.hour = start_work and objective = "resting"{
		objective <- "working" ;
		the_target <- any_location_in (working_place);
	}
		
	reflex time_to_go_home when: current_date.hour = end_work and objective = "working"{
		objective <- "resting" ;
		the_target <- any_location_in (living_place); 
	} 
	 
	reflex move when: the_target != nil {
		path path_followed <- goto(target:the_target, on:the_graph, return_path: true);
		list<geometry> segments <- path_followed.segments;
		loop line over: segments {
			float dist <- line.perimeter;
			ask road(path_followed agent_from_geometry line) { 
				destruction_coeff <- destruction_coeff + (destroy * dist / shape.perimeter);
			}
		}
		if the_target = location {
			the_target <- nil ;
		}
	}
	
	aspect base {
		draw circle(5) color: color border: #black;
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
	
	reflex go_to_work when: current_date.hour = start_work and objective = "waiting" {
		objective <- "working";
		the_target <- any_location_in(working_place);
	}
	
	reflex return_to_stop when: current_date.hour = end_work and objective = "working" {
		objective <- "waiting";
		if origin_stop != nil {
			the_target <- origin_stop.location;
		}
	}
	
	reflex move when: the_target != nil {
		path path_followed <- goto(target: the_target, on: the_graph, return_path: true);
		list<geometry> segments <- path_followed.segments;
		loop line over: segments {
			float dist <- line.perimeter;
			ask road(path_followed agent_from_geometry line) {
				destruction_coeff <- destruction_coeff + (destroy * dist / shape.perimeter);
			}
		}
		if the_target = location {
			the_target <- nil;
		}
	}
	
	aspect base {
		draw circle(5) color: color border: #black;
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
	
	output {
		display city_display type:3d background: #black {
			species building aspect: base ;
			species road aspect: base ;
			species transit_stop aspect: base ;
			species people aspect: base ;
			species transit_commuter aspect: base ;
			graphics "time" {
				draw string(current_date.hour) + "h" + string(current_date.minute) + "m"
					 color: #white font: font("Helvetica", 25, #italic)
					 at: {world.shape.width*0.9, world.shape.height*0.55};
			}
		}
		monitor "Time of day (hours)" value: (current_date.hour + (current_date.minute / 60.0));
		display chart_display refresh: every(10#cycles)  type: 2d { 
			chart "Road Status" type: series size: {1, 0.5} position: {0, 0} {
				data "Mean road destruction" value: mean (road collect each.destruction_coeff) style: line color: #green ;
				data "Max road destruction" value: road max_of each.destruction_coeff style: line color: #red ;
			}
			chart "Agent Objectives" type: pie style: exploded size: {1, 0.5} position: {0, 0.5}{
				data "Residents working" value: people count (each.objective="working") color: #magenta ;
				data "Residents resting" value: people count (each.objective="resting") color: #blue ;
				data "Transit working" value: transit_commuter count (each.objective="working") color: #orange ;
				data "Transit waiting" value: transit_commuter count (each.objective="waiting") color: #yellow ;
			}
		}
	}
}

/**
* Name: FreetownV23
* Based on the internal empty template. 
* Author: georinepierre
* Tags: 
*/


model Freetown_V2_3
global {
   // --- Load shapefiles ---
   file shape_file_buildings <- file("../includes/CBD_Buildings.shp");
   file shape_file_roads <- file("../includes/CBD_Roads.shp");
   file shape_file_stops <- file("../includes/CBD_Stops.shp");
   file shape_file_extendedstops <- file("../includes/Freetown_Stops.shp");
   file shape_file_morningtraffic <- file("../includes/Freetown_Morning.shp");
   file shape_file_eveningtraffic <- file("../includes/Freetown_Evening.shp");
   file shape_file_weekendstraffic <- file("../includes/Freetown_Weekends.shp");
   file shape_file_offpeaktraffic <- file("../includes/Freetown_Off Peak.shp");
   file shape_file_routes <- file("../includes/Freetown_Transit.shp");
   file shape_file_bounds <- file("../includes/CBD_Bounds.shp");
   // --- Define map extent based on bounds ---
   geometry shape <- envelope(shape_file_bounds);
   init {
       create building from: shape_file_buildings with: [type::string(read ("NATURE"))];
       create road from: shape_file_roads;
       create stops from: shape_file_stops;
       create extendedstops from: shape_file_extendedstops;
       create morningtraffic from: shape_file_morningtraffic;
       create morningtraffic from: shape_file_eveningtraffic;
       create morningtraffic from: shape_file_weekendstraffic;
       create morningtraffic from: shape_file_offpeaktraffic;         
       create routes from: shape_file_routes;
       create boundary from: shape_file_bounds;
   }
}
// --- Species for visualization ---
species building {
    string type;
    rgb color <- #gray;
    
    init {
        if (type = "office") {
            color <- #blue;
        } else if (type = "r") {
            color <- #gray;
        } else if (type = "college" or type = "school") {
            color <- #purple;
        } else if (type = "commercial") {
            color <- #orange;
        } else if (type = "park") {
            color <- #green;
        } else if (type = "tourism" or type = "tourism") {
            color <- #yellow;
        } else if (type = "hotel" or type = "hotel") {
            color <- #brown;
        } else if (type = "restaurant" or type = "restaurant") {
            color <- #orange;
        } else if (type = "nightlife" or type = "nightlife") {
            color <- #orange;
        } else if (type = "worship" or type = "worship") {
            color <- #teal;
        }
    }

    aspect base {
        draw shape color: color;
    }
}

// --- Other species ---
species road {
    aspect base {
        draw shape color: #black width: 1;
    }
}

species boundary {
    aspect base {
        draw shape color: #white border: #white;
    }
}

species stops {
    aspect base {
        draw shape color: #red border: #red;
    }
}

species extendedstops {
    aspect base {
        draw shape color: #red border: #red;
    }
}

species morningtraffic {
    aspect base {
        draw shape color: #green width: 2;
    }
}

species eveningtraffic {
    aspect base {
        draw shape color: #purple width: 2;
    }
}

species weekendstraffic {
    aspect base {
        draw shape color: #yellow width: 2;
    }
}

species offpeaktraffic {
    aspect base {
        draw shape color: #teal width: 2;
    }
}

species routes {
    aspect base {
        draw shape color: #orange width: 2;
    }
}

// --- Experiment for visualization ---
experiment shapefile_viewer type: gui {
   output {
       display map_display type: 3d {
           species boundary aspect: base;
           species road aspect: base;
           species building aspect: base;
           species stops aspect: base;
           species extendedstops aspect: base;
           species morningtraffic aspect: base;
           species eveningtraffic aspect: base;
           species weekendstraffic aspect: base;
           species offpeaktraffic aspect: base;
           species routes aspect: base;
       }
   }
}

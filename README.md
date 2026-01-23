# Freetown-mobility-gama
Development for an agent-based model pilot study in GAMA simulating urban mobility scenarios using GIS and General Transit Feed Specification (GTFS) mobility data in Freetown, Sierra Leone. <br><br>

![Example Image](https://github.com/georinep/Freetown-mobility-gama/blob/main/img/abm-before-after-updated.png) <br><br>

**Overview**

This project develops a pilot pedestrian mobility simulation for Freetown’s Central Business District (CBD) using GIS data and the GAMA agent-based modeling platform. It is designed as a decision-support tool to help municipal planners evaluate how transit expansion (including a proposed cable car by the City), housing densification, and commuter growth may impact pedestrian movement through 2028.

The model simulates daily pedestrian flows across different times of day, identifies streets likely to experience increased pedestrian pressure, and supports scenario testing under data and budget constraints typical of resource-limited cities. The pilot study focuses on the mobility behavior of professional workers, including those who both live and work in the CBD and those who commute into the CBD from designated origin–destination pairs linking residential areas, office locations, and transit nodes.  <br><br>

**Purpose**

The tool helps planners:

-Compare current and future pedestrian congestion patterns

-Identify streets suitable for pedestrianization or traffic calming

-Explore impacts of cable car adoption, densification, and commuter growth

-Support evidence-based planning with limited data availability <br><br>


![Example Image 2](https://github.com/georinep/Freetown-mobility-gama/blob/main/img/abm%20after%20tablet.gif) <br> (Above: Pedestrian Mobility Impact & Planning Decision Support Tool User-Interace Pilot) <br><br>

![Example Image 3](https://github.com/georinep/Freetown-mobility-gama/blob/main/img/1%20final%20abm%20after.gif) <br> (Above: GAMA Project Model Pedestrian Mobility Simulation) <br><br> 

The model identifies streets in Freetown’s CBD likely to experience sustained and intensified pedestrian activity, highlighting corridors that may benefit from pedestrianization, traffic calming, or road space reallocation. This focus is particularly relevant in Freetown, where pedestrian congestion often overlaps with informal street vending on vehicle-oriented roads, creating mobility constraints and safety risks. The simulation integrates GIS data on road networks, building uses, public transport routes, and the proposed cable car station location, with land use simplified into residential and office functions and transit inputs capturing both formal and informal services. Time-of-day transit speeds (morning peak, off-peak, evening peak), derived from GTFS-based analysis, reflect daily variation in mobility conditions. 

Pedestrians are modeled as agents with origins, destinations, and daily schedules, including residents working locally and commuters arriving via transit or the proposed cable car. Pedestrian congestion is estimated using a weighted road graph, where each street segment accumulates stress based on pedestrian use, walking distance, and time-specific transit speed classes (slow, medium, fast). Slower transit conditions increase pedestrian stress more strongly, linking observed congestion to simulated foot traffic. Outputs are visualized as red (high impact) to green (low imapct) maps and summarized through average walking travel time per kilometer, enabling comparison between baseline and future scenarios under transit expansion and urban densification. <br><br>


**Repository Structure**
├── gama/
├── dashboard/
├── img/
└── README.md <br><br>


**GAMA/**

Contains the core GAMA simulation model.

-GAMA project files defining agents, behaviors, and scenarios

-Includes/ folder with GIS input data (roads, buildings, land use, transit routes, transit stops, cable car station) <br><br>


**dashboard/**

Contains a web-based UX/UI prototype for visualizing simulation outputs.

-Interactive interface for exploring scenarios and time-of-day results

-Includes zipped dashboard assets and zipped GeoJSON files for mapping <br><br>


**img/**

-Image outputs and study references.

-Scenario maps and visualization outputs <br><br>


**Citation**

Taillandier, P., et al. (2019). Building, composing and experimenting complex spatial models with the GAMA platform. Geoinformatica, 23(2), 299–322. https://doi.org/10.1007/s10707-018-00339-6


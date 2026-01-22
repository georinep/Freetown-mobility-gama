# Freetown-mobility-gama
Development for an agent-based model pilot study in GAMA simulating urban mobility scenarios using GIS and GTFS mobility data in Freetown, Sierra Leone.
Urban Mobility ABM in GAMA. 

![Example Image](https://github.com/georinep/Freetown-mobility-gama/blob/main/img/abm-before-after-updated.png)

Overview

This project develops a pilot pedestrian mobility simulation for Freetown’s Central Business District (CBD) using GIS data and the GAMA agent-based modeling platform. It is designed as a decision-support tool to help municipal planners evaluate how transit expansion (including a proposed cable car), housing densification, and commuter growth may impact pedestrian movement through 2028.

The model simulates daily pedestrian flows across different times of day, identifies streets likely to experience increased pedestrian pressure, and supports scenario testing under data and budget constraints typical of resource-limited cities.

Repository Structure
├── gama/
├── dashboard/
├── img/
└── README.md


(**GAMA/**)

Contains the core GAMA simulation model.

-GAMA project files defining agents, behaviors, and scenarios

-includes/ folder with GIS input data (roads, buildings, land use, transit routes, cable car stations)


(**dashboard/**)

A web-based UX/UI prototype for visualizing simulation outputs.

-Interactive interface for exploring scenarios and time-of-day results

-Includes zipped dashboard assets and zipped GeoJSON files for mapping


(**img/**)

-Image outputs and study references.

-Scenario maps and visualization outputs


(**Purpose**)

The tool helps planners:

-Compare current and future pedestrian congestion patterns

-Identify streets suitable for pedestrianization or traffic calming

-Explore impacts of cable car adoption, densification, and commuter growth

-Support evidence-based planning with limited data availability


(**Citation**)

Taillandier, P., et al. (2019). Building, composing and experimenting complex spatial models with the GAMA platform. Geoinformatica, 23(2), 299–322. https://doi.org/10.1007/s10707-018-00339-6


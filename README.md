# Freetown-mobility-gama
Development for an agent-based model pilot study in GAMA simulating urban mobility scenarios using GIS and GTFS mobility data in Freetown, Sierra Leone.
Urban Mobility ABM in GAMA
This repository contains an Agent-Based Model (ABM) built using the GAMA platform to simulate urban mobility scenarios in Freetown. The model leverages GIS datasets, GTFS transit feeds, and derived travel delay analysis/fare data to explore potential scenarios such as transit expansion, traffic congestion, parking regulation, and street vendor management.

Potential Project Structure
urban-mobility-abm-gama/ │ ├── data/ - Raw and processed datasets │ ├── gis/ - Shapefiles, geopackages, and raster GIS data │ ├── gtfs/ - GTFS transit feed files (routes, shapes, stops, stop times, trips, frequencies, fare attributes, etc.) │ └── derived/ - Traffic delay analysis, fare matrices, etc. │ ├── model/ - GAMA models and sub-models │ ├── main.gaml │ └── includes/ │ ├── scripts/ - Data preprocessing scripts ├── outputs/ - Model outputs and scenario results ├── README.txt └── .gitignore

Data Animation
GTFS data was animated using Python scripts in the scripts/ directory.
To process: python scripts/gtfs_animation.py
Requirements: - geopandas - pandas - matplotlib - ffmpeg
Model Overview - TBD

Potential ABM can simulate interactions between:
Agents: commuters: students, workers, vendors, tourists, etc.
Environment: roads, public transit, points of interest, land use
Scenarios (TBD): transit expansion, parking regulation, traffic congestion, street vendor management
Built using the GAMA Platform: https://gama-platform.org/
Running the Model - TBD
Open GAMA
Load model/main.gaml
Select your scenario from the GUI
Run the simulation
Outputs will be saved in /outputs/
Scenarios (in model/includes/scenarios/) - TBD


# Freetown-mobility-gama
Development for an agent-based model pilot study in GAMA simulating urban mobility scenarios using GIS and GTFS mobility data in Freetown, Sierra Leone.
Urban Mobility ABM in GAMA. 

Project Deck Update: https://docs.google.com/presentation/d/1fF-7L6AmL62-9QmVp_K_17wNbMRJTMtMSySmYq8-Mtc/edit?usp=sharing

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


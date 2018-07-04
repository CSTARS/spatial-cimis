#! /bin/shell 

# The CIMIS GOES USER
CG_USER=cimis
CG_BASE=/home/cimis
# This is a default file for running the cg system
CG_GRASS_ADDON_PATH=${CG_BASE}/grass/bin:${CG_BASE}/grass/scripts
CG_GRASS_ADDON_ETC=${CG_BASE}/grass/etc

# GRASS Database Information
CG_GISDBASE=${CG_BASE}/gdb
CG_MAPSET=${CG_USER}
CG_ZIPCODE_DB=${CG_BASE}/cimis.db

# GOES15
CG_GOES_LOC=${CG_GISDBASE}/GOES15

# CA Daily Vis Information
CA_DAILY_VIS_LOC=${CG_GISDBASE}/ca_daily_vis
CA_DAILY_VIS_INTERVAL=15



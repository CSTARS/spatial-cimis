#ET API
#et.api:=http://et.water.ca.gov/
# Internally, dwr uses a different server
et.api:=http://dwrnpmsweb0121.ad.water.ca.gov:7180/api

# GOES16
goes.loc:=goes16

# CA Solar
solar.loc:=solar
solar.proj.method:=lanczos
# Can set region to default '-d' or explicitly
#solar.region:=-d
solar.region:=-d n=512000 s=-768000 e=640000 w=-512000 res=500

#CIMIS
cimis.loc:=cimis

import.wld:=501.004322\n0\n0\n-501.004322\n-3871009.893933\n3969206.741045

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

# For various bands, we need to have a set of sizes.  This affects the crop size, and the imports
B1.size:=1km
B2.size:=500m
B3.size:=1km
B4.size:=2km
B5.size:=1km
B6.size:=2km
B7.size:=2km
B8.size:=2km
B9.size:=2km
B10.size:=2km
B11.size:=2km
B12.size:=2km
B13.size:=2km
B14.size:=2km
B15.size:=2km
B16.size:=2km

#PGM Import parameters
500m.wld:=501.004322\n0\n0\n-501.004322\n-3871009.893933\n3969206.741045
1km.wld:=1002.008644\n0\n0\n-1002.008644\n-3871260.396094\n3969457.243206
2km.wld:=2004.017288\n0\n0\n-2004.017288\n-3870759.391772\n3968956.238884

# These are the cropping values vs band size.
500m.crop.ca:=2460x1912!+3121+2925
1km.crop.ca:=1231x957!+1560+1462
2km.crop.ca:=616x479!+780+731

# Default region parameters for each band
region:=-d n=512000 s=-768000 e=640000 w=-512000

500m.region:=${region} res=500
1km.region:=${region} res=1000
2km.region:=${region} res=2000

# Handy functions
band=$(lastword $(subst -, ,$(1:.pgm=)))
size=${$(call band,$1).size}
wld=${$(call size,$1).wld}
region=${$(call size,$1).region}

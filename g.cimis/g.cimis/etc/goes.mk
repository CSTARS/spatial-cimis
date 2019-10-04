#! /usr/bin/make -f

define pod

=pod

=head1 SYNOPSIS

  g.cimis sec=goes cmd=<command> [args=files=I<files>] [arg=mapsets=I<mapsets>]
  where command is one of: import, goes_to_solar, solar

This g.cimis section (a Makefile) is used import GOES-1[67] data into a grass database, and potentially
project it into the solar mapset, and run solar calculations.  It can work on either mapsets, or a list of files, or a
combination of both.  It should work for multiple mapsets of files spanning multiple days.  It will also work
specifing files one at a time, as in a incrontab.

=head1 COMMANDS

=over 4

=item B<cmd=info>

Show this information page

=item B<cmd=import>

Import all specified I<files> into the goes location.  The files are imported into mapsets corresponding to each day, and
named at the time of acqusition.  The I<mapsets> has no effect in this case.  Also, files will be imported regardless of whether
they will be used in any subsequent solar calculation.  That means nightime files will be included.

=item B<cmd=goes_to_solar>

Project all rasters in the goes location into an equivalent structure in the I<solar> location.  Any specified I<files> will
first be imported, if they have not yet been.  Both I<mapsets> and I<files> parameters can be specified. 

=item B<cmd=solar>

Compute all solar parameters for all rasters specified by either the I<mapsets> or I<files> parameters.  Files will first be
imported and projected into the solar space.  The solar calculation expects that it knows all the files up to the latest one.
Running this command where some files/rasters are missing will cause errors in the calculation, as the algorythm needs a proper
order for the files.  The I<solar> command can be modified with the B<add-sunset> and B<solar-location> parameters as described
below.  Note, that unlike the I<import> command, the I<solar> command will not import night-time (unused) files.

=back

=head1 OPTIONS

=over 4

=item <-n>

This option is specified in the C<g.cimis --help>.  It will cause the operations that would be performed, to be written
to stdout.  This is a good debugging tool.  As each section in g.cimis is simply a makefile, this is equivalant
to C<make -n>.

=item B<arg=files="list of files...">

This is a space separated list of the GOES.pgm files that are ready for import into the system.  Please note that this
program only imports pgm files that are in the very specific cookie-cutter regions used in cimis processing.  These are
specified in the C<configure.mk> file, in the extension.  

=item B<arg=mapsets="list of mapsets...">

This is a space separated list of mapsets within the B<goes> location.  Every matching raster (glob pattern=????PST-B2)
will be included in the subsequent command.  

=item B<arg=add_sunset=1>

Only used for the B<solar> command, if the I<add_sunset> option is included, then all mapsets will be checked that a complete
days calculations have been performed, including the final sunset (ssetr-G) total radiance example.  This is done, by checking
the latest raster time for each mapset, and adding a sunset calculation if they are all in the day.  This should be added when
you want to calculate previously collected data.  It should b<Not> be used in an incrontab type process.

=item B<arg=solar_mapsets=1>

B<THIS IS NOT YET IMPLEMENTED> This parameter will only check for files in the B<solar> location, and not back to the B<goes>
location.  This is useful if the original B<goes> data is somehow missing or removed.  You can, and probably should use the
B<add_sunset> parameter as well.

=back

=cut

endef

ifndef configure.mk
include configure.mk
endif

ifndef solar_functions.mk
include solar_functions.mk
endif

goes.mk:=1


# Handy oneline functions
f_fn=$(notdir $(basename $1))
f_mapset=$(word 1,$(subst T, ,$(call f_fn,$1)))
f_rastname=$(word 2,$(subst T, ,$(call f_fn,$1)))T$(word 3,$(subst T, ,$(call f_fn,$1)))
f_rast_mapset=$(call f_rastname,$1)@$(call f_mapset,$1)


#files:=$(wildcard /home/cimis/CA/*.pgm)
# you can call this two parameters; files, and/or mapsets. They will be combined together to create all rules
# Needed to import, project, and calculate solar parameters
file_mapsets:=$(sort $(foreach f,${files},$(call f_mapset,$f)))
all_mapsets:=$(sort ${mapsets} ${file_mapsets})


info::
	@pod2usage -exit 0 $(firstword ${MAKEFILE_LIST})

#check::
#	@podchecker ${MAKEFILE_LIST}

info::
	@echo files:${files}
	@echo mapsets:${all_mapsets}

.PHONY: import solar goes_to_solar

define _import
import::${GISDBASE}/${goes.loc}/$(call f_mapset,$1)/cellhd/$(call f_rastname,$1)
	@echo "imported"

${GISDBASE}/${goes.loc}/$(call f_mapset,$1)/cellhd/$(call f_rastname,$1):$1
	@$(call g.mapset-c,${goes.loc},$(call f_mapset,$1));\
	echo -e '${import.wld}' > $(patsubst %.pgm,%.wld,$1);\
	r.in.gdal --quiet --overwrite -o input=$1 output=$(call f_rastname,$1);\
	rm $(patsubst %.pgm,%.wld,$1);\
	echo ${goes.loc}/$(call f_mapset,$1)/$(call f_rastname,$1)

endef

define _goes_to_solar
goes_to_solar::${GISDBASE}/${solar.loc}/$1/cellhd/$2

${GISDBASE}/${solar.loc}/$1/cellhd/$2:${GISDBASE}/${goes.loc}/$1/cellhd/$2
	@$(call g.mapset-c,${solar.loc},$1);\
	g.region --quiet ${solar.region};\
	r.proj --quiet location=${goes.loc} mapset=$1 \
	  input=$2 method=${solar.proj.method};\
	echo ${solar.loc}/$1/$2
endef

define _add_predawn
endef

define _add_sunrise
$(eval $(call _goes_to_solar,$1,$2) $(call _sunrise,$2,$3,$1))
endef

# This adds in 'solar' rule.  Can't use with daily_solar as well,
# It would get overwritten.
# solar_functions go rast,prev,$mapset?
define _add_day
$(eval $(call _goes_to_solar,$1,$2) $(call _day,$2,$3,$1))
endef

define _add_sunset
$(eval $(call _sunset,$2,$3,$1))
endef

define _add_night
endef

# Let's get all files that are either in the mapsets, or in the files, ready to be added.  They are saved in a parameter list
# one for each mapset
$(foreach m,${all_mapsets},$(eval $m.files:=$(sort $(shell r.proj -l location=${goes.loc} mapset=$m 2>/dev/null || true | grep ????PST-B2) $(patsubst %@$m,%,$(filter %@$m,$(foreach i,$(filter %PST-B2.pgm,${files}),$(call f_rast_mapset,$i)))))))

# And calculate the sunrise and sunset
$(foreach m,${all_mapsets},$(eval $m.sretr=$(shell m=$m; y=$${m%????}; md=$${m#????};m=$${md%??};d=$${md#??}; r.solpos -r year=$$y month=$$m day=$$d timezone=-8 | grep sretr_hhmm | cut -d= -f 2 | sed -e 's/://')))
$(foreach m,${all_mapsets},$(eval $m.ssetr=$(shell m=$m; y=$${m%????}; md=$${m#????};m=$${md%??};d=$${md#??}; r.solpos -r year=$$y month=$$m day=$$d timezone=-8 | grep ssetr_hhmm | cut -d= -f 2 | sed -e 's/://')))
#$(foreach m,${all_mapsets},$(info $m: sretr:${$m.sretr} ssetr:${$m.ssetr}))  # Show them

# And Calculate night/day for each file we are looking at
$(foreach m,${all_mapsets},$(eval $m.daynight:=$(foreach f,$(patsubst %PST-B2,%,${$m.files}),$(shell if [[ $f < ${$m.sretr} || $f = ${$m.sretr} ]]; then echo predawn; elif [[ "$f" < "${$m.ssetr}" ]]; then echo day; else echo night; fi))))

# And now find sunrise and sunset.  Compare to the previous time / and it's type
$(foreach m,${all_mapsets},$(eval $m.prev:=0000 ${$m.files}))
$(foreach m,${all_mapsets},$(eval $m.prev_daynight:=predawn ${$m.daynight}))

$(foreach m,${all_mapsets},$(eval $m.ranges:=$(foreach i,$(shell seq 1 $(words ${$m.files})),$(if $(filter predawn,$(word $i,${$m.daynight})),predawn:,$(if $(filter day,$(word $i,${$m.daynight})),$(if $(filter predawn,$(word $i,${$m.prev_daynight})),sunrise,day),$(if $(filter day,$(word $i,${$m.prev_daynight})),sunset,night))):$(word $i,${$m.files}):$(word $i,${$m.prev}))))

# And finally create the proper rules, first mapset targets
$(foreach m,${all_mapsets},$(eval $(call mapset_targets,$m)))

# Then file imports
$(foreach f,$(sort $(filter %PST-B2.pgm,${files})),$(eval $(call _import,$f)))

# And also all the projection / and solar calculations
$(foreach m,${all_mapsets},$(foreach f,${$m.ranges},$(call _add_$(word 1,$(subst :, ,$f)),$m,$(word 2,$(subst :, ,$f)),$(word 3,$(subst :, ,$f)))))

# The user can provide a add-sunset parameter to put in a pseudo end of day if needed
$(if ${add-sunset},$(foreach m,${all_mapsets},$(if $(filter-out night,$(lastword ${$m.daynight})),$(info _add_sunset,$m,${$m.ssetr},$(lastword ${$m.files})) $(call _add_sunset,$m,${$m.ssetr},$(lastword ${$m.files})))))

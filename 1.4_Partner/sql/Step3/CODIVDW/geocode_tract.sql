DROP TABLE IF EXISTS #geocode_tract; 
SELECT 
	cl.PERSON_ID AS patid,
	cl.loc_start,
	--dbo.CENSUS_LOCATION.census_location_id,
	cl.geocode,
	cl.latitude,
	cl.longitude,
	cg.TRACT,
	cg.STATE,
	cg.COUNTY,
	cg.ZIP
INTO #geocode_tract
FROM
	@SCHEMA.@CENSUS_LOCATION cl
		LEFT JOIN @CENSUS_DEMOG_SCHEMA.@CENSUS_DEMOG cg ON cl.geocode = cg.GEOCODE
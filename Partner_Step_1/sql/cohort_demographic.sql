SELECT *
INTO #cohort_demographic
FROM (
  SELECT 
  	linkid, 
  	d.PERSON_ID AS patid, 
  	birth_date, 
  	GENDER AS sex, -- substitute
  	RACE1 AS race, -- using RACE1 only
  	hispanic, 
  	yr,
  	encN, 
  	CONVERT(date, loc_start) AS loc_start, 
  	loc_end, 
  	geocode_boundary_year,
  	geolevel, 
  	latitude, 
  	longitude --, 
  FROM (
	SELECT 
		linkid, 
		enc_counts.patid, 
		enc_counts.yr, 
		encN, 
		ec_test_latest_loc_date.latest_loc_date
	FROM enc_counts 
		LEFT JOIN ec_test_latest_loc_date ON enc_counts.patid = ec_test_latest_loc_date.PERSON_ID
		AND enc_counts.yr = ec_test_latest_loc_date.yr
  ) AS enc_counts_loc
  LEFT JOIN @SCHEMA.@CENSUS_LOCATION cl ON cl.PERSON_ID = enc_counts_loc.patid 
  				AND loc_start = enc_counts_loc.latest_loc_date 
  JOIN @SCHEMA.@DEMOGRAPHIC d ON d.PERSON_ID = enc_counts_loc.patid
) a;
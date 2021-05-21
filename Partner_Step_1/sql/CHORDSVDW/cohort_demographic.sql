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
		e.patid, 
		e.yr, 
		encN, 
		d.latest_loc_date
	FROM #enc_counts e
		LEFT JOIN #ec_test_latest_loc_date d ON e.patid = d.patid
		AND e.yr = d.yr
  ) AS enc_counts_loc
  LEFT JOIN @SCHEMA.@CENSUS_LOCATION cl ON cl.PERSON_ID = enc_counts_loc.patid 
  				AND loc_start = enc_counts_loc.latest_loc_date 
  JOIN @SCHEMA.@DEMOGRAPHICS d ON d.PERSON_ID = enc_counts_loc.patid
) a;
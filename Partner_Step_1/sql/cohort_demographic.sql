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
  		ec.patid, 
  		ec.yr, 
  		encN, 
  		(SELECT MAX(CONVERT(date, loc_start))
  			FROM @CENSUS_LOCATION cl 
  			WHERE ec.patid = PERSON_ID
  			AND loc_start <= CONVERT(datetime, '12-31-'+CAST( ec.yr AS VARCHAR(4)))
  		) AS latest_loc_date
  	FROM #enc_counts ec
  ) AS enc_counts_loc
  LEFT JOIN @CENSUS_LOCATION cl ON cl.PERSON_ID = enc_counts_loc.patid 
  				AND loc_start = enc_counts_loc.latest_loc_date 
  JOIN @DEMOGRAPHIC d ON d.PERSON_ID = enc_counts_loc.patid
) a;
--- Exposure  
DROP TABLE IF EXISTS #EXPOSURE_DOSE;

SELECT l.@LINKID_COLUMN_VALUE as linkid
	,program_name
	,session_date
	,dose
	,screening
	,counseling
	,intervention_activity
	,intervention_nutrition
	,intervention_navigation program_description
	,aim_activity
	,aim_nutrition
	,aim_weight
	,prescribed_total_dose
	,prescribed_program_duration
	,prescribed_session_frequency
	,prescribed_session_length program_setting
	,session_mode
	,location_address location_latitude
	,location_longitude
	,location_geocode
	,location_boundary_year
	,location_geolevel
INTO #EXPOSURE_DOSE
FROM @SCHEMA.@SESSION s
JOIN @SCHEMA.@PROGRAM pr ON pr.programid = s.programid
JOIN @SCHEMA.@LINK l ON s.@PERSON_ID_PATID = l.@PERSON_ID_PATID
JOIN #patientlist pl ON pl.linkid = l.@LINKID_COLUMN_VALUE
WHERE session_date >= '1/1/2017'
ORDER BY l.@LINKID_COLUMN_VALUE;


DROP TABLE IF EXISTS #ec_test;

SELECT *
INTO #ec_test
FROM (
	SELECT *
	FROM @SCHEMA.@CENSUS_LOCATION cl
	INNER JOIN #enc_counts ON enc_counts.person_id = cl.PERSON_ID
	WHERE loc_start <= CONVERT(DATETIME, '12-31-' + CAST(yr AS VARCHAR(4)))
	) a;

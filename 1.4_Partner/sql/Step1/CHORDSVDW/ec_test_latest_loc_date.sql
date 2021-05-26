DROP TABLE IF EXISTS #ec_test_latest_loc_date;

SELECT *
INTO #ec_test_latest_loc_date
FROM (
	SELECT patid
		,yr
		,MAX(CONVERT(DATE, loc_start)) AS latest_loc_date
	FROM #ec_test
	WHERE loc_start <= CONVERT(DATETIME, '12-31-' + CAST(yr AS VARCHAR(4)))
	GROUP BY patid
		,yr
	) a;

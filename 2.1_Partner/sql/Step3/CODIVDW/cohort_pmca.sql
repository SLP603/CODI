DROP TABLE IF EXISTS #cohort_pmca
SELECT c.*
	,body_system
	,severity
	,(
		CASE 
			WHEN body_system > 1
				OR severity > 1
				THEN 2
			WHEN (body_system IS NULL)
				AND (severity IS NULL)
				THEN NULL
			ELSE 1
			END
		) AS pmca_sum
INTO #cohort_pmca
FROM #cohort c
LEFT JOIN #pmca_input pi ON c.patid = pi.patid;

UPDATE #cohort_pmca
SET pmca = pmca_sum;

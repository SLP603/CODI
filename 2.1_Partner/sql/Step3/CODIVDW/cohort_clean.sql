WITH cte_cohort_clean as (
	SELECT distinct a.patid
	FROM #cohort a
	LEFT JOIN #anchor_date b 
		ON b.patid = a.patid
	WHERE b.patid is null
)
DELETE d
FROM #cohort d
JOIN cte_cohort_clean c 
	ON c.patid = d.patid;

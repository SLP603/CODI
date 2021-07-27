WITH cte_cohort_clean as (
SELECT distinct a.patid
		FROM #cohort a
		LEFT JOIN #anchor_date b 
			on b.patid = a.patid
		WHERE b.patid is null
)
DELETE d
FROM #cohort d
JOIN cte_cohort_clean c 
	on c.patid = d.patid;

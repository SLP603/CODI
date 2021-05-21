DROP TABLE IF EXISTS #study_cohort_demographic;
SELECT b.linkid
	,b.patid
	,b.birth_date
	,b.sex
	,b.race
	,b.hispanic
	,b.yr
	,b.encN
	,b.loc_start
	,c.most_recent_well_child_visit
	,c.enc_count
	,d.inclusion
	,e.exclusion
INTO #study_cohort_demographic
FROM #cohort_demographic_age_filter b
LEFT OUTER JOIN #study_cohort_export c ON b.patid = c.patid
LEFT OUTER JOIN #study_cohort_inclusion d ON b.patid = d.patid
LEFT OUTER JOIN #study_cohort_exclusion e ON b.patid = e.patid;

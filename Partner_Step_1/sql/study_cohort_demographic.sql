DROP TABLE IF EXISTS #study_cohort_demographic;
SELECT cohort_demographic_age_filter.linkid
	,cohort_demographic_age_filter.patid
	,cohort_demographic_age_filter.birth_date
	,cohort_demographic_age_filter.sex
	,cohort_demographic_age_filter.race
	,cohort_demographic_age_filter.hispanic
	,cohort_demographic_age_filter.yr
	,cohort_demographic_age_filter.encN
	,cohort_demographic_age_filter.loc_start
	,#study_cohort_export.most_recent_well_child_visit
	,#study_cohort_export.enc_count
	,#study_cohort_inclusion.inclusion
	,#study_cohort_exclusion.exclusion
INTO #study_cohort_demographic
FROM #cohort_demographic_age_filter
LEFT OUTER JOIN #study_cohort_export ON cohort_demographic_age_filter.patid = #study_cohort_export.patid
LEFT OUTER JOIN #study_cohort_inclusion ON cohort_demographic_age_filter.patid = #study_cohort_inclusion.patid
LEFT OUTER JOIN #study_cohort_exclusion ON cohort_demographic_age_filter.patid = #study_cohort_exclusion.patid;

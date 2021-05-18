DROP TABLE IF EXISTS #study_cohort_export;
SELECT S.person_id, most_recent_well_child_visit, enc_count
INTO #study_cohort_export
FROM #study_cohort S
	LEFT OUTER JOIN #recent_well_child R ON S.person_id = R.person_id
	LEFT OUTER JOIN #encounter_count E ON S.person_id = E.person_id;
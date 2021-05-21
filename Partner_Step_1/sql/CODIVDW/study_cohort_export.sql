DROP TABLE IF EXISTS #study_cohort_export;
SELECT S.patid, most_recent_well_child_visit, enc_count
INTO #study_cohort_export
FROM #study_cohort S
	LEFT OUTER JOIN #recent_well_child R ON S.patid = R.patid
	LEFT OUTER JOIN #encounter_count E ON S.patid = E.patid;
DELETE #cohort
WHERE patid IN (
		SELECT patid
		FROM #cohort
		WHERE patid NOT IN (
				SELECT patid
				FROM #anchor_date
				)
		);
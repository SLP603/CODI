DROP TABLE IF EXISTS #annotated_measures;
SELECT ad.patid
	,ht
	,wt
	,measure_date
	,(wt * .4535924) / SQUARE(ht * .0254) AS bmi
	,p95
	,100 * (((wt * .4535924) / SQUARE(ht * .0254)) / p95) AS bmi_percent_of_p95
	,'VITAL' AS src
	,d.GENDER AS sex
	,DATEDIFF(DAY, birth_date, measure_date) agedays
	,(
		CASE 
			WHEN datepart(day, measure_date) >= datepart(day, BIRTH_DATE)
				THEN datediff(month, BIRTH_DATE, measure_date)
			ELSE datediff(month, BIRTH_DATE, dateadd(month, - 1, measure_date))
			END
		) AS agemos
INTO #annotated_measures
FROM #anchor_date ad
JOIN @SCHEMA.@DEMOGRAPHICS d ON d.PERSON_ID = ad.patid
JOIN #bmiage b ON d.GENDER = b.sex
	AND b.agemos = (
		CASE 
			WHEN datepart(day, measure_date) >= datepart(day, BIRTH_DATE)
				THEN datediff(month, BIRTH_DATE, measure_date)
			ELSE datediff(month, BIRTH_DATE, dateadd(month, - 1, measure_date))
			END
		);


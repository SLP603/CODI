DROP TABLE IF EXISTS #diagnosis_CC_ind_any;
SELECT patid
	,year
	,CASE 
		WHEN condition = 'Acanthosis_Nigricans'
			THEN 1
		ELSE 0
		END AS acanthosis_nigricans
	,CASE 
		WHEN condition = 'ADHD'
			THEN 1
		ELSE 0
		END AS adhd
	,CASE 
		WHEN condition = 'anxiety'
			THEN 1
		ELSE 0
		END AS anxiety
	,CASE 
		WHEN condition = 'asthma'
			THEN 1
		ELSE 0
		END AS asthma
	,CASE 
		WHEN condition = 'autism'
			THEN 1
		ELSE 0
		END AS autism
	,CASE 
		WHEN condition = 'depression'
			THEN 1
		ELSE 0
		END AS depression
	,CASE 
		WHEN condition = 'diabetes'
			THEN 1
		ELSE 0
		END AS diabetes
	,CASE 
		WHEN condition = 'eating_disorders'
			THEN 1
		ELSE 0
		END AS eating_disorders
	,CASE 
		WHEN condition = 'hyperlipidemia'
			THEN 1
		ELSE 0
		END AS hyperlipidemia
	,CASE 
		WHEN condition = 'hypertension'
			THEN 1
		ELSE 0
		END AS hypertension
	,CASE 
		WHEN condition = 'NAFLD'
			THEN 1
		ELSE 0
		END AS NAFLD
	,CASE 
		WHEN condition = 'Obstructive_sleep_apnea'
			THEN 1
		ELSE 0
		END AS Obstructive_sleep_apnea
	,CASE 
		WHEN condition = 'PCOS'
			THEN 1
		ELSE 0
		END AS PCOS
INTO #diagnosis_CC_ind_any
FROM (
	SELECT patid
		,condition
		,year
		,count(DIAGNOSES_ID) AS cnt
	FROM #coconditions
	GROUP BY patid
		,year
		,condition
	) conditions
ORDER BY patid;


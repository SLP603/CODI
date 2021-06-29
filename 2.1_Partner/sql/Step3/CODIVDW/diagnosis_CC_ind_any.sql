DROP TABLE IF EXISTS #diagnosis_CC_ind_any;
SELECT DISTINCT c.patid
	,CASE 
		WHEN acanthosis_nigricans.patid IS NOT NULL
			THEN 1
		ELSE 0
		END AS acanthosis_nigricans
	,CASE 
		WHEN ADHD.patid IS NOT NULL
			THEN 1
		ELSE 0
		END AS adhd
	,CASE 
		WHEN anxiety.patid IS NOT NULL
			THEN 1
		ELSE 0
		END AS anxiety
	,CASE 
		WHEN asthma.patid IS NOT NULL
			THEN 1
		ELSE 0
		END AS asthma
	,CASE 
		WHEN autism.patid IS NOT NULL
			THEN 1
		ELSE 0
		END AS autism
	,CASE 
		WHEN depression.patid IS NOT NULL
			THEN 1
		ELSE 0
		END AS depression
	,CASE 
		WHEN diabetes.patid IS NOT NULL
			THEN 1
		ELSE 0
		END AS diabetes
	,CASE 
		WHEN eating_disorders.patid IS NOT NULL
			THEN 1
		ELSE 0
		END AS eating_disorders
	,CASE 
		WHEN hyperlipidemia.patid IS NOT NULL
			THEN 1
		ELSE 0
		END AS hyperlipidemia
	,CASE 
		WHEN hypertension.patid IS NOT NULL
			THEN 1
		ELSE 0
		END AS hypertension
	,CASE 
		WHEN NAFLD.patid IS NOT NULL
			THEN 1
		ELSE 0
		END AS NAFLD
	,CASE 
		WHEN Obstructive_sleep_apnea.patid IS NOT NULL
			THEN 1
		ELSE 0
		END AS Obstructive_sleep_apnea
	,CASE 
		WHEN PCOS.patid IS NOT NULL
			THEN 1
		ELSE 0
		END AS PCOS
INTO #diagnosis_CC_ind_any
FROM (
	SELECT DISTINCT patid
	FROM #coconditions
	) c
LEFT JOIN (
	SELECT DISTINCT patid
	FROM #coconditions
	WHERE condition = 'Acanthosis_Nigricans'
	) acanthosis_nigricans ON acanthosis_nigricans.patid = c.patid
LEFT JOIN (
	SELECT DISTINCT patid
	FROM #coconditions
	WHERE condition = 'ADHD'
	) ADHD ON ADHD.patid = c.patid
LEFT JOIN (
	SELECT DISTINCT patid
	FROM #coconditions
	WHERE condition = 'anxiety'
	) anxiety ON anxiety.patid = c.patid
LEFT JOIN (
	SELECT DISTINCT patid
	FROM #coconditions
	WHERE condition = 'asthma'
	) asthma ON asthma.patid = c.patid
LEFT JOIN (
	SELECT DISTINCT patid
	FROM #coconditions
	WHERE condition = 'autism'
	) autism ON autism.patid = c.patid
LEFT JOIN (
	SELECT DISTINCT patid
	FROM #coconditions
	WHERE condition = 'depression'
	) depression ON depression.patid = c.patid
LEFT JOIN (
	SELECT DISTINCT patid
	FROM #coconditions
	WHERE condition = 'diabetes'
	) diabetes ON diabetes.patid = c.patid
LEFT JOIN (
	SELECT DISTINCT patid
	FROM #coconditions
	WHERE condition = 'eating_disorders'
	) eating_disorders ON eating_disorders.patid = c.patid
LEFT JOIN (
	SELECT DISTINCT patid
	FROM #coconditions
	WHERE condition = 'hyperlipidemia'
	) hyperlipidemia ON hyperlipidemia.patid = c.patid
LEFT JOIN (
	SELECT DISTINCT patid
	FROM #coconditions
	WHERE condition = 'hypertension'
	) hypertension ON hypertension.patid = c.patid
LEFT JOIN (
	SELECT DISTINCT patid
	FROM #coconditions
	WHERE condition = 'NAFLD'
	) NAFLD ON NAFLD.patid = c.patid
LEFT JOIN (
	SELECT DISTINCT patid
	FROM #coconditions
	WHERE condition = 'Obstructive_sleep_apnea'
	) Obstructive_sleep_apnea ON Obstructive_sleep_apnea.patid = c.patid
LEFT JOIN (
	SELECT DISTINCT patid
	FROM #coconditions
	WHERE condition = 'PCOS'
	) PCOS ON PCOS.patid = c.patid
ORDER BY patid;

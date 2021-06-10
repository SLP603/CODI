DROP TABLE IF EXISTS #insurance;
SELECT 
	e.ENC_ID, 
	e.PERSON_ID,
	BENEFIT_CAT, 
	(SELECT CASE 
		WHEN BENEFIT_CAT IN ('CC', 'CP', 'MC', 'MD') THEN 'Public (non-military)'
		WHEN BENEFIT_CAT IN ('CO') THEN 'Private'
		ELSE 'Other or unknown' -- OG, NC, OT, UN, WC, NI
	END) as insurance_type
INTO #insurance	
FROM @SCHEMA.@ENCOUNTERS e
	LEFT JOIN (SELECT * FROM @SCHEMA.@BENEFIT WHERE BENEFIT_TYPE = 'PR') BEN ON e.ENC_ID = BEN.ENC_ID
JOIN #anchor_date a ON a.ENC_ID = e.ENC_ID;
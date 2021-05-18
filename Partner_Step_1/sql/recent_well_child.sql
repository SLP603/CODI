DROP TABLE IF EXISTS #recent_well_child;
SELECT 
	PERSON_ID AS person_id, 
	MAX(PROCDATE) most_recent_well_child_visit
INTO #recent_well_child
FROM @SCHEMA.@PROCEDURES
WHERE PROCDATE >= '6/1/2016' AND PROCDATE < '1/1/2020'
GROUP BY PERSON_ID;
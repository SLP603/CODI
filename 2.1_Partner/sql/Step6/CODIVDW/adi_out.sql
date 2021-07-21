DROP TABLE IF EXISTS #ADI_OUT;

WITH CTE_ADI_OUT AS (
SELECT 
	c.linkid,
	c.patid,
	cl.loc_start,
	cl.loc_end,
	cl.geocode,
	cl.latitude,
	cl.longitude,
	t.block_group_count,
	t.natrank_avg,
	t.staterank_avg
FROM #cohort c
	LEFT JOIN @SCHEMA.@CENSUS_LOCATION cl ON c.patid = cl.PERSON_ID
	LEFT JOIN #tract_adi t ON cl.geocode = t.census_tract)

SELECT 
	linkid,
	loc_start,
	loc_end,
	geocode,
	latitude,
	longitude,
	block_group_count,
	natrank_avg,
	staterank_avg
INTO #ADI_OUT
FROM CTE_ADI_OUT
ORDER BY linkid;
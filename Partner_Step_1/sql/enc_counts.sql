SELECT * 
INTO
  #enc_counts
FROM (
  SELECT linkid, patid, yr, COUNT(ENC_ID) AS encN
  FROM (
  	SELECT l.linkid AS linkid, e.PERSON_ID as patid, e.ENC_ID,
  		CASE WHEN ADATE >= '2017-1-1' AND ADATE < '2018-1-1' THEN 2017
  			 WHEN  ADATE >= '2018-1-1' AND ADATE < '2019-1-1' THEN 2018
  			 WHEN  ADATE >= '2019-1-1' AND ADATE < '2020-1-1' THEN 2019
  		END AS yr
  	FROM @SCHEMA.@ENCOUNTER e
  	JOIN @SCHEMA.@LINK l on l.patid = e.PERSON_ID
  	WHERE e.ADATE >= '2017-1-1' AND e.ADATE < '2020-1-1'
  ) AS encounter_plus_year
  GROUP BY linkid, patid, yr
) a;
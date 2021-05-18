SELECT * 
INTO
  #enc_counts
FROM (
  SELECT cid, person_id, yr, COUNT(ENC_ID) AS encN
  FROM (
  	SELECT l.cid AS cid, e.PERSON_ID as person_id, e.ENC_ID,
  		CASE WHEN ADATE >= '2017-1-1' AND ADATE < '2018-1-1' THEN 2017
  			 WHEN  ADATE >= '2018-1-1' AND ADATE < '2019-1-1' THEN 2018
  			 WHEN  ADATE >= '2019-1-1' AND ADATE < '2020-1-1' THEN 2019
  		END AS yr
  	FROM @SCHEMA.@ENCOUNTERS e
  	JOIN @SCHEMA.@LINKAGE l on l.person_id = e.PERSON_ID
  	WHERE e.ADATE >= '2017-1-1' AND e.ADATE < '2020-1-1'
  ) AS encounter_plus_year
  GROUP BY cid, person_id, yr
) a;
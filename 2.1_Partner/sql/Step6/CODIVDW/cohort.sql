DROP TABLE IF EXISTS #cohort;

CREATE TABLE #cohort (
	linkid varchar(255) PRIMARY KEY,
	patid varchar(255) ,
	race varchar(2),
	hispanic varchar(2),
	sex varchar(2),
	birth_date date,
	in_study_cohort bit default(0),
	index_site_flag varchar(5),
	ageyrs int	
);

INSERT INTO #cohort
(linkid, d.patid, sex, birth_date, race, hispanic, in_study_cohort, ageyrs)
SELECT p.linkid, d.PERSON_ID, GENDER, d.birth_date, RACE1, hispanic, 
	   CASE WHEN s.patid IS NOT NULL THEN 1 ELSE 0 END,
	   CASE 
		WHEN DATEDIFF(day, DATEADD(year, DATEDIFF(YEAR, d.birth_date, '1/1/2017'), d.birth_date), '1/1/2017') < 0
			THEN DATEDIFF(YEAR, d.birth_date, '1/1/2017') - 1
		ELSE DATEDIFF(YEAR, d.birth_date, '1/1/2017')
		END
FROM @SCHEMA.@DEMOGRAPHICS d
JOIN @SCHEMA.LINK l ON l.@PERSON_ID_PATID = d.PERSON_ID
JOIN #patientlist p ON p.linkid = l.@LINKID_COLUMN_VALUE
LEFT OUTER JOIN #study_cohort s ON d.PERSON_ID = s.patid;
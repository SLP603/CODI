DROP TABLE IF EXISTS #cohort;

CREATE TABLE #cohort (
	linkid varchar(255) PRIMARY KEY,
	patid varchar(255) ,
	ageyrs integer, -- Is this the right unit?
	sex varchar(2),
	pmca integer,
	bmi double precision,
	bmi_percent_of_p95 double precision,
	distance_from_program double precision, -- In what units?
	pat_pref_language_spoken varchar(3),
	race varchar(2),
	hispanic varchar(2),
	insurance varchar(30),
	in_study_cohort bit default(0),
	index_site_flag varchar(5),
	inclusion int, 
	exclusion int		
);

INSERT INTO #cohort
(linkid, d.patid, sex, pat_pref_language_spoken, race, hispanic, in_study_cohort, index_site_flag, ageyrs, inclusion, exclusion)
SELECT p.linkid, d.PERSON_ID, GENDER, PRIMARY_LANGUAGE, RACE1, hispanic, 
	   CASE WHEN s.patid IS NOT NULL THEN 1 ELSE 0 END AS in_study_cohort,
	   CASE WHEN UPPER(p.site) = UPPER(p.index_site) THEN 'T' ELSE 'F' END AS index_site_flag,
	   CASE 
		WHEN DATEDIFF(day, DATEADD(year, DATEDIFF(YEAR, d.birth_date, '1/1/2017'), d.birth_date), '1/1/2017') < 0
			THEN DATEDIFF(YEAR, d.birth_date, '1/1/2017') - 1
		ELSE DATEDIFF(YEAR, d.birth_date, '1/1/2017')
		END,
	   inclusion,
	   exclusion
FROM @SCHEMA.@DEMOGRAPHICS d
JOIN @SCHEMA.LINK l ON l.@PERSON_ID_PATID = d.PERSON_ID
JOIN #patientlist p ON p.linkid = l.@LINKID_COLUMN_VALUE
LEFT OUTER JOIN #study_cohort s ON d.PERSON_ID = s.patid
WHERE exclusion != 1
;
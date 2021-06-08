--Per Ken, all the programs are in so any session record should be included to consideration in the query
--This query is not used at this time.
DROP TABLE IF EXISTS #study_programs;
CREATE TABLE #study_programs (programid varchar(15))

INSERT INTO #study_programs (programid)
VALUES ('cwmp');
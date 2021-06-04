DROP TABLE IF EXISTS #pmca_input_single
SELECT *
INTO #pmca_input_single
FROM #pmca_input
WHERE body_system = 1;


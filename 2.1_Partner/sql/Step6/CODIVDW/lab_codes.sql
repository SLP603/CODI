DROP TABLE IF EXISTS #lab_codes

CREATE TABLE #lab_codes (
	test_type varchar(255),	
	coding_system varchar(50),
	code varchar(50),	
	notes varchar(255)
)
INSERT INTO #lab_codes VALUES ('AST', 'LOINC', '1920-8', 'serum/plasma QN');
INSERT INTO #lab_codes VALUES ('AST', 'CPT', '84450', NULL);
INSERT INTO #lab_codes VALUES ('ALT', 'LOINC', '1742-6', 'serum/plasma');
INSERT INTO #lab_codes VALUES ('ALT', 'CPT', '84460', NULL);
INSERT INTO #lab_codes VALUES ('HbA1c', 'LOINC', '4548-4', NULL);
INSERT INTO #lab_codes VALUES ('HbA1c', 'LOINC', '4549-2', 'electrophoresis');
INSERT INTO #lab_codes VALUES ('HbA1c', 'LOINC', '17856-6', 'HPLC');
INSERT INTO #lab_codes VALUES ('HbA1c', 'LOINC', '59261-8', 'IFCC protocol');
INSERT INTO #lab_codes VALUES ('HbA1c', 'LOINC', '71875-9', 'pure mass fraction');
INSERT INTO #lab_codes VALUES ('HbA1c', 'LOINC', '62388-4', 'JDS/JSCC protocol');
INSERT INTO #lab_codes VALUES ('HbA1c', 'CPT', '83036', NULL);
INSERT INTO #lab_codes VALUES ('Glucose', 'LOINC', '1450-5', '10-hr fasting');
INSERT INTO #lab_codes VALUES ('Glucose', 'CPT', '82947', NULL);
INSERT INTO #lab_codes VALUES ('LDL', 'LOINC', '13457-7', NULL);
INSERT INTO #lab_codes VALUES ('LDL', 'CPT', '80061', NULL);
INSERT INTO #lab_codes VALUES ('HDL', 'LOINC', '2085-9', NULL);
INSERT INTO #lab_codes VALUES ('HDL', 'CPT', '83718', NULL);
INSERT INTO #lab_codes VALUES ('Triglycerides', 'LOINC', '2571-8', NULL);
INSERT INTO #lab_codes VALUES ('Triglycerides', 'CPT', '84478', NULL);
INSERT INTO #lab_codes VALUES ('Total cholesterol', 'LOINC', '2093-3', NULL);
INSERT INTO #lab_codes VALUES ('Total cholesterol', 'CPT', '82465', NULL);
DROP TABLE IF EXISTS #demo_recon_loc_link;
SELECT 
	b.linkid,
	--#demo_recon_loc.birth_date,
	--#demo_recon_loc.sex,
	--#demo_recon_loc.race,
	--#demo_recon_loc.hispanic,
	b.site,
	b.yr,
	--#demo_recon_loc.loc_start,
	--#demo_recon_loc.census_location_id,
	l.patid
INTO #demo_recon_loc_link a
FROM 
	#demo_recon_loc b
		LEFT JOIN @SCHEMA.@LINK l ON b.linkid = l.linkid
;
DROP TABLE IF EXISTS #demo_recon_loc_tract; 
GO
SELECT 
	a.linkid,
	a.patid,
	b.birth_date,
	a.site,
	a.yr,
	b.loc_start,
	--cohort_demographic_age_filter.census_location_id,
	c.geocode,
	c.TRACT,
	c.latitude,
	c.longitude,
	c.STATE,
	c.COUNTY,
	c.ZIP
INTO 
	#demo_recon_loc_tract
FROM
	#demo_recon_loc_link a
		LEFT JOIN #cohort_demographic_age_filter b ON a.linkid = b.linkid AND
		a.yr = b.yr
		LEFT JOIN #geocode_tract c ON a.patid = c.patid
;
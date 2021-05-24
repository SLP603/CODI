# Running CODI Query for DCC	

### Running DCC Steps
1. Clone repo
2. Copy partner output from step 1 to `1.4_DCC_Step_1/partner_step_1_out`
3. Ensure each partner has output and the file names contain their partner id (e.g.: for partner with id of dh, `study_cohort_demographic_dh.csv`)
4. restore dependencies with `renv::restore()`
5. Run the code in `CodeToRun.r`
6. Output for each partner should be in the `./output`
7. Return the output to each partner.

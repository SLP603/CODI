### Partner Step 1

1) Download the project from GITHUB or obtain a zip from the DCC 
2) Unzip the project to a directory where you have read and write access

For RStudio Users:

3) If you have RStudio Installed, open the directory and navigate to the CODI/1.4_Partner/1.4_Partner.Rproj file and double click on it.
4) RStudio should automatically detect if renv is needed but it can be installed manually with the command ```
install.packages("renv")```
5) Locate the Setup_Template.r file in the directory where you unzipped the program
6) Copy the Setup_Template.r file and save it in the same directory as Setup.r.
7) Edit the Setup.r file in the following ways and save the file:
	+ Set credentials you need to connect to your CODI VDW.  Check with your database administrator at your site if you are not sure what these are.
	+ If your site has implemented a different database schema than `dbo`, update the SCHEMA variable.
	+ If you are running the code against a 3.5 CHORDS VDW instead of a CODI VDW, update the DATAMODEL variable from CODIVDW to CHORDSVDW
	+ Set the CODISTEP variable to the appropriate step (Currently 1 or 3)
	+ Set PartnerID for your site
	+ If your table names are different than the standard table names (e.g.: `CHORDS_DEMOGRAPHICS` instead of `DEMOGRAPHICS`) you can adjust the table names section to match your site's configuration
	+ If you implemented CODI VDW tables but used `person_id` instead of `patid`, update the PERSON_ID_PATID variable from `patid` to `person_id`
8) After you have updated the Setup.r file, open the CodeToRun.r file.  
9) At the top of the CodeToRun.r file, click the *Source* button to start the run.  If there are any errors, those should be displayed in the console.
10) If the program succeeds, a new file should appear in the output directory for the step.  Review this file and then submit the csv back to the DCC to be processed

For Non-Rstudio Users:

3) Open the directory where you unzipped the program and navigate to the CODI/1.4_Partner/ folder
4) Locate the Setup_Template.r file in the directory where you unzipped the program and open it in Notepad (do not use Microsoft Word)
5) Copy the Setup_Template.r file contents and save it in the same directory as Setup.r.
6) Edit the Setup.r file in the following ways and save the file:
	+ Set credentials you need to connect to your CODI VDW.  Check with your database administrator at your site if you are not sure what these are.
	+ If your site has implemented a different database schema than `dbo`, update the SCHEMA variable.
	+ If you are running the code against a 3.5 CHORDS VDW instead of a CODI VDW, update the DATAMODEL variable from CODIVDW to CHORDSVDW
	+ Set the CODISTEP variable to the appropriate step (Currently 1 or 3)
	+ Set PartnerID for your site
	+ If your table names are different than the standard table names (e.g.: `CHORDS_DEMOGRAPHICS` instead of `DEMOGRAPHICS`) you can adjust the table names section to match your site's configuration
	+ If you implemented CODI VDW tables but used `person_id` instead of `patid`, update the PERSON_ID_PATID variable from `patid` to `person_id`
7) Open the R_Location.txt file with Notepad (not Microsoft Word) and edit the location of where R is installed.  This should match the location you entered into the CHORDS Datamart client. 
8) Save the R_Location.txt file.
9) Double click on the CodeToRun.cmd file.  This will bring in the location of R and attempt to run the program.  If an error is encountered, it should display in the console
10) If the program succeeds, a new file should appear in the output directory for the step.  Review this file and then submit the csv back to the DCC to be processed

### Partner Step 3*

*Step 4 occurs immediately after step 3 at the partner site so Step 3 and Step 4 code is combined to run all together.  

1) If the code has been updated, obtain an updated zip from the DCC or download the code from Github as described in Step 1.

For RStudio Users:

2) Open the 1.4Partner.Rproj project file
3) Copy the Setup_Template.r file and save it in the same directory as Setup.r.
	 - Update the configurations to match your environment.  Most settings from Step 1 will remain the same. 		
	 - Update the `CODISTEP` variable to *3*
4) Get the `index_site_[your partner_id]` file from the DCC (Usually distributed through PopMedNet or Egnyte) and copy it to the `From_DCC` folder
5) Open the CodeToRun.r file.  
6) At the top of the CodeToRun.r file, click the *Source* button to start the run.  If there are any errors, those should be displayed in the console.
7) If the program succeeds, a new file should appear in the output directory for the step.  Review this file and then submit the csv back to the DCC to be processed.

For Non-RStudio Users:

2) Open the directory where you saved the 1.4_Partner code
3) Copy the Setup_Template.r file and save it in the same directory as Setup.r with a basic text editor like Notepad.
	 - Update the configurations to match your environment.  Most settings from Step 1 will remain the same. 
	 - Update the `CODISTEP` variable to *3*
4) Get the `index_site_[your partner_id]` file from the DCC (Usually distributed through PopMedNet or Egnyte) and copy it to the `From_DCC` folder
5) Open the R_Location.txt file with a basic text editor to verify the location of R has not changed.
6) Double click on the CodeToRun.cmd file.  This will bring in the location of R and attempt to run the program.  If an error is encountered, it should display in the console.
7) If the program succeeds, a new file should appear in the output directory for the step.  Review this file and then submit the csv back to the DCC to be processed.

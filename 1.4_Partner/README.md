### Partner Step 1

For RStudio Users:
1) Download the project from Github.
2) Unzip the project to a directory where you have read and write access
3) If you have RStudio Installed, open the directory and navigate to the CODI/1.4_Partner/1.4_Partner.Rproj file and double click on it.
4) RStudio should automatically detect if renv is needed but it can be installed manually with the command ```
install.packages("renv")```
5) Locate the Setup.r file in the directory where you unzipped the program
6) Edit the Setup.r file in the following ways and save the file:
	+ Set credentials you need to connect to your CODI VDW.  Check with your database administrator at your site if you are not sure what these are.
	+ If your site has implemented a different database schema than `dbo`, update the SCHEMA variable.
	+ Set the `CODISTEP` variable to `1`
	+ Set `PartnerID` for your site
	+ If your table names are different than the standard table names (e.g.: `CHORDS_DEMOGRAPHICS` instead of `DEMOGRAPHICS`) you can adjust the table names section to match your site's configuration
	+ If you implemented CODI VDW tables but used `person_id` instead of `patid`, update the PERSON_ID_PATID variable from `patid` to `person_id`
7) After you have updated the Setup.r file, open the CodeToRun.r file.  
8) At the top of the CodeToRun.r file, click the *Source* button to start the run.  If there are any errors, those should be displayed in the console.
9) If the program succeeds, a new file should appear in the output directory for the step.  Review this file and then submit the csv back to the DCC to be processed

For Non-Rstudio Users:
1) Download the project from GITHUB or obtain a zip from the DCC 
2) Unzip the project to a directory where you have read and write access
3) Open the directory where you unzipped the program and navigate to the CODI/1.4_Partner/ folder
4) Locate the Setup.r file in the directory where you unzipped the program and open it in Notepad (do not use Microsoft Word)
5) Edit the Setup.r file in the following ways and save the file:
	+ Set credentials you need to connect to your CODI VDW.  Check with your database administrator at your site if you are not sure what these are.
	+ If your site has implemented a different database schema than `dbo`, update the SCHEMA variable.
	+ Set the `CODISTEP` variable to `1`
	+ Set `PartnerID` for your site
	+ If your table names are different than the standard table names (e.g.: `CHORDS_DEMOGRAPHICS` instead of `DEMOGRAPHICS`) you can adjust the table names section to match your site's configuration
	+ If you implemented CODI VDW tables but used `person_id` instead of `patid`, update the PERSON_ID_PATID variable from `patid` to `person_id`
6) Open the R_Location.txt file with Notepad (not Microsoft Word) and edit the location of where R is installed.  This should match the location you entered into the CHORDS Datamart client. 
7) Save the R_Location.txt file.
8) Double click on the CodeToRun.cmd file.  This will bring in the location of R and attempt to run the program.  If an error is encountered, it should display in the console
9) If the program succeeds, a new file should appear in the output directory for the step.  Review this file and then submit the csv back to the DCC to be processed

### Partner Step 3*

*Step 4 occurs immediately after step 3 at the partner site so Step 3 and Step 4 code is combined to run all together.  

For RStudio Users:
1) Obtain the most up to date code from Github
2) Download the demo_recon_loc_[your partner_id].csv file from the DCC (Usually distributed through PopMedNet Datamart Client or Egnyte) and copy it to the `From_DCC` folder.
3) Open the 1.4Partner.Rproj project file
4) Copy the Setup.r file from when you ran Step 1 to the new code directory.  Check the `Setup_Template.r` file if there are any new settings you should copy over and configure.
5) Update the `CODISTEP` variable in the Setup.r file to `3`
6) Open the CodeToRun.r file.  
7) At the top of the CodeToRun.r file, click the *Source* button to start the run.  If there are any errors, those should be displayed in the console.
8) If the program succeeds, a new file should appear in the output directory for the step.  Review this file and then submit the csv back to the DCC to be processed.
  
For Non-RStudio Users:
1) Obtain the most up to date code from Github
2) Download the demo_recon_loc_[your partner_id].csv file from the DCC (Usually distributed through PopMedNet Datamart Client or Egnyte) and copy it to the `From_DCC` folder.
3) Open the directory where you saved the updated 1.4_Partner code
4) Copy the `Setup.r` file from when you ran Step 1 to the new code directory.  Check the `Setup_Template.r` file if there are any new settings you should copy over and configure.
5) Update the `CODISTEP` variable in the Setup.r file to `3` using notepad or other text editor.  Don't use Microsoft Word.
6) Open the R_Location.txt file with a basic text editor to verify the location of R has not changed.
7) Double click on the CodeToRun.cmd file.  This will bring in the location of R and attempt to run the program.  If an error is encountered, it should display in the console.
8) If the program succeeds, a new file should appear in the output directory for the step.  Review this file and then submit the csv back to the DCC to be processed.

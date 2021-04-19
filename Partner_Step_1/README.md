### Partner Step 1

1) Download the project from GITHUB or obtain a zip from the DCC 
2) Unzip the project to a directory where you have read and write access

For RStudio Users:

3) If you have RStudio Installed, open the navigate to the CODI/Partner_Setup_1/Partner_Step_1.Rproj file with RStudio.
4) RStudio should automatically detect if renv is needed but it can be installed manually with the command ```
install.packages("renv")```
5) Locate the Setup.r file in the directory where you unzipped the program
6) Edit the file to include the credentials you need to connect to your CODI VDW.  If you're not sure what you should put into these fields, check with your database administrator at your site.
7) Scroll down in the Setup.r file and enter your site's PartnerID.  This ID depends on who you are.
8) If your site has used different table names than those that are in the COID data model manual, you can update those at the bottom of the Setup.r file.  If you used only the table names from the CODI data model, leave these table names along.
9) At the top of the CodeToRun.r file, click the Source button to start the run.  If there are any errors, those should be displayed in the console.
10) If the program succeeds, a new file named study_cohort_demographic_.csv should appear in location of the program.  Review this file and then submit the csv back to the DCC to be processed

For Non-Rstudio Users:

3) Navigate to the CODI/Partner_Setup_1 folder
4) Locate the Setup.r file in the directory where you unzipped the program
6) Edit the file to include the credentials you need to connect to your CODI VDW.  If you're not sure what you should put into these fields, check with your database administrator at your site.
7) Open the R_Location.txt file with Notepad (not Microsoft Word) and edit the location of where R is installed.  This should match the location you entered into the CHORDS Datamart client. 
8) Save the R_Location.txt file.
9) Double click on the CodeToRun.cmd file.  This will bring in the location of R and attempt to run the program.  If an error is encountered, it should display
10) If the program succeeds, a new file named study_cohort_demographic_.csv should appear in the same location.  Review this file and then submit the csv back to the DCC to be processed

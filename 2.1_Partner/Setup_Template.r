# Enter the server name and database name of your CODI VDW
ServerName <- ""
DatabaseName <- ""

# If you use a specific username and password to connect to your CODI VDW enter those below.
# If you just use your windows credentials to connect, leave these blank.
SQLServerUserName<- ""
SQLServerPassword<- ""

# The default schema for SQL Server is "dbo". If you have used a different schema, specify
#  it here
SCHEMA <- "CODI"

# Only enter a port number if your CODI VDW SQL Server operates on a different port than
#  the standard one of 1433 (this is rare).
PortNumber <- ""

# Leave extra settings blank unless otherwise directed by someone from the DCC (i.e. Rachel)
extraSettings <- ""

# The default datamodel the the CODI version of the VDW.  If this is being run against
#  the 3.5 version of the CHORDS VDW, change this value to CHORDSVDW
DATAMODEL <- "CODIVDW"

# Set the step as 1 or 3
CODISTEP <- 0

# PatenerID corresponds to the initials of your site and is one of the following:
#  Children's Hospital of Colorado = ch
#  Denver Health = dh
#  Girls on the Run = gotr
#  hfc?
#  Kaiser Permanente Colorado = kp
PartnerID <- "dh"

# Below are the tables possible in the CODI data model.  If any tables have been named 
# differently (i.e, "VITAL_SIGNS" instead of VITAL), update the text within the quotes
# to your CODI table names.
ALERT <- "ALERT"
ASSET_DELIVERY <- "ASSET_DELIVERY"
CENSUS_DEMOG <- "CENSUS_DEMOG"
CENSUS_LOCATION <- "CENSUS_LOCATION"
COST <- "COST"
CURRICULUM_COMPONENT <- "CURRICULUM_COMPONENT"
DEMOGRAPHICS <- "DEMOGRAPHICS"
DIAGNOSES <- "DIAGNOSES"
ENCOUNTERS <- "ENCOUNTERS"
FAMILY_HISTORY <- "FAMILY_HISTORY"
IDENTIFIER <- "IDENTIFIER"
IDENTITY_HASH_BUNDLE <- "IDENTITY_HASH_BUNDLE"
LAB_RESULTS <- "LAB_RESULTS"
PRESCRIBING <- "PRESCRIBING"
PROCEDURES <- "PROCEDURES"
PROGRAM <- "PROGRAM"
PROVIDER_SPECIALTY <- "PROVIDER_SPECIALTY"
REFERRAL <- "REFERRAL"
SESSION <- "SESSION"
SESSION_ALERT <- "SESSION_ALERT"
VITAL_SIGNS <- "VITAL_SIGNS"
BENEFIT <- "BENEFIT"
BENEFIT_SCHEMA <- SCHEMA
PROVIDER_SPECIALTY_SCHEMA <- SCHEMA

# If DATAMODEL is set to CHORDSVDW, will set the LINK table name to LINKAGE
#  Otherwise will use the default value of LINK.  Should be no need to update this.
LINK <- ifelse(DATAMODEL == "CHORDSVDW", "LINKAGE", "LINK")

# If CODI Tables where implemented but CHORDS conventional column names were used
#  they can be set here. These settings are ignored for the VDW 3.5.
PERSON_ID_PATID <- "person_id"

# Can be used to change remap the linkid filed name in the link table to something else.
LINKID_COLUMN_VALUE <- "linkid"

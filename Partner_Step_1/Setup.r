# Enter the server name and database name of your CODI VDW

ServerName <- ""
DatabaseName <- ""

# The default schema for SQL Server is "dbo". If you have used a different schema, specify
#  it here
schema <- "dbo"

# If you use a specific username and password to connect to your CODI VDW enter those below.
# If you just use your windows credentials to connect, leave these blank.

SQLServerUserName<- ""
SQLServerPassword<- ""

# Only enter a port number if your CODI VDW SQL Server operates on a different port than
#  the standard one of 1433 (this is rare).

PortNumber <- ""

# Leave extra settings blank unless otherwise directed by someone from the DCC (i.e. Rachel)

extraSettings <- ""

# PatenerID corresponds to the initials of your site and is one of the following:
#  Children's Hospital of Colorado = ch
#  Denver Health = dh
#  Girls on the Run = gotr
#  hfc?
#  Kaiser Permanente Colorado = kp

PartnerID <- ""

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
LINKAGE <- "LINKAGE"
PRESCRIBING <- "PRESCRIBING"
PROCEDURES <- "PROCEDURES"
PROGRAM <- "PROGRAM"
PROVIDER_SPECIALTY <- "PROVIDER_SPECIALTY"
REFERRAL <- "REFERRAL"
SESSION <- "SESSION"
SESSION_ALERT <- "SESSION_ALERT"
VITAL_SIGNS <- "VITAL_SIGNS"

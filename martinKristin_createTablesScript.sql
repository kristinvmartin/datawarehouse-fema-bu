/*
This script is to create the schema for the warehouse. It is to be loaded in MSSQL Server before running
any of the .ipynb files.
*/

--drop tables/constraints/sequences to ensure error-free runs during testing
DROP SEQUENCE IF EXISTS dateTime_PK;
DROP SEQUENCE IF EXISTS location_PK;
DROP SEQUENCE IF EXISTS disaster_PK;
ALTER TABLE Relief_Fact DROP CONSTRAINT IF EXISTS disaster_FK;
ALTER TABLE Relief_Fact DROP CONSTRAINT IF EXISTS location_FK;
ALTER TABLE Relief_Fact DROP CONSTRAINT IF EXISTS dateTime_FK;
DROP TABLE IF EXISTS DateTime_Dimension;
DROP TABLE IF EXISTS Location_Dimension;
DROP TABLE IF EXISTS Disaster_Dimension;
DROP TABLE IF EXISTS Relief_Fact;

--creating the date/time dimension, used granularity as specified by business questions and to account for any flexibility needed
CREATE TABLE DateTime_Dimension (
	dateTimeId decimal PRIMARY KEY,
	calendarDate date NOT NULL,
	calendarDayOfWeek varchar(10) NOT NULL, 
	calendarDayOfMonth tinyint NOT NULL,
	calendarMonthOfYear tinyint NOT NULL,
	calendarWeekOfYear tinyint NOT NULL,
	calendarYear int NOT NULL,
	fiscalQuarter tinyint NOT NULL,
	fiscalYear int NOT NULL
);

--creating the location dimension. Did not normalize zip codes, states, etc to avoid overnormalizing and improve processing speed of queries
CREATE TABLE Location_Dimension (
	locationId decimal PRIMARY KEY,
	locRegion varchar(2),
	locPriorRegion varchar(2) DEFAULT NULL, --in case the location has been re-assigned to a different region, this mitigates data loss.
	locState varchar (40) NOT NULL,
	locCounty varchar(255) NOT NULL,
	locCity varchar(255) NOT NULL,
	locZipCode varchar(10) NOT NULL,
	locationIndex decimal NOT NULL
);

--creating the disaster dimension
CREATE TABLE Disaster_Dimension (
	disasterId decimal PRIMARY KEY,
	femaDisasterNumber decimal NOT NULL, --number designated by FEMA
	incidentType varchar(40) NOT NULL, --hurricane, flood, etc.
	designatedArea varchar(255) NOT NULL, --main area designated for disaster (FEMA provides)
	rowEffectiveDate date NOT NULL DEFAULT GETDATE(), --to ensure most current data is in table without creating duplicate records on periodic updates
	rowExpirationDate date DEFAULT NULL, --same as rowEffectiveDate
	currentIndicator BIT NOT NULL DEFAULT 1 --same as above
);

--creating the Relief fact table to answer key business questions, IDs are FKs to dimension tables
CREATE TABLE Relief_Fact (
	disasterId decimal,
	locationId decimal,
	dateTimeId decimal,
	totalValidRegistrations int NOT NULL, --how many people registered for aid
	ihpReferrals int NOT NULL, --how many people referred
	ihpEligible int NOT NULL, --how many registrants found eligible
	ihpAmount decimal (20,2) NOT NULL, --how much IHP aid received
	haReferrals int NOT NULL, --how many housing assistance referrals received
	haEligible int NOT NULL, --how many found eligible
	haAmount decimal (20,2) NOT NULL, --how much HA aid received
	onaReferrals int NOT NULL, --total IHP + HA referrals
	onaEligible int NOT NULL, --total IHP + HA eligible applicants
	onaAmount decimal (20,2) NOT NULL --total aid received
);
--adding FK constraints
ALTER TABLE Relief_Fact ADD CONSTRAINT disaster_FK FOREIGN KEY (disasterId) REFERENCES Disaster_Dimension(disasterId);
ALTER TABLE Relief_Fact ADD CONSTRAINT location_FK FOREIGN KEY (locationId) REFERENCES Location_Dimension(locationId);
ALTER TABLE Relief_Fact ADD CONSTRAINT dateTime_FK FOREIGN KEY (dateTimeId) REFERENCES DateTime_Dimension(dateTimeId);

--creating sequences to automate PK creation
CREATE SEQUENCE dateTime_PK
AS decimal
START WITH 1000000
INCREMENT BY 1
;

CREATE SEQUENCE location_PK
AS decimal
START WITH 2000000
INCREMENT BY 1
;

CREATE SEQUENCE disaster_PK
AS decimal
START WITH 3000000
INCREMENT BY 1
;

COMMIT

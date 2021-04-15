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

CREATE TABLE Location_Dimension (
	locationId decimal PRIMARY KEY,
	locRegion varchar(2),
	locPriorRegion varchar(2) DEFAULT NULL,
	locState varchar (40) NOT NULL,
	locCounty varchar(255) NOT NULL,
	locCity varchar(255) NOT NULL,
	locZipCode varchar(10) NOT NULL,
	locationIndex decimal NOT NULL
);

CREATE TABLE Disaster_Dimension (
	disasterId decimal PRIMARY KEY,
	femaDisasterNumber decimal NOT NULL,
	incidentType varchar(40) NOT NULL,
	designatedArea varchar(255) NOT NULL,
	rowEffectiveDate date NOT NULL DEFAULT GETDATE(),
	rowExpirationDate date DEFAULT NULL,
	currentIndicator BIT NOT NULL DEFAULT 1
);

CREATE TABLE Relief_Fact (
	disasterId decimal,
	locationId decimal,
	dateTimeId decimal,
	totalValidRegistrations int NOT NULL,
	ihpReferrals int NOT NULL,
	ihpEligible int NOT NULL,
	ihpAmount decimal (20,2) NOT NULL,
	haReferrals int NOT NULL,
	haEligible int NOT NULL,
	haAmount decimal (20,2) NOT NULL,
	onaReferrals int NOT NULL,
	onaEligible int NOT NULL,
	onaAmount decimal (20,2) NOT NULL
);

ALTER TABLE Relief_Fact ADD CONSTRAINT disaster_FK FOREIGN KEY (disasterId) REFERENCES Disaster_Dimension(disasterId);
ALTER TABLE Relief_Fact ADD CONSTRAINT location_FK FOREIGN KEY (locationId) REFERENCES Location_Dimension(locationId);
ALTER TABLE Relief_Fact ADD CONSTRAINT dateTime_FK FOREIGN KEY (dateTimeId) REFERENCES DateTime_Dimension(dateTimeId);

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

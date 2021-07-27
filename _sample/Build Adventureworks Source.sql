/*
 * HOW TO RUN THIS SCRIPT:
 *
 * 1. Enable full-text search on your SQL Server instance. 
 *
 * 2. Open the script inside SQL Server Management Studio and enable SQLCMD mode. 
 *    This option is in the Query menu.
 *
 * 3. Copy this script and the install files to C:\Samples\AdventureWorks, or
 *    set the following environment variable to your own data path.
 */
:setvar SqlSamplesSourceDataPath "/sql/Source/file/AdventureWorks/"

/*
 * 4. Append the SQL Server version number to database name if you want to
 *    differentiate it from other installs of AdventureWorks.
 */

:setvar DatabaseName "PyroSourceDB"

/* Execute the script
 */

IF '$(SqlSamplesSourceDataPath)' IS NULL OR '$(SqlSamplesSourceDataPath)' = ''
BEGIN
	RAISERROR(N'The variable SqlSamplesSourceDataPath must be defined.', 16, 127) WITH NOWAIT
	RETURN
END;


SET NOCOUNT OFF;
GO

PRINT CONVERT(varchar(1000), @@VERSION);
GO

PRINT '';
PRINT 'Started - ' + CONVERT(varchar, GETDATE(), 121);
GO

USE [master];
GO
-- ****************************************
-- Drop Database
-- ****************************************
--PRINT '';
--PRINT '*** Dropping Database';
--GO

--IF EXISTS (SELECT [name] FROM [master].[sys].[databases] WHERE [name] = N'$(DatabaseName)')
--    DROP DATABASE $(DatabaseName);

---- If the database has any other open connections close the network connection.
--IF @@ERROR = 3702 
--    RAISERROR('$(DatabaseName) database cannot be dropped because there are still other open connections', 127, 127) WITH NOWAIT, LOG;
--GO


-- ****************************************
-- Create Database
-- ****************************************
--PRINT '';
--PRINT '*** Creating Database';
--GO

--CREATE DATABASE $(DatabaseName);
--GO

--PRINT '';
--PRINT '*** Checking for $(DatabaseName) Database';
--/* CHECK FOR DATABASE IF IT DOESN'T EXISTS, DO NOT RUN THE REST OF THE SCRIPT */
--IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = N'$(DatabaseName)')
--BEGIN
--PRINT '*******************************************************************************************************************************************************************'
--+char(10)+'********$(DatabaseName) Database does not exist.  Make sure that the script is being run in SQLCMD mode and that the variables have been correctly set.*********'
--+char(10)+'*******************************************************************************************************************************************************************';
--SET NOEXEC ON;
--END
--GO

ALTER DATABASE $(DatabaseName) 
SET RECOVERY SIMPLE, 
    ANSI_NULLS ON, 
    ANSI_PADDING ON, 
    ANSI_WARNINGS ON, 
    ARITHABORT ON, 
    CONCAT_NULL_YIELDS_NULL ON, 
    QUOTED_IDENTIFIER ON, 
    NUMERIC_ROUNDABORT OFF, 
    PAGE_VERIFY CHECKSUM, 
    ALLOW_SNAPSHOT_ISOLATION OFF;
GO

USE $(DatabaseName);
GO

-- ****************************************
-- Create DDL Trigger for Database
-- ****************************************
PRINT '';
PRINT '*** Creating DDL Trigger for Database';
GO

SET QUOTED_IDENTIFIER ON;
GO

-- Create table to store database object creation messages
-- *** WARNING:  THIS TABLE IS INTENTIONALLY A HEAP - DO NOT ADD A PRIMARY KEY ***
CREATE TABLE [dbo].[DatabaseLog](
    [DatabaseLogID] [int] IDENTITY (1, 1) NOT NULL,
    [PostTime] [datetime] NOT NULL, 
    [DatabaseUser] [sysname] NOT NULL, 
    [Event] [sysname] NOT NULL, 
    [Schema] [sysname] NULL, 
    [Object] [sysname] NULL, 
    [TSQL] [nvarchar](max) NOT NULL, 
    [XmlEvent] [xml] NOT NULL
) ON [PRIMARY];
GO

CREATE TRIGGER [ddlDatabaseTriggerLog] ON DATABASE 
FOR DDL_DATABASE_LEVEL_EVENTS AS 
BEGIN
    SET NOCOUNT ON;

    DECLARE @data XML;
    DECLARE @schema sysname;
    DECLARE @object sysname;
    DECLARE @eventType sysname;

    SET @data = EVENTDATA();
    SET @eventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'sysname');
    SET @schema = @data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'sysname');
    SET @object = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname') 

    IF @object IS NOT NULL
        PRINT '  ' + @eventType + ' - ' + @schema + '.' + @object;
    ELSE
        PRINT '  ' + @eventType + ' - ' + @schema;

    IF @eventType IS NULL
        PRINT CONVERT(nvarchar(max), @data);

    INSERT [dbo].[DatabaseLog] 
        (
        [PostTime], 
        [DatabaseUser], 
        [Event], 
        [Schema], 
        [Object], 
        [TSQL], 
        [XmlEvent]
        ) 
    VALUES 
        (
        GETDATE(), 
        CONVERT(sysname, CURRENT_USER), 
        @eventType, 
        CONVERT(sysname, @schema), 
        CONVERT(sysname, @object), 
        @data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(max)'), 
        @data
        );
END;
GO


-- ****************************************
-- Create Error Log objects
-- ****************************************
PRINT '';
PRINT '*** Creating Error Log objects';
GO

-- Create table to store error information
CREATE TABLE [dbo].[ErrorLog](
    [ErrorLogID] [int] IDENTITY (1, 1) NOT NULL,
    [ErrorTime] [datetime] NOT NULL CONSTRAINT [DF_ErrorLog_ErrorTime] DEFAULT (GETDATE()),
    [UserName] [sysname] NOT NULL, 
    [ErrorNumber] [int] NOT NULL, 
    [ErrorSeverity] [int] NULL, 
    [ErrorState] [int] NULL, 
    [ErrorProcedure] [nvarchar](126) NULL, 
    [ErrorLine] [int] NULL, 
    [ErrorMessage] [nvarchar](4000) NOT NULL
) ON [PRIMARY];
GO

ALTER TABLE [dbo].[ErrorLog] WITH CHECK ADD 
    CONSTRAINT [PK_ErrorLog_ErrorLogID] PRIMARY KEY CLUSTERED 
    (
        [ErrorLogID]
    )  ON [PRIMARY];
GO

-- uspPrintError prints error information about the error that caused 
-- execution to jump to the CATCH block of a TRY...CATCH construct. 
-- Should be executed from within the scope of a CATCH block otherwise 
-- it will return without printing any error information.
CREATE PROCEDURE [dbo].[uspPrintError] 
AS
BEGIN
    SET NOCOUNT ON;

    -- Print error information. 
    PRINT 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
          ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
          ', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
          ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
          ', Line ' + CONVERT(varchar(5), ERROR_LINE());
    PRINT ERROR_MESSAGE();
END;
GO

-- uspLogError logs error information in the ErrorLog table about the 
-- error that caused execution to jump to the CATCH block of a 
-- TRY...CATCH construct. This should be executed from within the scope 
-- of a CATCH block otherwise it will return without inserting error 
-- information. 
CREATE PROCEDURE [dbo].[uspLogError] 
    @ErrorLogID [int] = 0 OUTPUT -- contains the ErrorLogID of the row inserted
AS                               -- by uspLogError in the ErrorLog table
BEGIN
    SET NOCOUNT ON;

    -- Output parameter value of 0 indicates that error 
    -- information was not logged
    SET @ErrorLogID = 0;

    BEGIN TRY
        -- Return if there is no error information to log
        IF ERROR_NUMBER() IS NULL
            RETURN;

        -- Return if inside an uncommittable transaction.
        -- Data insertion/modification is not allowed when 
        -- a transaction is in an uncommittable state.
        IF XACT_STATE() = -1
        BEGIN
            PRINT 'Cannot log error since the current transaction is in an uncommittable state. ' 
                + 'Rollback the transaction before executing uspLogError in order to successfully log error information.';
            RETURN;
        END

        INSERT [dbo].[ErrorLog] 
            (
            [UserName], 
            [ErrorNumber], 
            [ErrorSeverity], 
            [ErrorState], 
            [ErrorProcedure], 
            [ErrorLine], 
            [ErrorMessage]
            ) 
        VALUES 
            (
            CONVERT(sysname, CURRENT_USER), 
            ERROR_NUMBER(),
            ERROR_SEVERITY(),
            ERROR_STATE(),
            ERROR_PROCEDURE(),
            ERROR_LINE(),
            ERROR_MESSAGE()
            );

        -- Pass back the ErrorLogID of the row inserted
        SET @ErrorLogID = @@IDENTITY;
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred in stored procedure uspLogError: ';
        EXECUTE [dbo].[uspPrintError];
        RETURN -1;
    END CATCH
END;
GO


-- ****************************************
-- Create Data Types
-- ****************************************
PRINT '';
PRINT '*** Creating Data Types';
GO

CREATE TYPE [AccountNumber] FROM nvarchar(15) NULL;
CREATE TYPE [Flag] FROM bit NOT NULL;
CREATE TYPE [NameStyle] FROM bit NOT NULL;
CREATE TYPE [Name] FROM nvarchar(50) NULL;
CREATE TYPE [OrderNumber] FROM nvarchar(25) NULL;
CREATE TYPE [Phone] FROM nvarchar(25) NULL;
GO


-- ******************************************************
-- Add pre-table database functions.
-- ******************************************************
PRINT '';
PRINT '*** Creating Pre-Table Database Functions';
GO

CREATE FUNCTION [dbo].[ufnLeadingZeros](
    @Value int
) 
RETURNS varchar(8) 
WITH SCHEMABINDING 
AS 
BEGIN
    DECLARE @ReturnValue varchar(8);

    SET @ReturnValue = CONVERT(varchar(8), @Value);
    SET @ReturnValue = REPLICATE('0', 8 - DATALENGTH(@ReturnValue)) + @ReturnValue;

    RETURN (@ReturnValue);
END;
GO


-- ******************************************************
-- Create database schemas
-- ******************************************************
PRINT '';
PRINT '*** Creating Database Schemas';
GO

CREATE SCHEMA [AW_HumanResources] AUTHORIZATION [dbo];
GO

CREATE SCHEMA [AW_Person] AUTHORIZATION [dbo];
GO

CREATE SCHEMA [AW_Production] AUTHORIZATION [dbo];
GO

CREATE SCHEMA [AW_Purchasing] AUTHORIZATION [dbo];
GO

CREATE SCHEMA [AW_Sales] AUTHORIZATION [dbo];
GO


-- ****************************************
-- Create XML schemas
-- ****************************************
PRINT '';
PRINT '*** Creating XML Schemas';
GO

-- Create AdditionalContactInfo schema
PRINT '';
PRINT 'Create AdditionalContactInfo schema';
GO

CREATE XML SCHEMA COLLECTION [AW_Person].[AdditionalContactInfoSchemaCollection] AS 
'<?xml version="1.0" encoding="UTF-8"?>
<xsd:schema targetNamespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo" 
    xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo" 
    elementFormDefault="qualified"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" >
    <!-- the following imports are not needed. They simply provide readability -->

    <xsd:import 
        namespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactRecord" />

    <xsd:import 
        namespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes" />

    <xsd:element name="AdditionalContactInfo" >
        <xsd:complexType mixed="true" >
            <xsd:sequence>
                <xsd:any processContents="strict" 
                    namespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactRecord 
                        http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes"
                        minOccurs="0" maxOccurs="unbounded" />
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
</xsd:schema>';
GO

ALTER XML SCHEMA COLLECTION [AW_Person].[AdditionalContactInfoSchemaCollection] ADD 
'<?xml version="1.0" encoding="UTF-8"?>
<xsd:schema targetNamespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactRecord"
    elementFormDefault="qualified"
    xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactRecord"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" >

    <xsd:element name="ContactRecord" >
        <xsd:complexType mixed="true" >
            <xsd:choice minOccurs="0" maxOccurs="unbounded" >
                <xsd:any processContents="strict"  
                    namespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes" />
            </xsd:choice>
            <xsd:attribute name="date" type="xsd:date" />
        </xsd:complexType>
    </xsd:element>
</xsd:schema>';
GO

ALTER XML SCHEMA COLLECTION [AW_Person].[AdditionalContactInfoSchemaCollection] ADD 
'<?xml version="1.0" encoding="UTF-8"?>
<xsd:schema targetNamespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes"
    xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes" 
    elementFormDefault="qualified"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" >

    <xsd:complexType name="specialInstructionsType" mixed="true">
        <xsd:sequence>
            <xsd:any processContents="strict" 
                namespace = "##targetNamespace"
                minOccurs="0" maxOccurs="unbounded" />
        </xsd:sequence>
    </xsd:complexType>

    <xsd:complexType name="phoneNumberType">
        <xsd:sequence>
            <xsd:element name="number" >
                <xsd:simpleType>
                    <xsd:restriction base="xsd:string">
                        <xsd:pattern value="[0-9\(\)\-]*"/>
                    </xsd:restriction>
                </xsd:simpleType>
            </xsd:element>
            <xsd:element name="SpecialInstructions" minOccurs="0" type="specialInstructionsType" />
        </xsd:sequence>
    </xsd:complexType>

    <xsd:complexType name="eMailType">
        <xsd:sequence>
            <xsd:element name="eMailAddress" type="xsd:string" />
            <xsd:element name="SpecialInstructions" minOccurs="0" type="specialInstructionsType" />
        </xsd:sequence>
    </xsd:complexType>

    <xsd:complexType name="addressType">
        <xsd:sequence>
            <xsd:element name="Street" type="xsd:string" minOccurs="1" maxOccurs="2" />
            <xsd:element name="City" type="xsd:string" minOccurs="1" maxOccurs="1" />
            <xsd:element name="StateProvince" type="xsd:string" minOccurs="1" maxOccurs="1" />
            <xsd:element name="PostalCode" type="xsd:string" minOccurs="0" maxOccurs="1" />
            <xsd:element name="CountryRegion" type="xsd:string" minOccurs="1" maxOccurs="1" />
            <xsd:element name="SpecialInstructions" type="specialInstructionsType" minOccurs="0"/>
        </xsd:sequence>
    </xsd:complexType>

    <xsd:element name="telephoneNumber"            type="phoneNumberType" />
    <xsd:element name="mobile"                     type="phoneNumberType" />
    <xsd:element name="pager"                      type="phoneNumberType" />
    <xsd:element name="facsimileTelephoneNumber"   type="phoneNumberType" />
    <xsd:element name="telexNumber"                type="phoneNumberType" />
    <xsd:element name="internationaliSDNNumber"    type="phoneNumberType" />
    <xsd:element name="eMail"                      type="eMailType" />
    <xsd:element name="homePostalAddress"          type="addressType" />
    <xsd:element name="physicalDeliveryOfficeName" type="addressType" />
    <xsd:element name="registeredAddress"          type="addressType" /> 
</xsd:schema>';
GO

-- Create Individual survey schema.
PRINT '';
PRINT 'Create Individual survey schema';
GO

CREATE XML SCHEMA COLLECTION [AW_Person].[IndividualSurveySchemaCollection] AS 
'<?xml version="1.0" encoding="UTF-8"?>
<xsd:schema targetNamespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey" 
    xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"
    elementFormDefault="qualified"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" >

    <xsd:simpleType name="SalaryType">
        <xsd:restriction base="xsd:string">
            <xsd:enumeration value="0-25000" />
            <xsd:enumeration value="25001-50000" />
            <xsd:enumeration value="50001-75000" />
            <xsd:enumeration value="75001-100000" />
            <xsd:enumeration value="greater than 100000" />
        </xsd:restriction>
    </xsd:simpleType>

    <xsd:simpleType name="MileRangeType">
        <xsd:restriction base="xsd:string">
            <xsd:enumeration value="0-1 Miles" />
            <xsd:enumeration value="1-2 Miles" />
            <xsd:enumeration value="2-5 Miles" />
            <xsd:enumeration value="5-10 Miles" />
            <xsd:enumeration value="10+ Miles" />
        </xsd:restriction>
    </xsd:simpleType>

    <xsd:element name="IndividualSurvey">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element name="TotalPurchaseYTD" type="xsd:decimal" minOccurs="0" maxOccurs="1" />
                <xsd:element name="DateFirstPurchase" type="xsd:date" minOccurs="0" maxOccurs="1" />
                <xsd:element name="BirthDate" type="xsd:date" minOccurs="0" maxOccurs="1" />
                <xsd:element name="MaritalStatus" type="xsd:string" minOccurs="0" maxOccurs="1" />
                <xsd:element name="YearlyIncome" type="SalaryType" minOccurs="0" maxOccurs="1" />
                <xsd:element name="Gender" type="xsd:string" minOccurs="0" maxOccurs="1" />
                <xsd:element name="TotalChildren" type="xsd:int" minOccurs="0" maxOccurs="1" />
                <xsd:element name="NumberChildrenAtHome" type="xsd:int" minOccurs="0" maxOccurs="1" />
                <xsd:element name="Education" type="xsd:string" minOccurs="0" maxOccurs="1" />
                <xsd:element name="Occupation" type="xsd:string" minOccurs="0" maxOccurs="1" />
                <xsd:element name="HomeOwnerFlag" type="xsd:string" minOccurs="0" maxOccurs="1" />
                <xsd:element name="NumberCarsOwned" type="xsd:int" minOccurs="0" maxOccurs="1" />
                <xsd:element name="Hobby" type="xsd:string" minOccurs="0" maxOccurs="unbounded" />
                <xsd:element name="CommuteDistance" type="MileRangeType" minOccurs="0" maxOccurs="1" />
                <xsd:element name="Comments" type="xsd:string" minOccurs="0" maxOccurs="1" />
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
</xsd:schema>';
GO

-- Create resume schema.
PRINT '';
PRINT 'Create Resume schema';
GO

CREATE XML SCHEMA COLLECTION [AW_HumanResources].[HRResumeSchemaCollection] AS 
'<?xml version="1.0" encoding="UTF-8"?>
<xsd:schema targetNamespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume" 
    xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
    elementFormDefault="qualified" >

    <xsd:element name="Resume" type="ResumeType"/>
    <xsd:element name="Address" type="AddressType"/>
    <xsd:element name="Education" type="EducationType"/>
    <xsd:element name="Employment" type="EmploymentType"/>
    <xsd:element name="Location" type="LocationType"/>
    <xsd:element name="Name" type="NameType"/>
    <xsd:element name="Telephone" type="TelephoneType"/>

    <xsd:complexType name="ResumeType">
        <xsd:sequence>
            <xsd:element ref="Name"/>
            <xsd:element name="Skills" type="xsd:string" minOccurs="0"/>
            <xsd:element ref="Employment" maxOccurs="unbounded"/>
            <xsd:element ref="Education" maxOccurs="unbounded"/>
            <xsd:element ref="Address" maxOccurs="unbounded"/>
            <xsd:element ref="Telephone" minOccurs="0"/>
            <xsd:element name="EMail" type="xsd:string" minOccurs="0"/>
            <xsd:element name="WebSite" type="xsd:string" minOccurs="0"/>
        </xsd:sequence>
    </xsd:complexType>

    <xsd:complexType name="AddressType">
        <xsd:sequence>
            <xsd:element name="Addr.Type" type="xsd:string">
                <xsd:annotation>
                    <xsd:documentation>Home|Work|Permanent</xsd:documentation>
                </xsd:annotation>
            </xsd:element>
            <xsd:element name="Addr.OrgName" type="xsd:string" minOccurs="0"/>
            <xsd:element name="Addr.Street" type="xsd:string" maxOccurs="unbounded"/>
            <xsd:element name="Addr.Location">
                <xsd:complexType>
                    <xsd:sequence>
                        <xsd:element ref="Location"/>
                    </xsd:sequence>
                </xsd:complexType>
            </xsd:element>
            <xsd:element name="Addr.PostalCode" type="xsd:string"/>
            <xsd:element name="Addr.Telephone" minOccurs="0">
                <xsd:complexType>
                    <xsd:sequence>
                        <xsd:element ref="Telephone" maxOccurs="unbounded"/>
                    </xsd:sequence>
                </xsd:complexType>
            </xsd:element>
        </xsd:sequence>
    </xsd:complexType>

    <xsd:complexType name="EducationType">
        <xsd:sequence>
            <xsd:element name="Edu.Level" type="xsd:string">
                <xsd:annotation>
                    <xsd:documentation>High School|Associate|Bachelor|Master|Doctorate</xsd:documentation>
                </xsd:annotation>
            </xsd:element>
            <xsd:element name="Edu.StartDate" type="xsd:date"/>
            <xsd:element name="Edu.EndDate" type="xsd:date"/>
            <xsd:element name="Edu.Degree" type="xsd:string" minOccurs="0"/>
            <xsd:element name="Edu.Major" type="xsd:string" minOccurs="0"/>
            <xsd:element name="Edu.Minor" type="xsd:string" minOccurs="0"/>
            <xsd:element name="Edu.GPA" type="xsd:string" minOccurs="0"/>
            <xsd:element name="Edu.GPAAlternate" type="xsd:decimal" minOccurs="0">
                <xsd:annotation>
                    <xsd:documentation>In case the institution does not follow a GPA system</xsd:documentation>
                </xsd:annotation>
            </xsd:element>
            <xsd:element name="Edu.GPAScale" type="xsd:decimal" minOccurs="0"/>
            <xsd:element name="Edu.School" type="xsd:string" minOccurs="0"/>
            <xsd:element name="Edu.Location" minOccurs="0">
                <xsd:complexType>
                    <xsd:sequence>
                        <xsd:element ref="Location"/>
                    </xsd:sequence>
                </xsd:complexType>
            </xsd:element>
        </xsd:sequence>
    </xsd:complexType>

    <xsd:complexType name="EmploymentType">
        <xsd:sequence>
            <xsd:element name="Emp.StartDate" type="xsd:date" minOccurs="0"/>
            <xsd:element name="Emp.EndDate" type="xsd:date" minOccurs="0"/>
            <xsd:element name="Emp.OrgName" type="xsd:string"/>
            <xsd:element name="Emp.JobTitle" type="xsd:string"/>
            <xsd:element name="Emp.Responsibility" type="xsd:string"/>
            <xsd:element name="Emp.FunctionCategory" type="xsd:string" minOccurs="0"/>
            <xsd:element name="Emp.IndustryCategory" type="xsd:string" minOccurs="0"/>
            <xsd:element name="Emp.Location" minOccurs="0">
                <xsd:complexType>
                    <xsd:sequence>
                        <xsd:element ref="Location"/>
                    </xsd:sequence>
                </xsd:complexType>
            </xsd:element>
        </xsd:sequence>
    </xsd:complexType>

    <xsd:complexType name="LocationType">
        <xsd:sequence>
            <xsd:element name="Loc.CountryRegion" type="xsd:string">
                <xsd:annotation>
                    <xsd:documentation>ISO 3166 Country Code</xsd:documentation>
                </xsd:annotation>
            </xsd:element>
            <xsd:element name="Loc.State" type="xsd:string" minOccurs="0"/>
            <xsd:element name="Loc.City" type="xsd:string" minOccurs="0"/>
        </xsd:sequence>
    </xsd:complexType>

    <xsd:complexType name="NameType">
        <xsd:sequence>
            <xsd:element name="Name.Prefix" type="xsd:string" minOccurs="0"/>
            <xsd:element name="Name.First" type="xsd:string"/>
            <xsd:element name="Name.Middle" type="xsd:string" minOccurs="0"/>
            <xsd:element name="Name.Last" type="xsd:string"/>
            <xsd:element name="Name.Suffix" type="xsd:string" minOccurs="0"/>
        </xsd:sequence>
    </xsd:complexType>

    <xsd:complexType name="TelephoneType">
        <xsd:sequence>
            <xsd:element name="Tel.Type" minOccurs="0">
                <xsd:annotation>
                    <xsd:documentation>Voice|Fax|Pager</xsd:documentation>
                </xsd:annotation>
            </xsd:element>
            <xsd:element name="Tel.IntlCode" type="xsd:int" minOccurs="0"/>
            <xsd:element name="Tel.AreaCode" type="xsd:int" minOccurs="0"/>
            <xsd:element name="Tel.Number" type="xsd:string"/>
            <xsd:element name="Tel.Extension" type="xsd:int" minOccurs="0"/>
        </xsd:sequence>
    </xsd:complexType>
</xsd:schema>';
GO

-- Create Product catalog description schema.
PRINT '';
PRINT 'Create Product catalog description schema';
GO

CREATE XML SCHEMA COLLECTION [AW_Production].[ProductDescriptionSchemaCollection] AS 
'<xsd:schema targetNamespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelWarrAndMain"
    xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelWarrAndMain" 
    elementFormDefault="qualified" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" >
  
    <xsd:element name="Warranty"  >
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element name="WarrantyPeriod" type="xsd:string"  />
                <xsd:element name="Description" type="xsd:string"  />
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>

    <xsd:element name="Maintenance"  >
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element name="NoOfYears" type="xsd:string"  />
                <xsd:element name="Description" type="xsd:string"  />
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
</xsd:schema>';

ALTER XML SCHEMA COLLECTION [AW_Production].[ProductDescriptionSchemaCollection] ADD 
'<?xml version="1.0" encoding="UTF-8"?>
<xs:schema targetNamespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription" 
    xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription" 
    elementFormDefault="qualified" 
    xmlns:mstns="http://tempuri.org/XMLSchema.xsd" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:wm="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelWarrAndMain" >

    <xs:import 
        namespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelWarrAndMain" />

    <xs:element name="ProductDescription" type="ProductDescription" />
        <xs:complexType name="ProductDescription">
            <xs:annotation>
                <xs:documentation>Product description has a summary blurb, if its manufactured elsewhere it 
                includes a link to the manufacturers site for this component.
                Then it has optional zero or more sequences of features, pictures, categories
                and technical specifications.
                </xs:documentation>
            </xs:annotation>
            <xs:sequence>
                <xs:element name="Summary" type="Summary" minOccurs="0" />
                <xs:element name="Manufacturer" type="Manufacturer" minOccurs="0" />
                <xs:element name="Features" type="Features" minOccurs="0" maxOccurs="unbounded" />
                <xs:element name="Picture" type="Picture" minOccurs="0" maxOccurs="unbounded" />
                <xs:element name="Category" type="Category" minOccurs="0" maxOccurs="unbounded" />
                <xs:element name="Specifications" type="Specifications" minOccurs="0" maxOccurs="unbounded" />
            </xs:sequence>
            <xs:attribute name="ProductModelID" type="xs:string" />
            <xs:attribute name="ProductModelName" type="xs:string" />
        </xs:complexType>
  
        <xs:complexType name="Summary" mixed="true" >
            <xs:sequence>
                <xs:any processContents="skip" namespace="http://www.w3.org/1999/xhtml" minOccurs="0" maxOccurs="unbounded" />
            </xs:sequence>
        </xs:complexType>
        
        <xs:complexType name="Manufacturer">
            <xs:sequence>
                <xs:element name="Name" type="xs:string" minOccurs="0" />
                <xs:element name="CopyrightURL" type="xs:string" minOccurs="0" />
                <xs:element name="Copyright" type="xs:string" minOccurs="0" />
                <xs:element name="ProductURL" type="xs:string" minOccurs="0" />
            </xs:sequence>
        </xs:complexType>
  
        <xs:complexType name="Picture">
            <xs:annotation>
                <xs:documentation>Pictures of the component, some standard sizes are "Large" for zoom in, "Small" for a normal web page and "Thumbnail" for product listing pages.</xs:documentation>
            </xs:annotation>
            <xs:sequence>
                <xs:element name="Name" type="xs:string" minOccurs="0" />
                <xs:element name="Angle" type="xs:string" minOccurs="0" />
                <xs:element name="Size" type="xs:string" minOccurs="0" />
                <xs:element name="ProductPhotoID" type="xs:integer" minOccurs="0" />
            </xs:sequence>
        </xs:complexType>

        <xs:annotation>
            <xs:documentation>Features of the component that are more "sales" oriented.</xs:documentation>
        </xs:annotation>

        <xs:complexType name="Features" mixed="true"  >
            <xs:sequence>
                <xs:element ref="wm:Warranty"  />
                <xs:element ref="wm:Maintenance"  />
                <xs:any processContents="skip"  namespace="##other" minOccurs="0" maxOccurs="unbounded" />
            </xs:sequence>
        </xs:complexType>

        <xs:complexType name="Specifications" mixed="true">
            <xs:annotation>
                <xs:documentation>A single technical aspect of the component.</xs:documentation>
            </xs:annotation>
            <xs:sequence>
                <xs:any processContents="skip" minOccurs="0" maxOccurs="unbounded" />
            </xs:sequence>
        </xs:complexType>

        <xs:complexType name="Category">
            <xs:annotation>
                <xs:documentation>A single categorization element that designates a classification taxonomy and a code within that classification type.  Optional description for default display if needed.</xs:documentation>
            </xs:annotation>
            <xs:sequence>
                <xs:element ref="Taxonomy" />
                <xs:element ref="Code" />
                <xs:element ref="Description" minOccurs="0" />
            </xs:sequence>
        </xs:complexType>

    <xs:element name="Taxonomy" type="xs:string" />
    <xs:element name="Code" type="xs:string" />
    <xs:element name="Description" type="xs:string" />
</xs:schema>';
GO

-- Create Manufacturing instructions schema.
PRINT '';
PRINT 'Create Manufacturing instructions schema';
GO

CREATE XML SCHEMA COLLECTION [AW_Production].[ManuInstructionsSchemaCollection] AS 
'<?xml version="1.0" encoding="UTF-8"?>
<xsd:schema targetNamespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions" 
    xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions" 
    elementFormDefault="qualified" attributeFormDefault="unqualified"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" >

    <xsd:annotation>
        <xsd:documentation>
            SetupHour   is the time it takes to set up the machine.
            MachineHour is the time the machine is busy manufcturing
            LaborHour   is the labor hours in the manu process
            LotSize     is the minimum quanity manufactured. For example,
                    no. of frames cut from the sheet metal
        </xsd:documentation>
    </xsd:annotation>

    <xsd:complexType name="StepType" mixed="true" >
        <xsd:choice  minOccurs="0" maxOccurs="unbounded" > 
            <xsd:element name="tool" type="xsd:string" />
            <xsd:element name="material" type="xsd:string" />
            <xsd:element name="blueprint" type="xsd:string" />
            <xsd:element name="specs" type="xsd:string" />
            <xsd:element name="diag" type="xsd:string" />
        </xsd:choice> 
    </xsd:complexType>

    <xsd:element  name="root">
        <xsd:complexType mixed="true">
            <xsd:sequence>
                <xsd:element name="Location" minOccurs="1" maxOccurs="unbounded">
                    <xsd:complexType mixed="true">
                        <xsd:sequence>
                            <xsd:element name="step" type="StepType" minOccurs="1" maxOccurs="unbounded" />
                        </xsd:sequence>
                        <xsd:attribute name="LocationID" type="xsd:integer" use="required"/>
                        <xsd:attribute name="SetupHours" type="xsd:decimal" use="optional"/>
                        <xsd:attribute name="MachineHours" type="xsd:decimal" use="optional"/>
                        <xsd:attribute name="LaborHours" type="xsd:decimal" use="optional"/>
                        <xsd:attribute name="LotSize" type="xsd:decimal" use="optional"/>
                    </xsd:complexType>
                </xsd:element>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
</xsd:schema>';
GO

-- Create Store survey schema.
PRINT '';
PRINT 'Create Store survey schema';
GO

CREATE XML SCHEMA COLLECTION [AW_Sales].[StoreSurveySchemaCollection] AS 
'<?xml version="1.0" encoding="UTF-8"?>
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    targetNamespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey" 
    xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey" 
    elementFormDefault="qualified" attributeFormDefault="unqualified">

    <!-- BM=Bicycle manu BS=bicyle store OS=online store SGS=sporting goods store D=Discount Store -->
    <xsd:simpleType name="BusinessType">
        <xsd:restriction base="xsd:string">
            <xsd:enumeration value="BM" />
            <xsd:enumeration value="BS" />
            <xsd:enumeration value="D" />
            <xsd:enumeration value="OS" />
            <xsd:enumeration value="SGS" />
        </xsd:restriction>
    </xsd:simpleType>

    <!-- BMX=BMX Racing -->
    <xsd:simpleType name="SpecialtyType">
        <xsd:restriction base="xsd:string">
            <xsd:enumeration value="Family" />
            <xsd:enumeration value="Kids" />
            <xsd:enumeration value="BMX" />
            <xsd:enumeration value="Touring" />
            <xsd:enumeration value="Road" />
            <xsd:enumeration value="Mountain" />
            <xsd:enumeration value="All" />
        </xsd:restriction>
    </xsd:simpleType>

    <!-- AW=AdventureWorks only 2= AdvWorks+1 other brand other brand -->
    <xsd:simpleType name="BrandType">
        <xsd:restriction base="xsd:string">
            <xsd:enumeration value="AW" />
            <xsd:enumeration value="2" />
            <xsd:enumeration value="3" />
            <xsd:enumeration value="4+" />
        </xsd:restriction>
    </xsd:simpleType>

    <xsd:simpleType name="InternetType">
        <xsd:restriction base="xsd:string">
            <xsd:enumeration value="56kb" />
            <xsd:enumeration value="ISDN" />
            <xsd:enumeration value="DSL" />
            <xsd:enumeration value="T1" />
            <xsd:enumeration value="T2" />
            <xsd:enumeration value="T3" />
        </xsd:restriction>
    </xsd:simpleType>

    <xsd:element name="StoreSurvey">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element name="ContactName" type="xsd:string" minOccurs="0" maxOccurs="1" />
                <xsd:element name="JobTitle" type="xsd:string" minOccurs="0" maxOccurs="1" />
                <xsd:element name="AnnualSales" type="xsd:decimal" minOccurs="0" maxOccurs="1" />
                <xsd:element name="AnnualRevenue" type="xsd:decimal" minOccurs="0" maxOccurs="1" />
                <xsd:element name="BankName" type="xsd:string" minOccurs="0" maxOccurs="1" />
                <xsd:element name="BusinessType" type="BusinessType" minOccurs="0" maxOccurs="1" />
                <xsd:element name="YearOpened" type="xsd:gYear" minOccurs="0" maxOccurs="1" />
                <xsd:element name="Specialty" type="SpecialtyType" minOccurs="0" maxOccurs="1" />
                <xsd:element name="SquareFeet" type="xsd:float" minOccurs="0" maxOccurs="1" />
                <xsd:element name="Brands" type="BrandType" minOccurs="0" maxOccurs="1" />
                <xsd:element name="Internet" type="InternetType" minOccurs="0" maxOccurs="1" />
                <xsd:element name="NumberEmployees" type="xsd:int" minOccurs="0" maxOccurs="1" />
                <xsd:element name="Comments" type="xsd:string" minOccurs="0" maxOccurs="1" />
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
</xsd:schema>';
GO


-- ******************************************************
-- Create tables
-- ******************************************************
PRINT '';
PRINT '*** Creating Tables';
GO

CREATE TABLE [AW_Person].[Address](
    [AddressID] [int] IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [AddressLine1] [nvarchar](60) NOT NULL, 
    [AddressLine2] [nvarchar](60) NULL, 
    [City] [nvarchar](30) NOT NULL, 
    [StateProvinceID] [int] NOT NULL,
    [PostalCode] [nvarchar](15) NOT NULL, 
	[SpatialLocation] [geography] NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_Address_rowguid] DEFAULT (NEWID()),
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Address_ModifiedDate] DEFAULT (GETDATE())
) ON [PRIMARY];
GO

CREATE TABLE [AW_Person].[AddressType](
    [AddressTypeID] [int] IDENTITY (1, 1) NOT NULL,
    [Name] [Name] NOT NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_AddressType_rowguid] DEFAULT (NEWID()),
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_AddressType_ModifiedDate] DEFAULT (GETDATE())
) ON [PRIMARY];
GO

CREATE TABLE [dbo].[AWBuildVersion](
    [SystemInformationID] [tinyint] IDENTITY (1, 1) NOT NULL,
    [Database Version] [nvarchar](25) NOT NULL, 
    [VersionDate] [datetime] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_AWBuildVersion_ModifiedDate] DEFAULT (GETDATE())
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[BillOfMaterials](
    [BillOfMaterialsID] [int] IDENTITY (1, 1) NOT NULL,
    [ProductAssemblyID] [int] NULL,
    [ComponentID] [int] NOT NULL,
    [StartDate] [datetime] NOT NULL CONSTRAINT [DF_BillOfMaterials_StartDate] DEFAULT (GETDATE()),
    [EndDate] [datetime] NULL,
    [UnitMeasureCode] [nchar](3) NOT NULL, 
    [BOMLevel] [smallint] NOT NULL,
    [PerAssemblyQty] [decimal](8, 2) NOT NULL CONSTRAINT [DF_BillOfMaterials_PerAssemblyQty] DEFAULT (1.00),
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_BillOfMaterials_ModifiedDate] DEFAULT (GETDATE()),
    CONSTRAINT [CK_BillOfMaterials_EndDate] CHECK (([EndDate] > [StartDate]) OR ([EndDate] IS NULL)),
    CONSTRAINT [CK_BillOfMaterials_ProductAssemblyID] CHECK ([ProductAssemblyID] <> [ComponentID]),
    CONSTRAINT [CK_BillOfMaterials_BOMLevel] CHECK ((([ProductAssemblyID] IS NULL) 
        AND ([BOMLevel] = 0) AND ([PerAssemblyQty] = 1.00)) 
        OR (([ProductAssemblyID] IS NOT NULL) AND ([BOMLevel] >= 1))), 
    CONSTRAINT [CK_BillOfMaterials_PerAssemblyQty] CHECK ([PerAssemblyQty] >= 1.00) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Person].[BusinessEntity](
	[BusinessEntityID] [int] IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_BusinessEntity_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_BusinessEntity_ModifiedDate] DEFAULT (GETDATE())	
) ON [PRIMARY];
GO

CREATE TABLE [AW_Person].[BusinessEntityAddress](
	[BusinessEntityID] [int] NOT NULL,
    [AddressID] [int] NOT NULL,
    [AddressTypeID] [int] NOT NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_BusinessEntityAddress_rowguid] DEFAULT (NEWID()),
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_BusinessEntityAddress_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];

CREATE TABLE [AW_Person].[BusinessEntityContact](
	[BusinessEntityID] [int] NOT NULL,
    [AW_PersonID] [int] NOT NULL,
    [ContactTypeID] [int] NOT NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_BusinessEntityContact_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_BusinessEntityContact_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Person].[ContactType](
    [ContactTypeID] [int] IDENTITY (1, 1) NOT NULL,
    [Name] [Name] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ContactType_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[CountryRegionCurrency](
    [CountryRegionCode] [nvarchar](3) NOT NULL, 
    [CurrencyCode] [nchar](3) NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_CountryRegionCurrency_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Person].[CountryRegion](
    [CountryRegionCode] [nvarchar](3) NOT NULL, 
    [Name] [Name] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_CountryRegion_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[CreditCard](
    [CreditCardID] [int] IDENTITY (1, 1) NOT NULL,
    [CardType] [nvarchar](50) NOT NULL,
    [CardNumber] [nvarchar](25) NOT NULL,
    [ExpMonth] [tinyint] NOT NULL,
    [ExpYear] [smallint] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_CreditCard_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[Culture](
    [CultureID] [nchar](6) NOT NULL,
    [Name] [Name] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Culture_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[Currency](
    [CurrencyCode] [nchar](3) NOT NULL, 
    [Name] [Name] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Currency_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[CurrencyRate](
    [CurrencyRateID] [int] IDENTITY (1, 1) NOT NULL,
    [CurrencyRateDate] [datetime] NOT NULL,    
    [FromCurrencyCode] [nchar](3) NOT NULL, 
    [ToCurrencyCode] [nchar](3) NOT NULL, 
    [AverageRate] [money] NOT NULL,
    [EndOfDayRate] [money] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_CurrencyRate_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[Customer](
	[CustomerID] [int] IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
	-- A customer may either be a AW_Person, a store, or a AW_Person who works for a store
	[AW_PersonID] [int] NULL, -- If this customer represents a AW_Person, this is non-null
    [StoreID] [int] NULL,  -- If the customer is a store, or is associated with a store then this is non-null.
    [TerritoryID] [int] NULL,
    [AccountNumber] AS ISNULL('AW' + [dbo].[ufnLeadingZeros](CustomerID), ''),
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_Customer_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Customer_ModifiedDate] DEFAULT (GETDATE())
) ON [PRIMARY];
GO

CREATE TABLE [AW_HumanResources].[Department](
    [DepartmentID] [smallint] IDENTITY (1, 1) NOT NULL,
    [Name] [Name] NOT NULL,
    [GroupName] [Name] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Department_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[Document](
    [DocumentNode] [hierarchyid] NOT NULL,
	[DocumentLevel] AS DocumentNode.GetLevel(),
    [Title] [nvarchar](50) NOT NULL, 
	[Owner] [int] NOT NULL,
	[FolderFlag] [bit] NOT NULL CONSTRAINT [DF_Document_FolderFlag] DEFAULT (0),
    [FileName] [nvarchar](400) NOT NULL, 
    [FileExtension] nvarchar(8) NOT NULL,
    [Revision] [nchar](5) NOT NULL, 
    [ChangeNumber] [int] NOT NULL CONSTRAINT [DF_Document_ChangeNumber] DEFAULT (0),
    [Status] [tinyint] NOT NULL,
    [DocumentSummary] [nvarchar](max) NULL,
    [Document] [varbinary](max)  NULL,  
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL UNIQUE CONSTRAINT [DF_Document_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Document_ModifiedDate] DEFAULT (GETDATE()),
    CONSTRAINT [CK_Document_Status] CHECK ([Status] BETWEEN 1 AND 3)
) ON [PRIMARY];
GO

CREATE TABLE [AW_Person].[EmailAddress](
	[BusinessEntityID] [int] NOT NULL,
	[EmailAddressID] [int] IDENTITY (1, 1) NOT NULL,
    [EmailAddress] [nvarchar](50) NULL, 
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_EmailAddress_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_EmailAddress_ModifiedDate] DEFAULT (GETDATE())
) ON [PRIMARY];
GO
CREATE TABLE [AW_HumanResources].[Employee](
    [BusinessEntityID] [int] NOT NULL,
    [NationalIDNumber] [nvarchar](15) NOT NULL, 
    [LoginID] [nvarchar](256) NOT NULL,     
    [OrganizationNode] [hierarchyid] NULL,
	[OrganizationLevel] AS OrganizationNode.GetLevel(),
    [JobTitle] [nvarchar](50) NOT NULL, 
    [BirthDate] [date] NOT NULL,
    [MaritalStatus] [nchar](1) NOT NULL, 
    [Gender] [nchar](1) NOT NULL, 
    [HireDate] [date] NOT NULL,
    [SalariedFlag] [Flag] NOT NULL CONSTRAINT [DF_Employee_SalariedFlag] DEFAULT (1),
    [VacationHours] [smallint] NOT NULL CONSTRAINT [DF_Employee_VacationHours] DEFAULT (0),
    [SickLeaveHours] [smallint] NOT NULL CONSTRAINT [DF_Employee_SickLeaveHours] DEFAULT (0),
    [CurrentFlag] [Flag] NOT NULL CONSTRAINT [DF_Employee_CurrentFlag] DEFAULT (1),
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_Employee_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Employee_ModifiedDate] DEFAULT (GETDATE()),
    CONSTRAINT [CK_Employee_BirthDate] CHECK ([BirthDate] BETWEEN '1930-01-01' AND DATEADD(YEAR, -18, GETDATE())),
    CONSTRAINT [CK_Employee_MaritalStatus] CHECK (UPPER([MaritalStatus]) IN ('M', 'S')), -- Married or Single
    CONSTRAINT [CK_Employee_HireDate] CHECK ([HireDate] BETWEEN '1996-07-01' AND DATEADD(DAY, 1, GETDATE())),
    CONSTRAINT [CK_Employee_Gender] CHECK (UPPER([Gender]) IN ('M', 'F')), -- Male or Female
    CONSTRAINT [CK_Employee_VacationHours] CHECK ([VacationHours] BETWEEN -40 AND 240), 
    CONSTRAINT [CK_Employee_SickLeaveHours] CHECK ([SickLeaveHours] BETWEEN 0 AND 120) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_HumanResources].[EmployeeDepartmentHistory](
    [BusinessEntityID] [int] NOT NULL,
    [DepartmentID] [smallint] NOT NULL,
    [ShiftID] [tinyint] NOT NULL,
    [StartDate] [date] NOT NULL,
    [EndDate] [date] NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_EmployeeDepartmentHistory_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_EmployeeDepartmentHistory_EndDate] CHECK (([EndDate] >= [StartDate]) OR ([EndDate] IS NULL)),
) ON [PRIMARY];
GO

CREATE TABLE [AW_HumanResources].[EmployeePayHistory](
    [BusinessEntityID] [int] NOT NULL,
    [RateChangeDate] [datetime] NOT NULL,
    [Rate] [money] NOT NULL,
    [PayFrequency] [tinyint] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_EmployeePayHistory_ModifiedDate] DEFAULT (GETDATE()),
    CONSTRAINT [CK_EmployeePayHistory_PayFrequency] CHECK ([PayFrequency] IN (1, 2)), -- 1 = monthly salary, 2 = biweekly salary
    CONSTRAINT [CK_EmployeePayHistory_Rate] CHECK ([Rate] BETWEEN 6.50 AND 200.00) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[Illustration](
    [IllustrationID] [int] IDENTITY (1, 1) NOT NULL,
    [Diagram] [XML] NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Illustration_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_HumanResources].[JobCandidate](
    [JobCandidateID] [int] IDENTITY (1, 1) NOT NULL,
    [BusinessEntityID] [int] NULL,
    [Resume] [XML]([AW_HumanResources].[HRResumeSchemaCollection]) NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_JobCandidate_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[Location](
    [LocationID] [smallint] IDENTITY (1, 1) NOT NULL,
    [Name] [Name] NOT NULL,
    [CostRate] [smallmoney] NOT NULL CONSTRAINT [DF_Location_CostRate] DEFAULT (0.00),
    [Availability] [decimal](8, 2) NOT NULL CONSTRAINT [DF_Location_Availability] DEFAULT (0.00), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Location_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_Location_CostRate] CHECK ([CostRate] >= 0.00), 
    CONSTRAINT [CK_Location_Availability] CHECK ([Availability] >= 0.00) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Person].[Password](
	[BusinessEntityID] [int] NOT NULL,
    [PasswordHash] [varchar](128) NOT NULL, 
    [PasswordSalt] [varchar](10) NOT NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_Password_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Password_ModifiedDate] DEFAULT (GETDATE())

) ON [PRIMARY];
GO

CREATE TABLE [AW_Person].[AW_Person](
    [BusinessEntityID] [int] NOT NULL,
	[AW_PersonType] [nchar](2) NOT NULL,
    [NameStyle] [NameStyle] NOT NULL CONSTRAINT [DF_AW_Person_NameStyle] DEFAULT (0),
    [Title] [nvarchar](8) NULL, 
    [FirstName] [Name] NOT NULL,
    [MiddleName] [Name] NULL,
    [LastName] [Name] NOT NULL,
    [Suffix] [nvarchar](10) NULL, 
    [EmailPromotion] [int] NOT NULL CONSTRAINT [DF_AW_Person_EmailPromotion] DEFAULT (0), 
    [AdditionalContactInfo] [XML]([AW_Person].[AdditionalContactInfoSchemaCollection]) NULL,
    [Demographics] [XML]([AW_Person].[IndividualSurveySchemaCollection]) NULL, 
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_AW_Person_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_AW_Person_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_AW_Person_EmailPromotion] CHECK ([EmailPromotion] BETWEEN 0 AND 2),
    CONSTRAINT [CK_AW_Person_AW_PersonType] CHECK ([AW_PersonType] IS NULL OR UPPER([AW_PersonType]) IN ('SC', 'VC', 'IN', 'EM', 'SP', 'GC'))
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[AW_PersonCreditCard](
    [BusinessEntityID] [int] NOT NULL,
    [CreditCardID] [int] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_AW_PersonCreditCard_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Person].[AW_PersonPhone](
    [BusinessEntityID] [int] NOT NULL,
	[PhoneNumber] [Phone] NOT NULL,
	[PhoneNumberTypeID] [int] NOT NULL,
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_AW_PersonPhone_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Person].[PhoneNumberType](
	[PhoneNumberTypeID] [int] IDENTITY (1, 1) NOT NULL,
	[Name] [Name] NOT NULL,
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_PhoneNumberType_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[Product](
    [ProductID] [int] IDENTITY (1, 1) NOT NULL,
    [Name] [Name] NOT NULL,
    [ProductNumber] [nvarchar](25) NOT NULL, 
    [MakeFlag] [Flag] NOT NULL CONSTRAINT [DF_Product_MakeFlag] DEFAULT (1),
    [FinishedGoodsFlag] [Flag] NOT NULL CONSTRAINT [DF_Product_FinishedGoodsFlag] DEFAULT (1),
    [Color] [nvarchar](15) NULL, 
    [SafetyStockLevel] [smallint] NOT NULL,
    [ReorderPoint] [smallint] NOT NULL,
    [StandardCost] [money] NOT NULL,
    [ListPrice] [money] NOT NULL,
    [Size] [nvarchar](5) NULL, 
    [SizeUnitMeasureCode] [nchar](3) NULL, 
    [WeightUnitMeasureCode] [nchar](3) NULL, 
    [Weight] [decimal](8, 2) NULL,
    [DaysToManufacture] [int] NOT NULL,
    [ProductLine] [nchar](2) NULL, 
    [Class] [nchar](2) NULL, 
    [Style] [nchar](2) NULL, 
    [ProductSubcategoryID] [int] NULL,
    [ProductModelID] [int] NULL,
    [SellStartDate] [datetime] NOT NULL,
    [SellEndDate] [datetime] NULL,
    [DiscontinuedDate] [datetime] NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_Product_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Product_ModifiedDate] DEFAULT (GETDATE()),
    CONSTRAINT [CK_Product_SafetyStockLevel] CHECK ([SafetyStockLevel] > 0),
    CONSTRAINT [CK_Product_ReorderPoint] CHECK ([ReorderPoint] > 0),
    CONSTRAINT [CK_Product_StandardCost] CHECK ([StandardCost] >= 0.00),
    CONSTRAINT [CK_Product_ListPrice] CHECK ([ListPrice] >= 0.00),
    CONSTRAINT [CK_Product_Weight] CHECK ([Weight] > 0.00),
    CONSTRAINT [CK_Product_DaysToManufacture] CHECK ([DaysToManufacture] >= 0),
    CONSTRAINT [CK_Product_ProductLine] CHECK (UPPER([ProductLine]) IN ('S', 'T', 'M', 'R') OR [ProductLine] IS NULL),
    CONSTRAINT [CK_Product_Class] CHECK (UPPER([Class]) IN ('L', 'M', 'H') OR [Class] IS NULL),
    CONSTRAINT [CK_Product_Style] CHECK (UPPER([Style]) IN ('W', 'M', 'U') OR [Style] IS NULL), 
    CONSTRAINT [CK_Product_SellEndDate] CHECK (([SellEndDate] >= [SellStartDate]) OR ([SellEndDate] IS NULL)),
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[ProductCategory](
    [ProductCategoryID] [int] IDENTITY (1, 1) NOT NULL,
    [Name] [Name] NOT NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_ProductCategory_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductCategory_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[ProductCostHistory](
    [ProductID] [int] NOT NULL,
    [StartDate] [datetime] NOT NULL,
    [EndDate] [datetime] NULL,
    [StandardCost] [money] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductCostHistory_ModifiedDate] DEFAULT (GETDATE()),
    CONSTRAINT [CK_ProductCostHistory_EndDate] CHECK (([EndDate] >= [StartDate]) OR ([EndDate] IS NULL)),
    CONSTRAINT [CK_ProductCostHistory_StandardCost] CHECK ([StandardCost] >= 0.00)
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[ProductDescription](
    [ProductDescriptionID] [int] IDENTITY (1, 1) NOT NULL,
    [Description] [nvarchar](400) NOT NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_ProductDescription_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductDescription_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[ProductDocument](
    [ProductID] [int] NOT NULL,
    [DocumentNode] [hierarchyid] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductDocument_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[ProductInventory](
    [ProductID] [int] NOT NULL,
    [LocationID] [smallint] NOT NULL,
    [Shelf] [nvarchar](10) NOT NULL, 
    [Bin] [tinyint] NOT NULL,
    [Quantity] [smallint] NOT NULL CONSTRAINT [DF_ProductInventory_Quantity] DEFAULT (0),
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_ProductInventory_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductInventory_ModifiedDate] DEFAULT (GETDATE()),
    CONSTRAINT [CK_ProductInventory_Shelf] CHECK (([Shelf] LIKE '[A-Za-z]') OR ([Shelf] = 'N/A')),
    CONSTRAINT [CK_ProductInventory_Bin] CHECK ([Bin] BETWEEN 0 AND 100)
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[ProductListPriceHistory](
    [ProductID] [int] NOT NULL,
    [StartDate] [datetime] NOT NULL,
    [EndDate] [datetime] NULL,
    [ListPrice] [money] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductListPriceHistory_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_ProductListPriceHistory_EndDate] CHECK (([EndDate] >= [StartDate]) OR ([EndDate] IS NULL)),
    CONSTRAINT [CK_ProductListPriceHistory_ListPrice] CHECK ([ListPrice] > 0.00)
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[ProductModel](
    [ProductModelID] [int] IDENTITY (1, 1) NOT NULL,
    [Name] [Name] NOT NULL,
    [CatalogDescription] [XML]([AW_Production].[ProductDescriptionSchemaCollection]) NULL,
    [Instructions] [XML]([AW_Production].[ManuInstructionsSchemaCollection]) NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_ProductModel_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductModel_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[ProductModelIllustration](
    [ProductModelID] [int] NOT NULL,
    [IllustrationID] [int] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductModelIllustration_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[ProductModelProductDescriptionCulture](
    [ProductModelID] [int] NOT NULL,
    [ProductDescriptionID] [int] NOT NULL,
    [CultureID] [nchar](6) NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductModelProductDescriptionCulture_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[ProductPhoto](
    [ProductPhotoID] [int] IDENTITY (1, 1) NOT NULL,
    [ThumbNailPhoto] [varbinary](max) NULL,
    [ThumbnailPhotoFileName] [nvarchar](50) NULL,
    [LargePhoto] [varbinary](max) NULL,
    [LargePhotoFileName] [nvarchar](50) NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductPhoto_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[ProductProductPhoto](
    [ProductID] [int] NOT NULL,
    [ProductPhotoID] [int] NOT NULL,
    [Primary] [Flag] NOT NULL CONSTRAINT [DF_ProductProductPhoto_Primary] DEFAULT (0),
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductProductPhoto_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[ProductReview](
    [ProductReviewID] [int] IDENTITY (1, 1) NOT NULL,
    [ProductID] [int] NOT NULL,
    [ReviewerName] [Name] NOT NULL,
    [ReviewDate] [datetime] NOT NULL CONSTRAINT [DF_ProductReview_ReviewDate] DEFAULT (GETDATE()),
    [EmailAddress] [nvarchar](50) NOT NULL,
    [Rating] [int] NOT NULL,
    [Comments] [nvarchar](3850), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductReview_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_ProductReview_Rating] CHECK ([Rating] BETWEEN 1 AND 5), 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[ProductSubcategory](
    [ProductSubcategoryID] [int] IDENTITY (1, 1) NOT NULL,
    [ProductCategoryID] [int] NOT NULL,
    [Name] [Name] NOT NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_ProductSubcategory_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductSubcategory_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Purchasing].[ProductVendor](
    [ProductID] [int] NOT NULL,
    [BusinessEntityID] [int] NOT NULL,
    [AverageLeadTime] [int] NOT NULL,
    [StandardPrice] [money] NOT NULL,
    [LastReceiptCost] [money] NULL,
    [LastReceiptDate] [datetime] NULL,
    [MinOrderQty] [int] NOT NULL,
    [MaxOrderQty] [int] NOT NULL,
    [OnOrderQty] [int] NULL,
    [UnitMeasureCode] [nchar](3) NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductVendor_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_ProductVendor_AverageLeadTime] CHECK ([AverageLeadTime] >= 1),
    CONSTRAINT [CK_ProductVendor_StandardPrice] CHECK ([StandardPrice] > 0.00),
    CONSTRAINT [CK_ProductVendor_LastReceiptCost] CHECK ([LastReceiptCost] > 0.00),
    CONSTRAINT [CK_ProductVendor_MinOrderQty] CHECK ([MinOrderQty] >= 1),
    CONSTRAINT [CK_ProductVendor_MaxOrderQty] CHECK ([MaxOrderQty] >= 1),
    CONSTRAINT [CK_ProductVendor_OnOrderQty] CHECK ([OnOrderQty] >= 0)
) ON [PRIMARY];
GO

CREATE TABLE [AW_Purchasing].[PurchaseOrderDetail](
    [PurchaseOrderID] [int] NOT NULL,
    [PurchaseOrderDetailID] [int] IDENTITY (1, 1) NOT NULL,
    [DueDate] [datetime] NOT NULL,
    [OrderQty] [smallint] NOT NULL,
    [ProductID] [int] NOT NULL,
    [UnitPrice] [money] NOT NULL,
    [LineTotal] AS ISNULL([OrderQty] * [UnitPrice], 0.00), 
    [ReceivedQty] [decimal](8, 2) NOT NULL,
    [RejectedQty] [decimal](8, 2) NOT NULL,
    [StockedQty] AS ISNULL([ReceivedQty] - [RejectedQty], 0.00),
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_PurchaseOrderDetail_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_PurchaseOrderDetail_OrderQty] CHECK ([OrderQty] > 0), 
    CONSTRAINT [CK_PurchaseOrderDetail_UnitPrice] CHECK ([UnitPrice] >= 0.00), 
    CONSTRAINT [CK_PurchaseOrderDetail_ReceivedQty] CHECK ([ReceivedQty] >= 0.00), 
    CONSTRAINT [CK_PurchaseOrderDetail_RejectedQty] CHECK ([RejectedQty] >= 0.00) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Purchasing].[PurchaseOrderHeader](
    [PurchaseOrderID] [int] IDENTITY (1, 1) NOT NULL, 
    [RevisionNumber] [tinyint] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_RevisionNumber] DEFAULT (0), 
    [Status] [tinyint] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_Status] DEFAULT (1), 
    [EmployeeID] [int] NOT NULL, 
    [VendorID] [int] NOT NULL, 
    [ShipMethodID] [int] NOT NULL, 
    [OrderDate] [datetime] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_OrderDate] DEFAULT (GETDATE()), 
    [ShipDate] [datetime] NULL, 
    [SubTotal] [money] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_SubTotal] DEFAULT (0.00), 
    [TaxAmt] [money] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_TaxAmt] DEFAULT (0.00), 
    [Freight] [money] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_Freight] DEFAULT (0.00), 
    [TotalDue] AS ISNULL([SubTotal] + [TaxAmt] + [Freight], 0) PERSISTED NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_PurchaseOrderHeader_Status] CHECK ([Status] BETWEEN 1 AND 4), -- 1 = Pending; 2 = Approved; 3 = Rejected; 4 = Complete 
    CONSTRAINT [CK_PurchaseOrderHeader_ShipDate] CHECK (([ShipDate] >= [OrderDate]) OR ([ShipDate] IS NULL)), 
    CONSTRAINT [CK_PurchaseOrderHeader_SubTotal] CHECK ([SubTotal] >= 0.00), 
    CONSTRAINT [CK_PurchaseOrderHeader_TaxAmt] CHECK ([TaxAmt] >= 0.00), 
    CONSTRAINT [CK_PurchaseOrderHeader_Freight] CHECK ([Freight] >= 0.00) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[SalesOrderDetail](
    [SalesOrderID] [int] NOT NULL,
    [SalesOrderDetailID] [int] IDENTITY (1, 1) NOT NULL,
    [CarrierTrackingNumber] [nvarchar](25) NULL, 
    [OrderQty] [smallint] NOT NULL,
    [ProductID] [int] NOT NULL,
    [SpecialOfferID] [int] NOT NULL,
    [UnitPrice] [money] NOT NULL,
    [UnitPriceDiscount] [money] NOT NULL CONSTRAINT [DF_SalesOrderDetail_UnitPriceDiscount] DEFAULT (0.0),
    [LineTotal] AS ISNULL([UnitPrice] * (1.0 - [UnitPriceDiscount]) * [OrderQty], 0.0),
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_SalesOrderDetail_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesOrderDetail_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_SalesOrderDetail_OrderQty] CHECK ([OrderQty] > 0), 
    CONSTRAINT [CK_SalesOrderDetail_UnitPrice] CHECK ([UnitPrice] >= 0.00), 
    CONSTRAINT [CK_SalesOrderDetail_UnitPriceDiscount] CHECK ([UnitPriceDiscount] >= 0.00) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[SalesOrderHeader](
    [SalesOrderID] [int] IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RevisionNumber] [tinyint] NOT NULL CONSTRAINT [DF_SalesOrderHeader_RevisionNumber] DEFAULT (0),
    [OrderDate] [datetime] NOT NULL CONSTRAINT [DF_SalesOrderHeader_OrderDate] DEFAULT (GETDATE()),
    [DueDate] [datetime] NOT NULL,
    [ShipDate] [datetime] NULL,
    [Status] [tinyint] NOT NULL CONSTRAINT [DF_SalesOrderHeader_Status] DEFAULT (1),
    [OnlineOrderFlag] [Flag] NOT NULL CONSTRAINT [DF_SalesOrderHeader_OnlineOrderFlag] DEFAULT (1),
    [SalesOrderNumber] AS ISNULL(N'SO' + CONVERT(nvarchar(23), [SalesOrderID]), N'*** ERROR ***'), 
    [PurchaseOrderNumber] [OrderNumber] NULL,
    [AccountNumber] [AccountNumber] NULL,
    [CustomerID] [int] NOT NULL,
    [SalesAW_PersonID] [int] NULL,
    [TerritoryID] [int] NULL,
    [BillToAddressID] [int] NOT NULL,
    [ShipToAddressID] [int] NOT NULL,
    [ShipMethodID] [int] NOT NULL,
    [CreditCardID] [int] NULL,
    [CreditCardApprovalCode] [varchar](15) NULL,    
    [CurrencyRateID] [int] NULL,
    [SubTotal] [money] NOT NULL CONSTRAINT [DF_SalesOrderHeader_SubTotal] DEFAULT (0.00),
    [TaxAmt] [money] NOT NULL CONSTRAINT [DF_SalesOrderHeader_TaxAmt] DEFAULT (0.00),
    [Freight] [money] NOT NULL CONSTRAINT [DF_SalesOrderHeader_Freight] DEFAULT (0.00),
    [TotalDue] AS ISNULL([SubTotal] + [TaxAmt] + [Freight], 0),
    [Comment] [nvarchar](128) NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_SalesOrderHeader_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesOrderHeader_ModifiedDate] DEFAULT (GETDATE()),
    CONSTRAINT [CK_SalesOrderHeader_Status] CHECK ([Status] BETWEEN 0 AND 8), 
    CONSTRAINT [CK_SalesOrderHeader_DueDate] CHECK ([DueDate] >= [OrderDate]), 
    CONSTRAINT [CK_SalesOrderHeader_ShipDate] CHECK (([ShipDate] >= [OrderDate]) OR ([ShipDate] IS NULL)), 
    CONSTRAINT [CK_SalesOrderHeader_SubTotal] CHECK ([SubTotal] >= 0.00), 
    CONSTRAINT [CK_SalesOrderHeader_TaxAmt] CHECK ([TaxAmt] >= 0.00), 
    CONSTRAINT [CK_SalesOrderHeader_Freight] CHECK ([Freight] >= 0.00) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[SalesOrderHeaderSalesReason](
    [SalesOrderID] [int] NOT NULL,
    [SalesReasonID] [int] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesOrderHeaderSalesReason_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[SalesAW_Person](
    [BusinessEntityID] [int] NOT NULL,
    [TerritoryID] [int] NULL,
    [SalesQuota] [money] NULL,
    [Bonus] [money] NOT NULL CONSTRAINT [DF_SalesAW_Person_Bonus] DEFAULT (0.00),
    [CommissionPct] [smallmoney] NOT NULL CONSTRAINT [DF_SalesAW_Person_CommissionPct] DEFAULT (0.00),
    [SalesYTD] [money] NOT NULL CONSTRAINT [DF_SalesAW_Person_SalesYTD] DEFAULT (0.00),
    [SalesLastYear] [money] NOT NULL CONSTRAINT [DF_SalesAW_Person_SalesLastYear] DEFAULT (0.00),
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_SalesAW_Person_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesAW_Person_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_SalesAW_Person_SalesQuota] CHECK ([SalesQuota] > 0.00), 
    CONSTRAINT [CK_SalesAW_Person_Bonus] CHECK ([Bonus] >= 0.00), 
    CONSTRAINT [CK_SalesAW_Person_CommissionPct] CHECK ([CommissionPct] >= 0.00), 
    CONSTRAINT [CK_SalesAW_Person_SalesYTD] CHECK ([SalesYTD] >= 0.00), 
    CONSTRAINT [CK_SalesAW_Person_SalesLastYear] CHECK ([SalesLastYear] >= 0.00) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[SalesAW_PersonQuotaHistory](
    [BusinessEntityID] [int] NOT NULL,
    [QuotaDate] [datetime] NOT NULL,
    [SalesQuota] [money] NOT NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_SalesAW_PersonQuotaHistory_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesAW_PersonQuotaHistory_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_SalesAW_PersonQuotaHistory_SalesQuota] CHECK ([SalesQuota] > 0.00) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[SalesReason](
    [SalesReasonID] [int] IDENTITY (1, 1) NOT NULL,
    [Name] [Name] NOT NULL,
    [ReasonType] [Name] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesReason_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[SalesTaxRate](
    [SalesTaxRateID] [int] IDENTITY (1, 1) NOT NULL,
    [StateProvinceID] [int] NOT NULL,
    [TaxType] [tinyint] NOT NULL,
    [TaxRate] [smallmoney] NOT NULL CONSTRAINT [DF_SalesTaxRate_TaxRate] DEFAULT (0.00),
    [Name] [Name] NOT NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_SalesTaxRate_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesTaxRate_ModifiedDate] DEFAULT (GETDATE()),
    CONSTRAINT [CK_SalesTaxRate_TaxType] CHECK ([TaxType] BETWEEN 1 AND 3)
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[SalesTerritory](
    [TerritoryID] [int] IDENTITY (1, 1) NOT NULL,
    [Name] [Name] NOT NULL,
    [CountryRegionCode] [nvarchar](3) NOT NULL, 
    [Group] [nvarchar](50) NOT NULL,
    [SalesYTD] [money] NOT NULL CONSTRAINT [DF_SalesTerritory_SalesYTD] DEFAULT (0.00),
    [SalesLastYear] [money] NOT NULL CONSTRAINT [DF_SalesTerritory_SalesLastYear] DEFAULT (0.00),
    [CostYTD] [money] NOT NULL CONSTRAINT [DF_SalesTerritory_CostYTD] DEFAULT (0.00),
    [CostLastYear] [money] NOT NULL CONSTRAINT [DF_SalesTerritory_CostLastYear] DEFAULT (0.00),
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_SalesTerritory_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesTerritory_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_SalesTerritory_SalesYTD] CHECK ([SalesYTD] >= 0.00), 
    CONSTRAINT [CK_SalesTerritory_SalesLastYear] CHECK ([SalesLastYear] >= 0.00), 
    CONSTRAINT [CK_SalesTerritory_CostYTD] CHECK ([CostYTD] >= 0.00), 
    CONSTRAINT [CK_SalesTerritory_CostLastYear] CHECK ([CostLastYear] >= 0.00) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[SalesTerritoryHistory](
    [BusinessEntityID] [int] NOT NULL,  -- A sales AW_Person
    [TerritoryID] [int] NOT NULL,
    [StartDate] [datetime] NOT NULL,
    [EndDate] [datetime] NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_SalesTerritoryHistory_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesTerritoryHistory_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_SalesTerritoryHistory_EndDate] CHECK (([EndDate] >= [StartDate]) OR ([EndDate] IS NULL))
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[ScrapReason](
    [ScrapReasonID] [smallint] IDENTITY (1, 1) NOT NULL,
    [Name] [Name] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ScrapReason_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_HumanResources].[Shift](
    [ShiftID] [tinyint] IDENTITY (1, 1) NOT NULL,
    [Name] [Name] NOT NULL,
    [StartTime] [time] NOT NULL,
    [EndTime] [time] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Shift_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Purchasing].[ShipMethod](
    [ShipMethodID] [int] IDENTITY (1, 1) NOT NULL,
    [Name] [Name] NOT NULL,
    [ShipBase] [money] NOT NULL CONSTRAINT [DF_ShipMethod_ShipBase] DEFAULT (0.00),
    [ShipRate] [money] NOT NULL CONSTRAINT [DF_ShipMethod_ShipRate] DEFAULT (0.00),
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_ShipMethod_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ShipMethod_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_ShipMethod_ShipBase] CHECK ([ShipBase] > 0.00), 
    CONSTRAINT [CK_ShipMethod_ShipRate] CHECK ([ShipRate] > 0.00), 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[ShoppingCartItem](
    [ShoppingCartItemID] [int] IDENTITY (1, 1) NOT NULL,
    [ShoppingCartID] [nvarchar](50) NOT NULL,
    [Quantity] [int] NOT NULL CONSTRAINT [DF_ShoppingCartItem_Quantity] DEFAULT (1),
    [ProductID] [int] NOT NULL,
    [DateCreated] [datetime] NOT NULL CONSTRAINT [DF_ShoppingCartItem_DateCreated] DEFAULT (GETDATE()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ShoppingCartItem_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_ShoppingCartItem_Quantity] CHECK ([Quantity] >= 1) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[SpecialOffer](
    [SpecialOfferID] [int] IDENTITY (1, 1) NOT NULL,
    [Description] [nvarchar](255) NOT NULL,
    [DiscountPct] [smallmoney] NOT NULL CONSTRAINT [DF_SpecialOffer_DiscountPct] DEFAULT (0.00),
    [Type] [nvarchar](50) NOT NULL,
    [Category] [nvarchar](50) NOT NULL,
    [StartDate] [datetime] NOT NULL,
    [EndDate] [datetime] NOT NULL,
    [MinQty] [int] NOT NULL CONSTRAINT [DF_SpecialOffer_MinQty] DEFAULT (0), 
    [MaxQty] [int] NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_SpecialOffer_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SpecialOffer_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_SpecialOffer_EndDate] CHECK ([EndDate] >= [StartDate]), 
    CONSTRAINT [CK_SpecialOffer_DiscountPct] CHECK ([DiscountPct] >= 0.00), 
    CONSTRAINT [CK_SpecialOffer_MinQty] CHECK ([MinQty] >= 0), 
    CONSTRAINT [CK_SpecialOffer_MaxQty]  CHECK ([MaxQty] >= 0)
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[SpecialOfferProduct](
    [SpecialOfferID] [int] NOT NULL,
    [ProductID] [int] NOT NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_SpecialOfferProduct_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SpecialOfferProduct_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Person].[StateProvince](
    [StateProvinceID] [int] IDENTITY (1, 1) NOT NULL,
    [StateProvinceCode] [nchar](3) NOT NULL, 
    [CountryRegionCode] [nvarchar](3) NOT NULL, 
    [IsOnlyStateProvinceFlag] [Flag] NOT NULL CONSTRAINT [DF_StateProvince_IsOnlyStateProvinceFlag] DEFAULT (1),
    [Name] [Name] NOT NULL,
    [TerritoryID] [int] NOT NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_StateProvince_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_StateProvince_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Sales].[Store](
    [BusinessEntityID] [int] NOT NULL,
    [Name] [Name] NOT NULL,
    [SalesAW_PersonID] [int] NULL,
    [Demographics] [XML]([AW_Sales].[StoreSurveySchemaCollection]) NULL,
    [rowguid] uniqueidentifier ROWGUIDCOL NOT NULL CONSTRAINT [DF_Store_rowguid] DEFAULT (NEWID()), 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Store_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[TransactionHistory](
    [TransactionID] [int] IDENTITY (100000, 1) NOT NULL,
    [ProductID] [int] NOT NULL,
    [ReferenceOrderID] [int] NOT NULL,
    [ReferenceOrderLineID] [int] NOT NULL CONSTRAINT [DF_TransactionHistory_ReferenceOrderLineID] DEFAULT (0),
    [TransactionDate] [datetime] NOT NULL CONSTRAINT [DF_TransactionHistory_TransactionDate] DEFAULT (GETDATE()),
    [TransactionType] [nchar](1) NOT NULL, 
    [Quantity] [int] NOT NULL,
    [ActualCost] [money] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_TransactionHistory_ModifiedDate] DEFAULT (GETDATE()),
    CONSTRAINT [CK_TransactionHistory_TransactionType] CHECK (UPPER([TransactionType]) IN ('W', 'S', 'P'))
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[TransactionHistoryArchive](
    [TransactionID] [int] NOT NULL,
    [ProductID] [int] NOT NULL,
    [ReferenceOrderID] [int] NOT NULL,
    [ReferenceOrderLineID] [int] NOT NULL CONSTRAINT [DF_TransactionHistoryArchive_ReferenceOrderLineID] DEFAULT (0),
    [TransactionDate] [datetime] NOT NULL CONSTRAINT [DF_TransactionHistoryArchive_TransactionDate] DEFAULT (GETDATE()),
    [TransactionType] [nchar](1) NOT NULL, 
    [Quantity] [int] NOT NULL,
    [ActualCost] [money] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_TransactionHistoryArchive_ModifiedDate] DEFAULT (GETDATE()),
    CONSTRAINT [CK_TransactionHistoryArchive_TransactionType] CHECK (UPPER([TransactionType]) IN ('W', 'S', 'P'))
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[UnitMeasure](
    [UnitMeasureCode] [nchar](3) NOT NULL, 
    [Name] [Name] NOT NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_UnitMeasure_ModifiedDate] DEFAULT (GETDATE()) 
) ON [PRIMARY];
GO

CREATE TABLE [AW_Purchasing].[Vendor](
    [BusinessEntityID] [int] NOT NULL,
    [AccountNumber] [AccountNumber] NOT NULL,
    [Name] [Name] NOT NULL,
    [CreditRating] [tinyint] NOT NULL,
    [PreferredVendorStatus] [Flag] NOT NULL CONSTRAINT [DF_Vendor_PreferredVendorStatus] DEFAULT (1), 
    [ActiveFlag] [Flag] NOT NULL CONSTRAINT [DF_Vendor_ActiveFlag] DEFAULT (1),
    [PurchasingWebServiceURL] [nvarchar](1024) NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Vendor_ModifiedDate] DEFAULT (GETDATE()),
    CONSTRAINT [CK_Vendor_CreditRating] CHECK ([CreditRating] BETWEEN 1 AND 5)
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[WorkOrder](
    [WorkOrderID] [int] IDENTITY (1, 1) NOT NULL,
    [ProductID] [int] NOT NULL,
    [OrderQty] [int] NOT NULL,
    [StockedQty] AS ISNULL([OrderQty] - [ScrappedQty], 0),
    [ScrappedQty] [smallint] NOT NULL,
    [StartDate] [datetime] NOT NULL,
    [EndDate] [datetime] NULL,
    [DueDate] [datetime] NOT NULL,
    [ScrapReasonID] [smallint] NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrder_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_WorkOrder_OrderQty] CHECK ([OrderQty] > 0), 
    CONSTRAINT [CK_WorkOrder_ScrappedQty] CHECK ([ScrappedQty] >= 0), 
    CONSTRAINT [CK_WorkOrder_EndDate] CHECK (([EndDate] >= [StartDate]) OR ([EndDate] IS NULL))
) ON [PRIMARY];
GO

CREATE TABLE [AW_Production].[WorkOrderRouting](
    [WorkOrderID] [int] NOT NULL,
    [ProductID] [int] NOT NULL,
    [OperationSequence] [smallint] NOT NULL,
    [LocationID] [smallint] NOT NULL,
    [ScheduledStartDate] [datetime] NOT NULL,
    [ScheduledEndDate] [datetime] NOT NULL,
    [ActualStartDate] [datetime] NULL,
    [ActualEndDate] [datetime] NULL,
    [ActualResourceHrs] [decimal](9, 4) NULL,
    [PlannedCost] [money] NOT NULL,
    [ActualCost] [money] NULL, 
    [ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderRouting_ModifiedDate] DEFAULT (GETDATE()), 
    CONSTRAINT [CK_WorkOrderRouting_ScheduledEndDate] CHECK ([ScheduledEndDate] >= [ScheduledStartDate]), 
    CONSTRAINT [CK_WorkOrderRouting_ActualEndDate] CHECK (([ActualEndDate] >= [ActualStartDate]) 
        OR ([ActualEndDate] IS NULL) OR ([ActualStartDate] IS NULL)), 
    CONSTRAINT [CK_WorkOrderRouting_ActualResourceHrs] CHECK ([ActualResourceHrs] >= 0.0000), 
    CONSTRAINT [CK_WorkOrderRouting_PlannedCost] CHECK ([PlannedCost] > 0.00), 
    CONSTRAINT [CK_WorkOrderRouting_ActualCost] CHECK ([ActualCost] > 0.00) 
) ON [PRIMARY];
GO


-- ******************************************************
-- Load data
-- ******************************************************
PRINT '';
PRINT '*** Loading Data';
GO

PRINT 'Loading [AW_Person].[Address]';

BULK INSERT [AW_Person].[Address] FROM '$(SqlSamplesSourceDataPath)Address.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE = 'char',
    FIELDTERMINATOR= '\t',
    ROWTERMINATOR = '\n',
    KEEPIDENTITY,
    TABLOCK
);


PRINT 'Loading [AW_Person].[AddressType]';

BULK INSERT [AW_Person].[AddressType] FROM '$(SqlSamplesSourceDataPath)AddressType.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE = 'char',
    FIELDTERMINATOR= '\t',
    ROWTERMINATOR = '\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [dbo].[AWBuildVersion]';



INSERT INTO [dbo].[AWBuildVersion] 
VALUES
( CONVERT(nvarchar(25), SERVERPROPERTY('ProductVersion')), CONVERT(datetime, SERVERPROPERTY('ResourceLastUpdateDateTime')), CONVERT(datetime, GETDATE()) );


PRINT 'Loading [AW_Production].[BillOfMaterials]';

BULK INSERT [AW_Production].[BillOfMaterials] FROM '$(SqlSamplesSourceDataPath)BillOfMaterials.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE = 'char',
    FIELDTERMINATOR= '\t',
    ROWTERMINATOR = '\n',
    KEEPIDENTITY,
    TABLOCK
);


PRINT 'Loading [AW_Person].[BusinessEntity]';

BULK INSERT [AW_Person].[BusinessEntity] FROM '$(SqlSamplesSourceDataPath)BusinessEntity.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='+|',
    ROWTERMINATOR='&|\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Person].[BusinessEntityAddress]';

BULK INSERT [AW_Person].[BusinessEntityAddress] FROM '$(SqlSamplesSourceDataPath)BusinessEntityAddress.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='+|',
    ROWTERMINATOR='&|\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Person].[BusinessEntityContact]';

BULK INSERT [AW_Person].[BusinessEntityContact] FROM '$(SqlSamplesSourceDataPath)BusinessEntityContact.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='+|',
    ROWTERMINATOR='&|\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Person].[ContactType]';

BULK INSERT [AW_Person].[ContactType] FROM '$(SqlSamplesSourceDataPath)ContactType.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Person].[CountryRegion]';

BULK INSERT [AW_Person].[CountryRegion] FROM '$(SqlSamplesSourceDataPath)CountryRegion.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Sales].[CountryRegionCurrency]';

BULK INSERT [AW_Sales].[CountryRegionCurrency] FROM '$(SqlSamplesSourceDataPath)CountryRegionCurrency.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Sales].[CreditCard]';

BULK INSERT [AW_Sales].[CreditCard] FROM '$(SqlSamplesSourceDataPath)CreditCard.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Production].[Culture]';

BULK INSERT [AW_Production].[Culture] FROM '$(SqlSamplesSourceDataPath)Culture.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Sales].[Currency]';

BULK INSERT [AW_Sales].[Currency] FROM '$(SqlSamplesSourceDataPath)Currency.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Sales].[CurrencyRate]';

BULK INSERT [AW_Sales].[CurrencyRate] FROM '$(SqlSamplesSourceDataPath)CurrencyRate.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);


PRINT 'Loading [AW_Sales].[Customer]';

BULK INSERT [AW_Sales].[Customer] FROM '$(SqlSamplesSourceDataPath)Customer.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);



PRINT 'Loading [AW_HumanResources].[Department]';

BULK INSERT [AW_HumanResources].[Department] FROM '$(SqlSamplesSourceDataPath)Department.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

 
PRINT 'Loading [AW_Production].[Document]';

BULK INSERT [AW_Production].[Document] FROM '$(SqlSamplesSourceDataPath)Document.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='+|',
    ROWTERMINATOR='&|\n',
    KEEPIDENTITY,
    TABLOCK   
);


PRINT 'Loading [AW_Person].[EmailAddress]';

BULK INSERT [AW_Person].[EmailAddress] FROM '$(SqlSamplesSourceDataPath)EmailAddress.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='+|',
    ROWTERMINATOR='&|\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_HumanResources].[Employee]';

BULK INSERT [AW_HumanResources].[Employee] FROM '$(SqlSamplesSourceDataPath)Employee.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_HumanResources].[EmployeeDepartmentHistory]';

BULK INSERT [AW_HumanResources].[EmployeeDepartmentHistory] FROM '$(SqlSamplesSourceDataPath)EmployeeDepartmentHistory.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_HumanResources].[EmployeePayHistory]';

BULK INSERT [AW_HumanResources].[EmployeePayHistory] FROM '$(SqlSamplesSourceDataPath)EmployeePayHistory.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);


PRINT 'Loading [AW_Production].[Illustration]';

BULK INSERT [AW_Production].[Illustration] FROM '$(SqlSamplesSourceDataPath)Illustration.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='+|',
    ROWTERMINATOR='&|\n',
    KEEPIDENTITY,
    TABLOCK
);


PRINT 'Loading [AW_HumanResources].[JobCandidate]';

BULK INSERT [AW_HumanResources].[JobCandidate] FROM '$(SqlSamplesSourceDataPath)JobCandidate.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='+|',
    ROWTERMINATOR='&|\n',
    KEEPIDENTITY,
    TABLOCK
);



PRINT 'Loading [AW_Production].[Location]';

BULK INSERT [AW_Production].[Location] FROM '$(SqlSamplesSourceDataPath)Location.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);


PRINT 'Loading [AW_Person].[Password]';

BULK INSERT [AW_Person].[Password] FROM '$(SqlSamplesSourceDataPath)Password.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='+|',
    ROWTERMINATOR='&|\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Person].[AW_Person]';

BULK INSERT [AW_Person].[AW_Person] FROM '$(SqlSamplesSourceDataPath)AW_Person.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='+|',
    ROWTERMINATOR='&|\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Sales].[AW_PersonCreditCard]';

BULK INSERT [AW_Sales].[AW_PersonCreditCard] FROM '$(SqlSamplesSourceDataPath)AW_PersonCreditCard.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Person].[AW_PersonPhone]';

BULK INSERT [AW_Person].[AW_PersonPhone] FROM '$(SqlSamplesSourceDataPath)AW_PersonPhone.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='+|',
    ROWTERMINATOR='&|\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Person].[PhoneNumberType]';

BULK INSERT [AW_Person].[PhoneNumberType] FROM '$(SqlSamplesSourceDataPath)PhoneNumberType.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='+|',
    ROWTERMINATOR='&|\n',
    KEEPIDENTITY,
    TABLOCK
);


PRINT 'Loading [AW_Production].[Product]';

BULK INSERT [AW_Production].[Product] FROM '$(SqlSamplesSourceDataPath)Product.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Production].[ProductCategory]';

BULK INSERT [AW_Production].[ProductCategory] FROM '$(SqlSamplesSourceDataPath)ProductCategory.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Production].[ProductCostHistory]';

BULK INSERT [AW_Production].[ProductCostHistory] FROM '$(SqlSamplesSourceDataPath)ProductCostHistory.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Production].[ProductDescription]';

BULK INSERT [AW_Production].[ProductDescription] FROM '$(SqlSamplesSourceDataPath)ProductDescription.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Production].[ProductDocument]';

BULK INSERT [AW_Production].[ProductDocument] FROM '$(SqlSamplesSourceDataPath)ProductDocument.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK   
);

PRINT 'Loading [AW_Production].[ProductInventory]';

BULK INSERT [AW_Production].[ProductInventory] FROM '$(SqlSamplesSourceDataPath)ProductInventory.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Production].[ProductListPriceHistory]';

BULK INSERT [AW_Production].[ProductListPriceHistory] FROM '$(SqlSamplesSourceDataPath)ProductListPriceHistory.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Production].[ProductModel]';

BULK INSERT [AW_Production].[ProductModel] FROM '$(SqlSamplesSourceDataPath)ProductModel.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='+|',
    ROWTERMINATOR='&|\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Production].[ProductModelIllustration]';

BULK INSERT [AW_Production].[ProductModelIllustration] FROM '$(SqlSamplesSourceDataPath)ProductModelIllustration.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Production].[ProductModelProductDescriptionCulture]';

BULK INSERT [AW_Production].[ProductModelProductDescriptionCulture] FROM '$(SqlSamplesSourceDataPath)ProductModelProductDescriptionCulture.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Production].[ProductPhoto]';

BULK INSERT [AW_Production].[ProductPhoto] FROM '$(SqlSamplesSourceDataPath)ProductPhoto.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='+|',
    ROWTERMINATOR='&|\n',
    KEEPIDENTITY,
    TABLOCK   
);

PRINT 'Loading [AW_Production].[ProductProductPhoto]';

BULK INSERT [AW_Production].[ProductProductPhoto] FROM '$(SqlSamplesSourceDataPath)ProductProductPhoto.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Production].[ProductReview]';

BULK INSERT [AW_Production].[ProductReview] FROM '$(SqlSamplesSourceDataPath)ProductReview.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Production].[ProductSubcategory]';

BULK INSERT [AW_Production].[ProductSubcategory] FROM '$(SqlSamplesSourceDataPath)ProductSubcategory.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);


PRINT 'Loading [AW_Purchasing].[ProductVendor]';

BULK INSERT [AW_Purchasing].[ProductVendor] FROM '$(SqlSamplesSourceDataPath)ProductVendor.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);


PRINT 'Loading [AW_Purchasing].[PurchaseOrderDetail]';

BULK INSERT [AW_Purchasing].[PurchaseOrderDetail] FROM '$(SqlSamplesSourceDataPath)PurchaseOrderDetail.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Purchasing].[PurchaseOrderHeader]';

BULK INSERT [AW_Purchasing].[PurchaseOrderHeader] FROM '$(SqlSamplesSourceDataPath)PurchaseOrderHeader.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Sales].[SalesOrderDetail]';

BULK INSERT [AW_Sales].[SalesOrderDetail] FROM '$(SqlSamplesSourceDataPath)SalesOrderDetail.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Sales].[SalesOrderHeader]';

BULK INSERT [AW_Sales].[SalesOrderHeader] FROM '$(SqlSamplesSourceDataPath)SalesOrderHeader.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);


PRINT 'Loading [AW_Sales].[SalesOrderHeaderSalesReason]';

BULK INSERT [AW_Sales].[SalesOrderHeaderSalesReason] FROM '$(SqlSamplesSourceDataPath)SalesOrderHeaderSalesReason.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);


PRINT 'Loading [AW_Sales].[SalesAW_Person]';

BULK INSERT [AW_Sales].[SalesAW_Person] FROM '$(SqlSamplesSourceDataPath)SalesAW_Person.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);


PRINT 'Loading [AW_Sales].[SalesAW_PersonQuotaHistory]';

BULK INSERT [AW_Sales].[SalesAW_PersonQuotaHistory] FROM '$(SqlSamplesSourceDataPath)SalesAW_PersonQuotaHistory.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);


PRINT 'Loading [AW_Sales].[SalesReason]';

BULK INSERT [AW_Sales].[SalesReason] FROM '$(SqlSamplesSourceDataPath)SalesReason.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Sales].[SalesTaxRate]';

BULK INSERT [AW_Sales].[SalesTaxRate] FROM '$(SqlSamplesSourceDataPath)SalesTaxRate.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Sales].[SalesTerritory]';

BULK INSERT [AW_Sales].[SalesTerritory] FROM '$(SqlSamplesSourceDataPath)SalesTerritory.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Sales].[SalesTerritoryHistory]';

BULK INSERT [AW_Sales].[SalesTerritoryHistory] FROM '$(SqlSamplesSourceDataPath)SalesTerritoryHistory.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);


PRINT 'Loading [AW_Production].[ScrapReason]';

BULK INSERT [AW_Production].[ScrapReason] FROM '$(SqlSamplesSourceDataPath)ScrapReason.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_HumanResources].[Shift]';

BULK INSERT [AW_HumanResources].[Shift] FROM '$(SqlSamplesSourceDataPath)Shift.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Purchasing].[ShipMethod]';

BULK INSERT [AW_Purchasing].[ShipMethod] FROM '$(SqlSamplesSourceDataPath)ShipMethod.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Sales].[ShoppingCartItem]';

BULK INSERT [AW_Sales].[ShoppingCartItem] FROM '$(SqlSamplesSourceDataPath)ShoppingCartItem.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Sales].[SpecialOffer]';

BULK INSERT [AW_Sales].[SpecialOffer] FROM '$(SqlSamplesSourceDataPath)SpecialOffer.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Sales].[SpecialOfferProduct]';

BULK INSERT [AW_Sales].[SpecialOfferProduct] FROM '$(SqlSamplesSourceDataPath)SpecialOfferProduct.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Person].[StateProvince]';

BULK INSERT [AW_Person].[StateProvince] FROM '$(SqlSamplesSourceDataPath)StateProvince.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Sales].[Store]';

BULK INSERT [AW_Sales].[Store] FROM '$(SqlSamplesSourceDataPath)Store.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='+|',
    ROWTERMINATOR='&|\n',
    KEEPIDENTITY,
    TABLOCK
);


PRINT 'Loading [AW_Production].[TransactionHistory]';

BULK INSERT [AW_Production].[TransactionHistory] FROM '$(SqlSamplesSourceDataPath)TransactionHistory.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    TABLOCK
);

PRINT 'Loading [AW_Production].[TransactionHistoryArchive]';

BULK INSERT [AW_Production].[TransactionHistoryArchive] FROM '$(SqlSamplesSourceDataPath)TransactionHistoryArchive.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Production].[UnitMeasure]';

BULK INSERT [AW_Production].[UnitMeasure] FROM '$(SqlSamplesSourceDataPath)UnitMeasure.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Purchasing].[Vendor]';

BULK INSERT [AW_Purchasing].[Vendor] FROM '$(SqlSamplesSourceDataPath)Vendor.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Production].[WorkOrder]';

BULK INSERT [AW_Production].[WorkOrder] FROM '$(SqlSamplesSourceDataPath)WorkOrder.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

PRINT 'Loading [AW_Production].[WorkOrderRouting]';

BULK INSERT [AW_Production].[WorkOrderRouting] FROM '$(SqlSamplesSourceDataPath)WorkOrderRouting.csv'
WITH (
    -- CHECK_CONSTRAINTS,
    -- CODEPAGE='ACP',
    DATAFILETYPE='char',
    FIELDTERMINATOR='\t',
    ROWTERMINATOR='\n',
    KEEPIDENTITY,
    TABLOCK
);

GO



-- ******************************************************
-- Add Primary Keys
-- ******************************************************
PRINT '';
PRINT '*** Adding Primary Keys';
GO

SET QUOTED_IDENTIFIER ON;

ALTER TABLE [AW_Person].[Address] WITH CHECK ADD 
    CONSTRAINT [PK_Address_AddressID] PRIMARY KEY CLUSTERED 
    (
        [AddressID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Person].[AddressType] WITH CHECK ADD 
    CONSTRAINT [PK_AddressType_AddressTypeID] PRIMARY KEY CLUSTERED 
    (
        [AddressTypeID]
    )  ON [PRIMARY];
GO

ALTER TABLE [dbo].[AWBuildVersion] WITH CHECK ADD 
    CONSTRAINT [PK_AWBuildVersion_SystemInformationID] PRIMARY KEY CLUSTERED 
    (
        [SystemInformationID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[BillOfMaterials] WITH CHECK ADD 
    CONSTRAINT [PK_BillOfMaterials_BillOfMaterialsID] PRIMARY KEY NONCLUSTERED
    (
        [BillOfMaterialsID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Person].[BusinessEntity] WITH CHECK ADD 
    CONSTRAINT [PK_BusinessEntity_BusinessEntityID] PRIMARY KEY CLUSTERED 
    (
        [BusinessEntityID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Person].[BusinessEntityAddress] WITH CHECK ADD 
    CONSTRAINT [PK_BusinessEntityAddress_BusinessEntityID_AddressID_AddressTypeID] PRIMARY KEY CLUSTERED 
    (
        [BusinessEntityID],
		[AddressID],
		[AddressTypeID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Person].[BusinessEntityContact] WITH CHECK ADD 
    CONSTRAINT [PK_BusinessEntityContact_BusinessEntityID_AW_PersonID_ContactTypeID] PRIMARY KEY CLUSTERED 
    (
        [BusinessEntityID],
		[AW_PersonID],
		[ContactTypeID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Person].[ContactType] WITH CHECK ADD 
    CONSTRAINT [PK_ContactType_ContactTypeID] PRIMARY KEY CLUSTERED 
    (
        [ContactTypeID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[CountryRegionCurrency] WITH CHECK ADD 
    CONSTRAINT [PK_CountryRegionCurrency_CountryRegionCode_CurrencyCode] PRIMARY KEY CLUSTERED 
    (
        [CountryRegionCode],
        [CurrencyCode]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Person].[CountryRegion] WITH CHECK ADD 
    CONSTRAINT [PK_CountryRegion_CountryRegionCode] PRIMARY KEY CLUSTERED 
    (
        [CountryRegionCode]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[CreditCard] WITH CHECK ADD 
    CONSTRAINT [PK_CreditCard_CreditCardID] PRIMARY KEY CLUSTERED 
    (
        [CreditCardID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[Culture] WITH CHECK ADD 
    CONSTRAINT [PK_Culture_CultureID] PRIMARY KEY CLUSTERED 
    (
        [CultureID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[Currency] WITH CHECK ADD 
    CONSTRAINT [PK_Currency_CurrencyCode] PRIMARY KEY CLUSTERED 
    (
        [CurrencyCode]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[CurrencyRate] WITH CHECK ADD 
    CONSTRAINT [PK_CurrencyRate_CurrencyRateID] PRIMARY KEY CLUSTERED 
    (
        [CurrencyRateID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[Customer] WITH CHECK ADD 
    CONSTRAINT [PK_Customer_CustomerID] PRIMARY KEY CLUSTERED 
    (
        [CustomerID]
    )  ON [PRIMARY];
GO

ALTER TABLE [dbo].[DatabaseLog] WITH CHECK ADD 
    CONSTRAINT [PK_DatabaseLog_DatabaseLogID] PRIMARY KEY NONCLUSTERED 
    (
        [DatabaseLogID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_HumanResources].[Department] WITH CHECK ADD 
    CONSTRAINT [PK_Department_DepartmentID] PRIMARY KEY CLUSTERED 
    (
        [DepartmentID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[Document] WITH CHECK ADD 
    CONSTRAINT [PK_Document_DocumentNode] PRIMARY KEY CLUSTERED 
    (
        [DocumentNode]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Person].[EmailAddress] WITH CHECK ADD 
    CONSTRAINT [PK_EmailAddress_BusinessEntityID_EmailAddressID] PRIMARY KEY CLUSTERED 
    (
        [BusinessEntityID],
		[EmailAddressID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_HumanResources].[Employee] WITH CHECK ADD 
    CONSTRAINT [PK_Employee_BusinessEntityID] PRIMARY KEY CLUSTERED 
    (
        [BusinessEntityID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_HumanResources].[EmployeeDepartmentHistory] WITH CHECK ADD 
    CONSTRAINT [PK_EmployeeDepartmentHistory_BusinessEntityID_StartDate_DepartmentID] PRIMARY KEY CLUSTERED 
    (
        [BusinessEntityID],
        [StartDate],
        [DepartmentID],
        [ShiftID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_HumanResources].[EmployeePayHistory] WITH CHECK ADD 
    CONSTRAINT [PK_EmployeePayHistory_BusinessEntityID_RateChangeDate] PRIMARY KEY CLUSTERED 
    (
        [BusinessEntityID],
        [RateChangeDate]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[Illustration] WITH CHECK ADD 
    CONSTRAINT [PK_Illustration_IllustrationID] PRIMARY KEY CLUSTERED 
    (
        [IllustrationID]
    )  ON [PRIMARY];
GO


ALTER TABLE [AW_HumanResources].[JobCandidate] WITH CHECK ADD 
    CONSTRAINT [PK_JobCandidate_JobCandidateID] PRIMARY KEY CLUSTERED 
    (
        [JobCandidateID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[Location] WITH CHECK ADD 
    CONSTRAINT [PK_Location_LocationID] PRIMARY KEY CLUSTERED 
    (
        [LocationID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Person].[Password] WITH CHECK ADD 
    CONSTRAINT [PK_Password_BusinessEntityID] PRIMARY KEY CLUSTERED 
    (
        [BusinessEntityID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Person].[AW_Person] WITH CHECK ADD 
    CONSTRAINT [PK_AW_Person_BusinessEntityID] PRIMARY KEY CLUSTERED 
    (
        [BusinessEntityID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[AW_PersonCreditCard] WITH CHECK ADD 
    CONSTRAINT [PK_AW_PersonCreditCard_BusinessEntityID_CreditCardID] PRIMARY KEY CLUSTERED 
    (
        [BusinessEntityID],
        [CreditCardID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Person].[AW_PersonPhone] WITH CHECK ADD 
    CONSTRAINT [PK_AW_PersonPhone_BusinessEntityID_PhoneNumber_PhoneNumberTypeID] PRIMARY KEY CLUSTERED 
    (
        [BusinessEntityID],
        [PhoneNumber],
        [PhoneNumberTypeID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Person].[PhoneNumberType] WITH CHECK ADD 
    CONSTRAINT [PK_PhoneNumberType_PhoneNumberTypeID] PRIMARY KEY CLUSTERED 
    (
        [PhoneNumberTypeID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[Product] WITH CHECK ADD 
    CONSTRAINT [PK_Product_ProductID] PRIMARY KEY CLUSTERED 
    (
        [ProductID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[ProductCategory] WITH CHECK ADD 
    CONSTRAINT [PK_ProductCategory_ProductCategoryID] PRIMARY KEY CLUSTERED 
    (
        [ProductCategoryID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[ProductCostHistory] WITH CHECK ADD 
    CONSTRAINT [PK_ProductCostHistory_ProductID_StartDate] PRIMARY KEY CLUSTERED 
    (
        [ProductID],
        [StartDate]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[ProductDescription] WITH CHECK ADD 
    CONSTRAINT [PK_ProductDescription_ProductDescriptionID] PRIMARY KEY CLUSTERED 
    (
        [ProductDescriptionID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[ProductDocument] WITH CHECK ADD 
    CONSTRAINT [PK_ProductDocument_ProductID_DocumentNode] PRIMARY KEY CLUSTERED 
    (
        [ProductID],
        [DocumentNode]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[ProductInventory] WITH CHECK ADD 
    CONSTRAINT [PK_ProductInventory_ProductID_LocationID] PRIMARY KEY CLUSTERED 
    (
    [ProductID],
    [LocationID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[ProductListPriceHistory] WITH CHECK ADD 
    CONSTRAINT [PK_ProductListPriceHistory_ProductID_StartDate] PRIMARY KEY CLUSTERED 
    (
        [ProductID],
        [StartDate]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[ProductModel] WITH CHECK ADD 
    CONSTRAINT [PK_ProductModel_ProductModelID] PRIMARY KEY CLUSTERED 
    (
        [ProductModelID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[ProductModelIllustration] WITH CHECK ADD 
    CONSTRAINT [PK_ProductModelIllustration_ProductModelID_IllustrationID] PRIMARY KEY CLUSTERED 
    (
        [ProductModelID],
        [IllustrationID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[ProductModelProductDescriptionCulture] WITH CHECK ADD 
    CONSTRAINT [PK_ProductModelProductDescriptionCulture_ProductModelID_ProductDescriptionID_CultureID] PRIMARY KEY CLUSTERED 
    (
        [ProductModelID],
        [ProductDescriptionID],
        [CultureID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[ProductPhoto] WITH CHECK ADD 
    CONSTRAINT [PK_ProductPhoto_ProductPhotoID] PRIMARY KEY CLUSTERED 
    (
        [ProductPhotoID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[ProductProductPhoto] WITH CHECK ADD 
    CONSTRAINT [PK_ProductProductPhoto_ProductID_ProductPhotoID] PRIMARY KEY NONCLUSTERED 
    (
        [ProductID],
        [ProductPhotoID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[ProductReview] WITH CHECK ADD 
    CONSTRAINT [PK_ProductReview_ProductReviewID] PRIMARY KEY CLUSTERED 
    (
        [ProductReviewID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[ProductSubcategory] WITH CHECK ADD 
    CONSTRAINT [PK_ProductSubcategory_ProductSubcategoryID] PRIMARY KEY CLUSTERED 
    (
        [ProductSubcategoryID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Purchasing].[ProductVendor] WITH CHECK ADD 
    CONSTRAINT [PK_ProductVendor_ProductID_BusinessEntityID] PRIMARY KEY CLUSTERED 
    (
        [ProductID],
        [BusinessEntityID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Purchasing].[PurchaseOrderDetail] WITH CHECK ADD 
    CONSTRAINT [PK_PurchaseOrderDetail_PurchaseOrderID_PurchaseOrderDetailID] PRIMARY KEY CLUSTERED 
    (
        [PurchaseOrderID],
        [PurchaseOrderDetailID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Purchasing].[PurchaseOrderHeader] WITH CHECK ADD 
    CONSTRAINT [PK_PurchaseOrderHeader_PurchaseOrderID] PRIMARY KEY CLUSTERED 
    (
        [PurchaseOrderID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[SalesOrderDetail] WITH CHECK ADD 
    CONSTRAINT [PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID] PRIMARY KEY CLUSTERED 
    (
        [SalesOrderID],
        [SalesOrderDetailID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[SalesOrderHeader] WITH CHECK ADD 
    CONSTRAINT [PK_SalesOrderHeader_SalesOrderID] PRIMARY KEY CLUSTERED 
    (
        [SalesOrderID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[SalesOrderHeaderSalesReason] WITH CHECK ADD 
    CONSTRAINT [PK_SalesOrderHeaderSalesReason_SalesOrderID_SalesReasonID] PRIMARY KEY CLUSTERED 
    (
        [SalesOrderID],
        [SalesReasonID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[SalesAW_Person] WITH CHECK ADD 
    CONSTRAINT [PK_SalesAW_Person_BusinessEntityID] PRIMARY KEY CLUSTERED 
    (
        [BusinessEntityID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[SalesAW_PersonQuotaHistory] WITH CHECK ADD 
    CONSTRAINT [PK_SalesAW_PersonQuotaHistory_BusinessEntityID_QuotaDate] PRIMARY KEY CLUSTERED 
    (
        [BusinessEntityID],
        [QuotaDate] --,
        -- [ProductCategoryID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[SalesReason] WITH CHECK ADD 
    CONSTRAINT [PK_SalesReason_SalesReasonID] PRIMARY KEY CLUSTERED 
    (
        [SalesReasonID]
    )  ON [PRIMARY];
GO
 
ALTER TABLE [AW_Sales].[SalesTaxRate] WITH CHECK ADD 
    CONSTRAINT [PK_SalesTaxRate_SalesTaxRateID] PRIMARY KEY CLUSTERED 
    (
        [SalesTaxRateID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[SalesTerritory] WITH CHECK ADD 
    CONSTRAINT [PK_SalesTerritory_TerritoryID] PRIMARY KEY CLUSTERED 
    (
        [TerritoryID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[SalesTerritoryHistory] WITH CHECK ADD 
    CONSTRAINT [PK_SalesTerritoryHistory_BusinessEntityID_StartDate_TerritoryID] PRIMARY KEY CLUSTERED 
    (
        [BusinessEntityID],  --Sales AW_Person
        [StartDate],
        [TerritoryID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[ScrapReason] WITH CHECK ADD 
    CONSTRAINT [PK_ScrapReason_ScrapReasonID] PRIMARY KEY CLUSTERED 
    (
        [ScrapReasonID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_HumanResources].[Shift] WITH CHECK ADD 
    CONSTRAINT [PK_Shift_ShiftID] PRIMARY KEY CLUSTERED 
    (
        [ShiftID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Purchasing].[ShipMethod] WITH CHECK ADD 
    CONSTRAINT [PK_ShipMethod_ShipMethodID] PRIMARY KEY CLUSTERED 
    (
        [ShipMethodID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[ShoppingCartItem] WITH CHECK ADD 
    CONSTRAINT [PK_ShoppingCartItem_ShoppingCartItemID] PRIMARY KEY CLUSTERED 
    (
        [ShoppingCartItemID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[SpecialOffer] WITH CHECK ADD 
    CONSTRAINT [PK_SpecialOffer_SpecialOfferID] PRIMARY KEY CLUSTERED 
    (
        [SpecialOfferID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[SpecialOfferProduct] WITH CHECK ADD 
    CONSTRAINT [PK_SpecialOfferProduct_SpecialOfferID_ProductID] PRIMARY KEY CLUSTERED 
    (
        [SpecialOfferID],
        [ProductID]
    )  ON [PRIMARY];
GO
GO

ALTER TABLE [AW_Person].[StateProvince] WITH CHECK ADD 
    CONSTRAINT [PK_StateProvince_StateProvinceID] PRIMARY KEY CLUSTERED 
    (
        [StateProvinceID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Sales].[Store] WITH CHECK ADD 
    CONSTRAINT [PK_Store_BusinessEntityID] PRIMARY KEY CLUSTERED 
    (
        [BusinessEntityID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[TransactionHistory] WITH CHECK ADD 
    CONSTRAINT [PK_TransactionHistory_TransactionID] PRIMARY KEY CLUSTERED 
    (
        [TransactionID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[TransactionHistoryArchive] WITH CHECK ADD 
    CONSTRAINT [PK_TransactionHistoryArchive_TransactionID] PRIMARY KEY CLUSTERED 
    (
        [TransactionID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[UnitMeasure] WITH CHECK ADD 
    CONSTRAINT [PK_UnitMeasure_UnitMeasureCode] PRIMARY KEY CLUSTERED 
    (
        [UnitMeasureCode]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Purchasing].[Vendor] WITH CHECK ADD 
    CONSTRAINT [PK_Vendor_BusinessEntityID] PRIMARY KEY CLUSTERED 
    (
        [BusinessEntityID]
    )  ON [PRIMARY];
GO


ALTER TABLE [AW_Production].[WorkOrder] WITH CHECK ADD 
    CONSTRAINT [PK_WorkOrder_WorkOrderID] PRIMARY KEY CLUSTERED 
    (
        [WorkOrderID]
    )  ON [PRIMARY];
GO

ALTER TABLE [AW_Production].[WorkOrderRouting] WITH CHECK ADD 
    CONSTRAINT [PK_WorkOrderRouting_WorkOrderID_ProductID_OperationSequence] PRIMARY KEY CLUSTERED 
    (
        [WorkOrderID],
        [ProductID],
        [OperationSequence]
    )  ON [PRIMARY];
GO


-- ******************************************************
-- Add Indexes
-- ******************************************************
PRINT '';
PRINT '*** Adding Indexes';
GO

CREATE UNIQUE INDEX [AK_Address_rowguid] ON [AW_Person].[Address]([rowguid]) ON [PRIMARY];
CREATE UNIQUE INDEX [IX_Address_AddressLine1_AddressLine2_City_StateProvinceID_PostalCode] ON [AW_Person].[Address] ([AddressLine1], [AddressLine2], [City], [StateProvinceID], [PostalCode]) ON [PRIMARY];
CREATE INDEX [IX_Address_StateProvinceID] ON [AW_Person].[Address]([StateProvinceID]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_AddressType_rowguid] ON [AW_Person].[AddressType]([rowguid]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_AddressType_Name] ON [AW_Person].[AddressType]([Name]) ON [PRIMARY];
GO

CREATE INDEX [IX_BillOfMaterials_UnitMeasureCode] ON [AW_Production].[BillOfMaterials]([UnitMeasureCode]) ON [PRIMARY];
CREATE UNIQUE CLUSTERED INDEX [AK_BillOfMaterials_ProductAssemblyID_ComponentID_StartDate] ON [AW_Production].[BillOfMaterials]([ProductAssemblyID], [ComponentID], [StartDate]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_BusinessEntity_rowguid] ON [AW_Person].[BusinessEntity]([rowguid]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_BusinessEntityAddress_rowguid] ON [AW_Person].[BusinessEntityAddress]([rowguid]) ON [PRIMARY];
CREATE INDEX [IX_BusinessEntityAddress_AddressID] ON [AW_Person].[BusinessEntityAddress]([AddressID]) ON [PRIMARY];
CREATE INDEX [IX_BusinessEntityAddress_AddressTypeID] ON [AW_Person].[BusinessEntityAddress]([AddressTypeID]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_BusinessEntityContact_rowguid] ON [AW_Person].[BusinessEntityContact]([rowguid]) ON [PRIMARY];
CREATE INDEX [IX_BusinessEntityContact_AW_PersonID] ON [AW_Person].[BusinessEntityContact]([AW_PersonID]) ON [PRIMARY];
CREATE INDEX [IX_BusinessEntityContact_ContactTypeID] ON [AW_Person].[BusinessEntityContact]([ContactTypeID]) ON [PRIMARY];
GO


CREATE UNIQUE INDEX [AK_ContactType_Name] ON [AW_Person].[ContactType]([Name]) ON [PRIMARY];
GO

CREATE INDEX [IX_CountryRegionCurrency_CurrencyCode] ON [AW_Sales].[CountryRegionCurrency]([CurrencyCode]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_CountryRegion_Name] ON [AW_Person].[CountryRegion]([Name]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_CreditCard_CardNumber] ON [AW_Sales].[CreditCard]([CardNumber]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_Culture_Name] ON [AW_Production].[Culture]([Name]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_Currency_Name] ON [AW_Sales].[Currency]([Name]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_CurrencyRate_CurrencyRateDate_FromCurrencyCode_ToCurrencyCode] ON [AW_Sales].[CurrencyRate]([CurrencyRateDate], [FromCurrencyCode], [ToCurrencyCode]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_Customer_rowguid] ON [AW_Sales].[Customer]([rowguid]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_Customer_AccountNumber] ON [AW_Sales].[Customer]([AccountNumber]) ON [PRIMARY];
CREATE INDEX [IX_Customer_TerritoryID] ON [AW_Sales].[Customer]([TerritoryID]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_Department_Name] ON [AW_HumanResources].[Department]([Name]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_Document_DocumentLevel_DocumentNode] ON [AW_Production].[Document] ([DocumentLevel], [DocumentNode]);
CREATE UNIQUE INDEX [AK_Document_rowguid] ON [AW_Production].[Document]([rowguid]) ON [PRIMARY];
CREATE INDEX [IX_Document_FileName_Revision] ON [AW_Production].[Document]([FileName], [Revision]) ON [PRIMARY];
GO

CREATE INDEX [IX_EmailAddress_EmailAddress] ON [AW_Person].[EmailAddress]([EmailAddress]) ON [PRIMARY];
GO

CREATE INDEX [IX_Employee_OrganizationNode] ON [AW_HumanResources].[Employee] ([OrganizationNode]);
CREATE INDEX [IX_Employee_OrganizationLevel_OrganizationNode] ON [AW_HumanResources].[Employee] ([OrganizationLevel], [OrganizationNode]);
CREATE UNIQUE INDEX [AK_Employee_LoginID] ON [AW_HumanResources].[Employee]([LoginID]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_Employee_NationalIDNumber] ON [AW_HumanResources].[Employee]([NationalIDNumber]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_Employee_rowguid] ON [AW_HumanResources].[Employee]([rowguid]) ON [PRIMARY];
GO

CREATE INDEX [IX_EmployeeDepartmentHistory_DepartmentID] ON [AW_HumanResources].[EmployeeDepartmentHistory]([DepartmentID]) ON [PRIMARY];
CREATE INDEX [IX_EmployeeDepartmentHistory_ShiftID] ON [AW_HumanResources].[EmployeeDepartmentHistory]([ShiftID]) ON [PRIMARY];
GO

CREATE INDEX [IX_JobCandidate_BusinessEntityID] ON [AW_HumanResources].[JobCandidate]([BusinessEntityID]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_Location_Name] ON [AW_Production].[Location]([Name]) ON [PRIMARY];
GO

CREATE INDEX [IX_AW_Person_LastName_FirstName_MiddleName] ON [AW_Person].[AW_Person] ([LastName], [FirstName], [MiddleName]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_AW_Person_rowguid] ON [AW_Person].[AW_Person]([rowguid]) ON [PRIMARY];

CREATE INDEX [IX_AW_PersonPhone_PhoneNumber] on [AW_Person].[AW_PersonPhone] ([PhoneNumber]) ON [PRIMARY];

CREATE UNIQUE INDEX [AK_Product_ProductNumber] ON [AW_Production].[Product]([ProductNumber]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_Product_Name] ON [AW_Production].[Product]([Name]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_Product_rowguid] ON [AW_Production].[Product]([rowguid]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_ProductCategory_Name] ON [AW_Production].[ProductCategory]([Name]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_ProductCategory_rowguid] ON [AW_Production].[ProductCategory]([rowguid]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_ProductDescription_rowguid] ON [AW_Production].[ProductDescription]([rowguid]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_ProductModel_Name] ON [AW_Production].[ProductModel]([Name]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_ProductModel_rowguid] ON [AW_Production].[ProductModel]([rowguid]) ON [PRIMARY];
GO

CREATE NONCLUSTERED INDEX [IX_ProductReview_ProductID_Name] ON [AW_Production].[ProductReview]([ProductID], [ReviewerName]) INCLUDE ([Comments]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_ProductSubcategory_Name] ON [AW_Production].[ProductSubcategory]([Name]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_ProductSubcategory_rowguid] ON [AW_Production].[ProductSubcategory]([rowguid]) ON [PRIMARY];
GO

CREATE INDEX [IX_ProductVendor_UnitMeasureCode] ON [AW_Purchasing].[ProductVendor]([UnitMeasureCode]) ON [PRIMARY];
CREATE INDEX [IX_ProductVendor_BusinessEntityID] ON [AW_Purchasing].[ProductVendor]([BusinessEntityID]) ON [PRIMARY];
GO

CREATE INDEX [IX_PurchaseOrderDetail_ProductID] ON [AW_Purchasing].[PurchaseOrderDetail]([ProductID]) ON [PRIMARY];
GO

CREATE INDEX [IX_PurchaseOrderHeader_VendorID] ON [AW_Purchasing].[PurchaseOrderHeader]([VendorID]) ON [PRIMARY];
CREATE INDEX [IX_PurchaseOrderHeader_EmployeeID] ON [AW_Purchasing].[PurchaseOrderHeader]([EmployeeID]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_SalesOrderDetail_rowguid] ON [AW_Sales].[SalesOrderDetail]([rowguid]) ON [PRIMARY];
CREATE INDEX [IX_SalesOrderDetail_ProductID] ON [AW_Sales].[SalesOrderDetail]([ProductID]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_SalesOrderHeader_rowguid] ON [AW_Sales].[SalesOrderHeader]([rowguid]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_SalesOrderHeader_SalesOrderNumber] ON [AW_Sales].[SalesOrderHeader]([SalesOrderNumber]) ON [PRIMARY];
CREATE INDEX [IX_SalesOrderHeader_CustomerID] ON [AW_Sales].[SalesOrderHeader]([CustomerID]) ON [PRIMARY];
CREATE INDEX [IX_SalesOrderHeader_SalesAW_PersonID] ON [AW_Sales].[SalesOrderHeader]([SalesAW_PersonID]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_SalesAW_Person_rowguid] ON [AW_Sales].[SalesAW_Person]([rowguid]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_SalesAW_PersonQuotaHistory_rowguid] ON [AW_Sales].[SalesAW_PersonQuotaHistory]([rowguid]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_SalesTaxRate_StateProvinceID_TaxType] ON [AW_Sales].[SalesTaxRate]([StateProvinceID], [TaxType]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_SalesTaxRate_rowguid] ON [AW_Sales].[SalesTaxRate]([rowguid]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_SalesTerritory_Name] ON [AW_Sales].[SalesTerritory]([Name]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_SalesTerritory_rowguid] ON [AW_Sales].[SalesTerritory]([rowguid]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_SalesTerritoryHistory_rowguid] ON [AW_Sales].[SalesTerritoryHistory]([rowguid]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_ScrapReason_Name] ON [AW_Production].[ScrapReason]([Name]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_Shift_Name] ON [AW_HumanResources].[Shift]([Name]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_Shift_StartTime_EndTime] ON [AW_HumanResources].[Shift]([StartTime], [EndTime]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_ShipMethod_Name] ON [AW_Purchasing].[ShipMethod]([Name]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_ShipMethod_rowguid] ON [AW_Purchasing].[ShipMethod]([rowguid]) ON [PRIMARY];
GO

CREATE INDEX [IX_ShoppingCartItem_ShoppingCartID_ProductID] ON [AW_Sales].[ShoppingCartItem]([ShoppingCartID], [ProductID]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_SpecialOffer_rowguid] ON [AW_Sales].[SpecialOffer]([rowguid]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_SpecialOfferProduct_rowguid] ON [AW_Sales].[SpecialOfferProduct]([rowguid]) ON [PRIMARY];
CREATE INDEX [IX_SpecialOfferProduct_ProductID] ON [AW_Sales].[SpecialOfferProduct]([ProductID]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_StateProvince_Name] ON [AW_Person].[StateProvince]([Name]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_StateProvince_StateProvinceCode_CountryRegionCode] ON [AW_Person].[StateProvince]([StateProvinceCode], [CountryRegionCode]) ON [PRIMARY];
CREATE UNIQUE INDEX [AK_StateProvince_rowguid] ON [AW_Person].[StateProvince]([rowguid]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_Store_rowguid] ON [AW_Sales].[Store]([rowguid]) ON [PRIMARY];
CREATE INDEX [IX_Store_SalesAW_PersonID] ON [AW_Sales].[Store]([SalesAW_PersonID]) ON [PRIMARY];
GO

CREATE INDEX [IX_TransactionHistory_ProductID] ON [AW_Production].[TransactionHistory]([ProductID]) ON [PRIMARY];
CREATE INDEX [IX_TransactionHistory_ReferenceOrderID_ReferenceOrderLineID] ON [AW_Production].[TransactionHistory]([ReferenceOrderID], [ReferenceOrderLineID]) ON [PRIMARY];
GO

CREATE INDEX [IX_TransactionHistoryArchive_ProductID] ON [AW_Production].[TransactionHistoryArchive]([ProductID]) ON [PRIMARY];
CREATE INDEX [IX_TransactionHistoryArchive_ReferenceOrderID_ReferenceOrderLineID] ON [AW_Production].[TransactionHistoryArchive]([ReferenceOrderID], [ReferenceOrderLineID]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_UnitMeasure_Name] ON [AW_Production].[UnitMeasure]([Name]) ON [PRIMARY];
GO

CREATE UNIQUE INDEX [AK_Vendor_AccountNumber] ON [AW_Purchasing].[Vendor]([AccountNumber]) ON [PRIMARY];
GO

CREATE INDEX [IX_WorkOrder_ScrapReasonID] ON [AW_Production].[WorkOrder]([ScrapReasonID]) ON [PRIMARY];
CREATE INDEX [IX_WorkOrder_ProductID] ON [AW_Production].[WorkOrder]([ProductID]) ON [PRIMARY];
GO

CREATE INDEX [IX_WorkOrderRouting_ProductID] ON [AW_Production].[WorkOrderRouting]([ProductID]) ON [PRIMARY];
GO

-- ****************************************
-- Create XML index for each XML column
-- ****************************************
PRINT '';
PRINT '*** Creating XML index for each XML column';
GO

SET ARITHABORT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;





CREATE PRIMARY XML INDEX [PXML_AW_Person_AddContact] ON [AW_Person].[AW_Person]([AdditionalContactInfo]);
GO

CREATE PRIMARY XML INDEX [PXML_AW_Person_Demographics] ON [AW_Person].[AW_Person]([Demographics]);
GO

CREATE XML INDEX [XMLPATH_AW_Person_Demographics] ON [AW_Person].[AW_Person]([Demographics]) 
USING XML INDEX [PXML_AW_Person_Demographics] FOR PATH;
GO

CREATE XML INDEX [XMLPROPERTY_AW_Person_Demographics] ON [AW_Person].[AW_Person]([Demographics]) 
USING XML INDEX [PXML_AW_Person_Demographics] FOR PROPERTY;
GO

CREATE XML INDEX [XMLVALUE_AW_Person_Demographics] ON [AW_Person].[AW_Person]([Demographics]) 
USING XML INDEX [PXML_AW_Person_Demographics] FOR VALUE;
GO

CREATE PRIMARY XML INDEX [PXML_Store_Demographics] ON [AW_Sales].[Store]([Demographics]);
GO

CREATE PRIMARY XML INDEX [PXML_ProductModel_CatalogDescription] ON [AW_Production].[ProductModel]([CatalogDescription]);
GO

CREATE PRIMARY XML INDEX [PXML_ProductModel_Instructions] ON [AW_Production].[ProductModel]([Instructions]);
GO

-- ****************************************
-- Create Full Text catalog and indexes
-- ****************************************
PRINT '';
PRINT '*** Creating Full Text catalog and indexes';
GO

--This creates a default FULLTEXT CATALOG where to logically store all the FTIndexes going to be created

CREATE FULLTEXT CATALOG AW2016FullTextCatalog AS DEFAULT;
GO


--This creates a FULLTEXT INDEX on ProductReview table. The index will cover the column 'Comments' which contains plain text data.

CREATE FULLTEXT INDEX ON AW_Production.ProductReview(Comments) KEY INDEX PK_ProductReview_ProductReviewID;
GO

--This creates a FULLTEXT INDEX on JobCandidate table. The index will cover the column 'Resume' which contains XML data related with the candidates
--resumes.This is a good example of how iFTS will automatically call the XML filter in order to parse the data and store the information into the FTIndex
--created. No data type column is needed in this case as the datatype already provides the needed information

CREATE FULLTEXT INDEX ON AW_HumanResources.JobCandidate(Resume) KEY INDEX PK_JobCandidate_JobCandidateID;
GO

--This creates a FULLTEXT INDEX on Document table. The index will cover the columns 'Document' and ‘DocumentSummary’. Note that the column ‘Document’
--contains binary data on a format specified by the 'FileExtension' column.This is a good example of how iFTS will automatically call the need 
--iFilter associated with the 'FileExtension'associated with each row/document (in this case, all are .doc, which should be loaded into SQL from the OS by default)

CREATE FULLTEXT INDEX ON AW_Production.Document(Document TYPE COLUMN FileExtension, DocumentSummary) KEY INDEX PK_Document_DocumentNode;
GO


-- ****************************************
-- Create Foreign key constraints
-- ****************************************
PRINT '';
PRINT '*** Creating Foreign Key Constraints';
GO

ALTER TABLE [AW_Person].[Address] ADD 
    CONSTRAINT [FK_Address_StateProvince_StateProvinceID] FOREIGN KEY 
    (
        [StateProvinceID]
    ) REFERENCES [AW_Person].[StateProvince](
        [StateProvinceID]
    );
GO

ALTER TABLE [AW_Production].[BillOfMaterials] ADD 
    CONSTRAINT [FK_BillOfMaterials_Product_ProductAssemblyID] FOREIGN KEY 
    (
        [ProductAssemblyID]
    ) REFERENCES [AW_Production].[Product](
        [ProductID]
    ),
    CONSTRAINT [FK_BillOfMaterials_Product_ComponentID] FOREIGN KEY 
    (
        [ComponentID]
    ) REFERENCES [AW_Production].[Product](
        [ProductID]
    ),
    CONSTRAINT [FK_BillOfMaterials_UnitMeasure_UnitMeasureCode] FOREIGN KEY 
    (
        [UnitMeasureCode]
    ) REFERENCES [AW_Production].[UnitMeasure](
        [UnitMeasureCode]
    );
GO

ALTER TABLE [AW_Person].[BusinessEntityAddress] ADD 
    CONSTRAINT [FK_BusinessEntityAddress_Address_AddressID] FOREIGN KEY 
    (
        [AddressID]
    ) REFERENCES [AW_Person].[Address](
        [AddressID]
    ),
    CONSTRAINT [FK_BusinessEntityAddress_AddressType_AddressTypeID] FOREIGN KEY 
    (
        [AddressTypeID]
    ) REFERENCES [AW_Person].[AddressType](
        [AddressTypeID]
    ),
    CONSTRAINT [FK_BusinessEntityAddress_BusinessEntity_BusinessEntityID] FOREIGN KEY 
    (
        [BusinessEntityID]
    ) REFERENCES [AW_Person].[BusinessEntity](
        [BusinessEntityID]
    );
GO

ALTER TABLE [AW_Person].[BusinessEntityContact] ADD
    CONSTRAINT [FK_BusinessEntityContact_AW_Person_AW_PersonID] FOREIGN KEY 
    (
        [AW_PersonID]
    ) REFERENCES [AW_Person].[AW_Person](
        [BusinessEntityID]
    ),
    CONSTRAINT [FK_BusinessEntityContact_ContactType_ContactTypeID] FOREIGN KEY 
    (
        [ContactTypeID]
    ) REFERENCES [AW_Person].[ContactType](
        [ContactTypeID]
    ),
    CONSTRAINT [FK_BusinessEntityContact_BusinessEntity_BusinessEntityID] FOREIGN KEY 
    (
        [BusinessEntityID]
    ) REFERENCES [AW_Person].[BusinessEntity](
        [BusinessEntityID]
    );
GO

ALTER TABLE [AW_Sales].[CountryRegionCurrency] ADD 
    CONSTRAINT [FK_CountryRegionCurrency_CountryRegion_CountryRegionCode] FOREIGN KEY 
    (
        [CountryRegionCode]
    ) REFERENCES [AW_Person].[CountryRegion](
        [CountryRegionCode]
    ),
    CONSTRAINT [FK_CountryRegionCurrency_Currency_CurrencyCode] FOREIGN KEY 
    (
        [CurrencyCode]
    ) REFERENCES [AW_Sales].[Currency](
        [CurrencyCode]
    );
GO

ALTER TABLE [AW_Sales].[CurrencyRate] ADD 
    CONSTRAINT [FK_CurrencyRate_Currency_FromCurrencyCode] FOREIGN KEY 
    (
        [FromCurrencyCode]
    ) REFERENCES [AW_Sales].[Currency](
        [CurrencyCode]
    ),
    CONSTRAINT [FK_CurrencyRate_Currency_ToCurrencyCode] FOREIGN KEY 
    (
        [ToCurrencyCode]
    ) REFERENCES [AW_Sales].[Currency](
        [CurrencyCode]
    );
GO

ALTER TABLE [AW_Sales].[Customer] ADD 
    CONSTRAINT [FK_Customer_AW_Person_AW_PersonID] FOREIGN KEY 
    (
        [AW_PersonID]
    ) REFERENCES [AW_Person].[AW_Person](
        [BusinessEntityID]
    ),
    CONSTRAINT [FK_Customer_Store_StoreID] FOREIGN KEY 
    (
        [StoreID]
    ) REFERENCES [AW_Sales].[Store](
        [BusinessEntityID]
    ),
    CONSTRAINT [FK_Customer_SalesTerritory_TerritoryID] FOREIGN KEY 
    (
        [TerritoryID]
    ) REFERENCES [AW_Sales].[SalesTerritory](
        [TerritoryID]
    );
GO

ALTER TABLE [AW_Production].[Document] ADD
	CONSTRAINT [FK_Document_Employee_Owner] FOREIGN KEY
	(
		[Owner]
	) REFERENCES [AW_HumanResources].[Employee](
		[BusinessEntityID]
	);
GO

ALTER TABLE [AW_Person].[EmailAddress] ADD 
    CONSTRAINT [FK_EmailAddress_AW_Person_BusinessEntityID] FOREIGN KEY 
    (
        [BusinessEntityID]
    ) REFERENCES [AW_Person].[AW_Person](
        [BusinessEntityID]
    );
GO

ALTER TABLE [AW_HumanResources].[Employee] ADD 
    CONSTRAINT [FK_Employee_AW_Person_BusinessEntityID] FOREIGN KEY 
    (
        [BusinessEntityID]
    ) REFERENCES [AW_Person].[AW_Person](
        [BusinessEntityID]
    );
GO

ALTER TABLE [AW_HumanResources].[EmployeeDepartmentHistory] ADD 
    CONSTRAINT [FK_EmployeeDepartmentHistory_Department_DepartmentID] FOREIGN KEY 
    (
        [DepartmentID]
    ) REFERENCES [AW_HumanResources].[Department](
        [DepartmentID]
    ),
    CONSTRAINT [FK_EmployeeDepartmentHistory_Employee_BusinessEntityID] FOREIGN KEY 
    (
        [BusinessEntityID]
    ) REFERENCES [AW_HumanResources].[Employee](
        [BusinessEntityID]
    ),
    CONSTRAINT [FK_EmployeeDepartmentHistory_Shift_ShiftID] FOREIGN KEY 
    (
        [ShiftID]
    ) REFERENCES [AW_HumanResources].[Shift](
        [ShiftID]
    );
GO

ALTER TABLE [AW_HumanResources].[EmployeePayHistory] ADD 
    CONSTRAINT [FK_EmployeePayHistory_Employee_BusinessEntityID] FOREIGN KEY 
    (
        [BusinessEntityID]
    ) REFERENCES [AW_HumanResources].[Employee](
        [BusinessEntityID]
    );
GO

ALTER TABLE [AW_HumanResources].[JobCandidate] ADD 
    CONSTRAINT [FK_JobCandidate_Employee_BusinessEntityID] FOREIGN KEY 
    (
        [BusinessEntityID]
    ) REFERENCES [AW_HumanResources].[Employee](
        [BusinessEntityID]
    );
GO

ALTER TABLE [AW_Person].[Password] ADD 
    CONSTRAINT [FK_Password_AW_Person_BusinessEntityID] FOREIGN KEY 
    (
        [BusinessEntityID]
    ) REFERENCES [AW_Person].[AW_Person](
        [BusinessEntityID]
    );
GO

ALTER TABLE [AW_Person].[AW_Person] ADD 
    CONSTRAINT [FK_AW_Person_BusinessEntity_BusinessEntityID] FOREIGN KEY 
    (
        [BusinessEntityID]
    ) REFERENCES [AW_Person].[BusinessEntity](
        [BusinessEntityID]
    );
GO

ALTER TABLE [AW_Sales].[AW_PersonCreditCard] ADD 
    CONSTRAINT [FK_AW_PersonCreditCard_AW_Person_BusinessEntityID] FOREIGN KEY 
    (
        [BusinessEntityID]
    ) REFERENCES [AW_Person].[AW_Person](
        [BusinessEntityID]
    ),
    CONSTRAINT [FK_AW_PersonCreditCard_CreditCard_CreditCardID] FOREIGN KEY 
    (
        [CreditCardID]
    ) REFERENCES [AW_Sales].[CreditCard](
        [CreditCardID]
    );
GO

ALTER TABLE [AW_Person].[AW_PersonPhone] ADD 
    CONSTRAINT [FK_AW_PersonPhone_AW_Person_BusinessEntityID] FOREIGN KEY 
    (
        [BusinessEntityID]
    ) REFERENCES [AW_Person].[AW_Person](
        [BusinessEntityID]
    ),
 CONSTRAINT [FK_AW_PersonPhone_PhoneNumberType_PhoneNumberTypeID] FOREIGN KEY 
    (
        [PhoneNumberTypeID]
    ) REFERENCES [AW_Person].[PhoneNumberType](
        [PhoneNumberTypeID]
    );
GO

ALTER TABLE [AW_Production].[Product] ADD 
    CONSTRAINT [FK_Product_UnitMeasure_SizeUnitMeasureCode] FOREIGN KEY 
    (
        [SizeUnitMeasureCode]
    ) REFERENCES [AW_Production].[UnitMeasure](
        [UnitMeasureCode]
    ),
    CONSTRAINT [FK_Product_UnitMeasure_WeightUnitMeasureCode] FOREIGN KEY 
    (
        [WeightUnitMeasureCode]
    ) REFERENCES [AW_Production].[UnitMeasure](
        [UnitMeasureCode]
    ),
    CONSTRAINT [FK_Product_ProductModel_ProductModelID] FOREIGN KEY 
    (
        [ProductModelID]
    ) REFERENCES [AW_Production].[ProductModel](
        [ProductModelID]
    ),
    CONSTRAINT [FK_Product_ProductSubcategory_ProductSubcategoryID] FOREIGN KEY 
    (
        [ProductSubcategoryID]
    ) REFERENCES [AW_Production].[ProductSubcategory](
        [ProductSubcategoryID]
    );
GO

ALTER TABLE [AW_Production].[ProductCostHistory] ADD 
    CONSTRAINT [FK_ProductCostHistory_Product_ProductID] FOREIGN KEY 
    (
        [ProductID]
    ) REFERENCES [AW_Production].[Product](
        [ProductID]
    );
GO

ALTER TABLE [AW_Production].[ProductDocument] ADD 
    CONSTRAINT [FK_ProductDocument_Product_ProductID] FOREIGN KEY 
    (
        [ProductID]
    ) REFERENCES [AW_Production].[Product](
        [ProductID]
    ),
    CONSTRAINT [FK_ProductDocument_Document_DocumentNode] FOREIGN KEY 
    (
        [DocumentNode]
    ) REFERENCES [AW_Production].[Document](
        [DocumentNode]
    );
GO

ALTER TABLE [AW_Production].[ProductInventory] ADD 
    CONSTRAINT [FK_ProductInventory_Location_LocationID] FOREIGN KEY 
    (
        [LocationID]
    ) REFERENCES [AW_Production].[Location](
        [LocationID]
    ),
    CONSTRAINT [FK_ProductInventory_Product_ProductID] FOREIGN KEY 
    (
        [ProductID]
    ) REFERENCES [AW_Production].[Product](
        [ProductID]
    );
GO

ALTER TABLE [AW_Production].[ProductListPriceHistory] ADD 
    CONSTRAINT [FK_ProductListPriceHistory_Product_ProductID] FOREIGN KEY 
    (
        [ProductID]
    ) REFERENCES [AW_Production].[Product](
        [ProductID]
    );
GO

ALTER TABLE [AW_Production].[ProductModelIllustration] ADD 
    CONSTRAINT [FK_ProductModelIllustration_ProductModel_ProductModelID] FOREIGN KEY 
    (
        [ProductModelID]
    ) REFERENCES [AW_Production].[ProductModel](
        [ProductModelID]
    ),
    CONSTRAINT [FK_ProductModelIllustration_Illustration_IllustrationID] FOREIGN KEY 
    (
        [IllustrationID]
    ) REFERENCES [AW_Production].[Illustration](
        [IllustrationID]
    );
GO

ALTER TABLE [AW_Production].[ProductModelProductDescriptionCulture] ADD 
    CONSTRAINT [FK_ProductModelProductDescriptionCulture_ProductDescription_ProductDescriptionID] FOREIGN KEY 
    (
        [ProductDescriptionID]
    ) REFERENCES [AW_Production].[ProductDescription](
        [ProductDescriptionID]
    ),
    CONSTRAINT [FK_ProductModelProductDescriptionCulture_Culture_CultureID] FOREIGN KEY 
    (
        [CultureID]
    ) REFERENCES [AW_Production].[Culture]
    (
        [CultureID]
    ),
    CONSTRAINT [FK_ProductModelProductDescriptionCulture_ProductModel_ProductModelID] FOREIGN KEY 
    (
        [ProductModelID]
    ) REFERENCES [AW_Production].[ProductModel](
        [ProductModelID]
    );
GO

ALTER TABLE [AW_Production].[ProductProductPhoto] ADD
    CONSTRAINT [FK_ProductProductPhoto_Product_ProductID] FOREIGN KEY 
    (
        [ProductID]
    ) REFERENCES [AW_Production].[Product](
        [ProductID]
    ),
    CONSTRAINT [FK_ProductProductPhoto_ProductPhoto_ProductPhotoID] FOREIGN KEY 
    (
        [ProductPhotoID]
    ) REFERENCES [AW_Production].[ProductPhoto](
        [ProductPhotoID]
    );
GO

ALTER TABLE [AW_Production].[ProductReview] ADD 
    CONSTRAINT [FK_ProductReview_Product_ProductID] FOREIGN KEY 
    (
        [ProductID]
    ) REFERENCES [AW_Production].[Product](
        [ProductID]
    );
GO

ALTER TABLE [AW_Production].[ProductSubcategory] ADD 
    CONSTRAINT [FK_ProductSubcategory_ProductCategory_ProductCategoryID] FOREIGN KEY 
    (
        [ProductCategoryID]
    ) REFERENCES [AW_Production].[ProductCategory](
        [ProductCategoryID]
    );
GO

ALTER TABLE [AW_Purchasing].[ProductVendor] ADD 
    CONSTRAINT [FK_ProductVendor_Product_ProductID] FOREIGN KEY 
    (
        [ProductID]
    ) REFERENCES [AW_Production].[Product](
        [ProductID]
    ),
    CONSTRAINT [FK_ProductVendor_UnitMeasure_UnitMeasureCode] FOREIGN KEY 
    (
        [UnitMeasureCode]
    ) REFERENCES [AW_Production].[UnitMeasure](
        [UnitMeasureCode]
    ),
    CONSTRAINT [FK_ProductVendor_Vendor_BusinessEntityID] FOREIGN KEY 
    (
        [BusinessEntityID]
    ) REFERENCES [AW_Purchasing].[Vendor](
        [BusinessEntityID]
    );
GO

ALTER TABLE [AW_Purchasing].[PurchaseOrderDetail] ADD 
    CONSTRAINT [FK_PurchaseOrderDetail_Product_ProductID] FOREIGN KEY 
    (
        [ProductID]
    ) REFERENCES [AW_Production].[Product](
        [ProductID]
    ),
    CONSTRAINT [FK_PurchaseOrderDetail_PurchaseOrderHeader_PurchaseOrderID] FOREIGN KEY 
    (
        [PurchaseOrderID]
    ) REFERENCES [AW_Purchasing].[PurchaseOrderHeader](
        [PurchaseOrderID]
    );
GO

ALTER TABLE [AW_Purchasing].[PurchaseOrderHeader] ADD 
    CONSTRAINT [FK_PurchaseOrderHeader_Employee_EmployeeID] FOREIGN KEY 
    (
        [EmployeeID]
    ) REFERENCES [AW_HumanResources].[Employee](
        [BusinessEntityID]
    ),
    CONSTRAINT [FK_PurchaseOrderHeader_Vendor_VendorID] FOREIGN KEY 
    (
        [VendorID]
    ) REFERENCES [AW_Purchasing].[Vendor](
        [BusinessEntityID]
    ),
    CONSTRAINT [FK_PurchaseOrderHeader_ShipMethod_ShipMethodID] FOREIGN KEY 
    (
        [ShipMethodID]
    ) REFERENCES [AW_Purchasing].[ShipMethod](
        [ShipMethodID]
    );
GO

ALTER TABLE [AW_Sales].[SalesOrderDetail] ADD 
    CONSTRAINT [FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID] FOREIGN KEY 
    (
        [SalesOrderID]
    ) REFERENCES [AW_Sales].[SalesOrderHeader](
        [SalesOrderID]
    ) ON DELETE CASCADE,
    CONSTRAINT [FK_SalesOrderDetail_SpecialOfferProduct_SpecialOfferIDProductID] FOREIGN KEY 
    (
        [SpecialOfferID],
        [ProductID]
    ) REFERENCES [AW_Sales].[SpecialOfferProduct](
        [SpecialOfferID],
        [ProductID]
    );
GO

ALTER TABLE [AW_Sales].[SalesOrderHeader] ADD 
    CONSTRAINT [FK_SalesOrderHeader_Address_BillToAddressID] FOREIGN KEY 
    (
        [BillToAddressID]
    ) REFERENCES [AW_Person].[Address](
        [AddressID]
    ),
    CONSTRAINT [FK_SalesOrderHeader_Address_ShipToAddressID] FOREIGN KEY 
    (
        [ShipToAddressID]
    ) REFERENCES [AW_Person].[Address](
        [AddressID]
    ),
    CONSTRAINT [FK_SalesOrderHeader_CreditCard_CreditCardID] FOREIGN KEY 
    (
        [CreditCardID]
    ) REFERENCES [AW_Sales].[CreditCard](
        [CreditCardID]
    ),
    CONSTRAINT [FK_SalesOrderHeader_CurrencyRate_CurrencyRateID] FOREIGN KEY 
    (
        [CurrencyRateID]
    ) REFERENCES [AW_Sales].[CurrencyRate](
        [CurrencyRateID]
    ),
    CONSTRAINT [FK_SalesOrderHeader_Customer_CustomerID] FOREIGN KEY 
    (
        [CustomerID]
    ) REFERENCES [AW_Sales].[Customer](
        [CustomerID]
    ),
    CONSTRAINT [FK_SalesOrderHeader_SalesAW_Person_SalesAW_PersonID] FOREIGN KEY 
    (
        [SalesAW_PersonID]
    ) REFERENCES [AW_Sales].[SalesAW_Person](
        [BusinessEntityID]
    ),
    CONSTRAINT [FK_SalesOrderHeader_ShipMethod_ShipMethodID] FOREIGN KEY 
    (
        [ShipMethodID]
    ) REFERENCES [AW_Purchasing].[ShipMethod](
        [ShipMethodID]
    ),
    CONSTRAINT [FK_SalesOrderHeader_SalesTerritory_TerritoryID] FOREIGN KEY 
    (
        [TerritoryID]
    ) REFERENCES [AW_Sales].[SalesTerritory](
        [TerritoryID]
    );
GO

ALTER TABLE [AW_Sales].[SalesOrderHeaderSalesReason] ADD 
    CONSTRAINT [FK_SalesOrderHeaderSalesReason_SalesReason_SalesReasonID] FOREIGN KEY 
    (
        [SalesReasonID]
    ) REFERENCES [AW_Sales].[SalesReason](
        [SalesReasonID]
    ),
    CONSTRAINT [FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID] FOREIGN KEY 
    (
        [SalesOrderID]
    ) REFERENCES [AW_Sales].[SalesOrderHeader](
        [SalesOrderID]
    ) ON DELETE CASCADE;
GO

ALTER TABLE [AW_Sales].[SalesAW_Person] ADD 
    CONSTRAINT [FK_SalesAW_Person_Employee_BusinessEntityID] FOREIGN KEY 
    (
        [BusinessEntityID]
    ) REFERENCES [AW_HumanResources].[Employee](
        [BusinessEntityID]
    ),
    CONSTRAINT [FK_SalesAW_Person_SalesTerritory_TerritoryID] FOREIGN KEY 
    (
        [TerritoryID]
    ) REFERENCES [AW_Sales].[SalesTerritory](
        [TerritoryID]
    );
GO

ALTER TABLE [AW_Sales].[SalesAW_PersonQuotaHistory] ADD 
    CONSTRAINT [FK_SalesAW_PersonQuotaHistory_SalesAW_Person_BusinessEntityID] FOREIGN KEY 
    (
        [BusinessEntityID]
    ) REFERENCES [AW_Sales].[SalesAW_Person](
        [BusinessEntityID]
    );
GO

ALTER TABLE [AW_Sales].[SalesTaxRate] ADD 
    CONSTRAINT [FK_SalesTaxRate_StateProvince_StateProvinceID] FOREIGN KEY 
    (
        [StateProvinceID]
    ) REFERENCES [AW_Person].[StateProvince](
        [StateProvinceID]
    );
GO

ALTER TABLE [AW_Sales].[SalesTerritory] ADD
	CONSTRAINT [FK_SalesTerritory_CountryRegion_CountryRegionCode] FOREIGN KEY
	(
		[CountryRegionCode]
	) REFERENCES [AW_Person].[CountryRegion] (
		[CountryRegionCode]
    );
GO

ALTER TABLE [AW_Sales].[SalesTerritoryHistory] ADD 
    CONSTRAINT [FK_SalesTerritoryHistory_SalesAW_Person_BusinessEntityID] FOREIGN KEY 
    (
        [BusinessEntityID]
    ) REFERENCES [AW_Sales].[SalesAW_Person](
        [BusinessEntityID]
    ),
    CONSTRAINT [FK_SalesTerritoryHistory_SalesTerritory_TerritoryID] FOREIGN KEY 
    (
        [TerritoryID]
    ) REFERENCES [AW_Sales].[SalesTerritory](
        [TerritoryID]
    );
GO

ALTER TABLE [AW_Sales].[ShoppingCartItem] ADD 
    CONSTRAINT [FK_ShoppingCartItem_Product_ProductID] FOREIGN KEY 
    (
        [ProductID]
    ) REFERENCES [AW_Production].[Product](
        [ProductID]
    );
GO

ALTER TABLE [AW_Sales].[SpecialOfferProduct] ADD 
    CONSTRAINT [FK_SpecialOfferProduct_Product_ProductID] FOREIGN KEY 
    (
        [ProductID]
    ) REFERENCES [AW_Production].[Product](
        [ProductID]
    ),
    CONSTRAINT [FK_SpecialOfferProduct_SpecialOffer_SpecialOfferID] FOREIGN KEY 
    (
        [SpecialOfferID]
    ) REFERENCES [AW_Sales].[SpecialOffer](
        [SpecialOfferID]
    );
GO

ALTER TABLE [AW_Person].[StateProvince] ADD 
    CONSTRAINT [FK_StateProvince_CountryRegion_CountryRegionCode] FOREIGN KEY 
    (
        [CountryRegionCode]
    ) REFERENCES [AW_Person].[CountryRegion](
        [CountryRegionCode]
    ), 
    CONSTRAINT [FK_StateProvince_SalesTerritory_TerritoryID] FOREIGN KEY 
    (
        [TerritoryID]
    ) REFERENCES [AW_Sales].[SalesTerritory](
        [TerritoryID]
    );
GO

ALTER TABLE [AW_Sales].[Store] ADD 
	CONSTRAINT [FK_Store_BusinessEntity_BusinessEntityID] FOREIGN KEY
	(
		[BusinessEntityID]
	) REFERENCES [AW_Person].[BusinessEntity](
		[BusinessEntityID]
	),
    CONSTRAINT [FK_Store_SalesAW_Person_SalesAW_PersonID] FOREIGN KEY 
    (
        [SalesAW_PersonID]
    ) REFERENCES [AW_Sales].[SalesAW_Person](
        [BusinessEntityID]
    );
GO



ALTER TABLE [AW_Production].[TransactionHistory] ADD 
    CONSTRAINT [FK_TransactionHistory_Product_ProductID] FOREIGN KEY 
    (
        [ProductID]
    ) REFERENCES [AW_Production].[Product](
        [ProductID]
    );
GO

ALTER TABLE [AW_Purchasing].[Vendor] ADD 
	CONSTRAINT [FK_Vendor_BusinessEntity_BusinessEntityID] FOREIGN KEY
	(
		[BusinessEntityID]
	) REFERENCES [AW_Person].[BusinessEntity](
		[BusinessEntityID]
	);
GO

ALTER TABLE [AW_Production].[WorkOrder] ADD 
    CONSTRAINT [FK_WorkOrder_Product_ProductID] FOREIGN KEY 
    (
        [ProductID]
    ) REFERENCES [AW_Production].[Product](
        [ProductID]
    ),
    CONSTRAINT [FK_WorkOrder_ScrapReason_ScrapReasonID] FOREIGN KEY 
    (
        [ScrapReasonID]
    ) REFERENCES [AW_Production].[ScrapReason](
        [ScrapReasonID]
    );
GO

ALTER TABLE [AW_Production].[WorkOrderRouting] ADD 
    CONSTRAINT [FK_WorkOrderRouting_Location_LocationID] FOREIGN KEY 
    (
        [LocationID]
    ) REFERENCES [AW_Production].[Location](
        [LocationID]
    ),
    CONSTRAINT [FK_WorkOrderRouting_WorkOrder_WorkOrderID] FOREIGN KEY 
    (
        [WorkOrderID]
    ) REFERENCES [AW_Production].[WorkOrder](
        [WorkOrderID]
    );
GO


-- ******************************************************
-- Add table triggers.
-- ******************************************************
PRINT '';
PRINT '*** Creating Table Triggers';
GO

CREATE TRIGGER [AW_HumanResources].[dEmployee] ON [AW_HumanResources].[Employee] 
INSTEAD OF DELETE NOT FOR REPLICATION AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN
        RAISERROR
            (N'Employees cannot be deleted. They can only be marked as not current.', -- Message
            10, -- Severity.
            1); -- State.

        -- Rollback any active or uncommittable transactions
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
    END;
END;
GO

CREATE TRIGGER [AW_Person].[iuAW_Person] ON [AW_Person].[AW_Person] 
AFTER INSERT, UPDATE NOT FOR REPLICATION AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    IF UPDATE([BusinessEntityID]) OR UPDATE([Demographics]) 
    BEGIN
        UPDATE [AW_Person].[AW_Person] 
        SET [AW_Person].[AW_Person].[Demographics] = N'<IndividualSurvey xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"> 
            <TotalPurchaseYTD>0.00</TotalPurchaseYTD> 
            </IndividualSurvey>' 
        FROM inserted 
        WHERE [AW_Person].[AW_Person].[BusinessEntityID] = inserted.[BusinessEntityID] 
            AND inserted.[Demographics] IS NULL;
        
        UPDATE [AW_Person].[AW_Person] 
        SET [Demographics].modify(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
            insert <TotalPurchaseYTD>0.00</TotalPurchaseYTD> 
            as first 
            into (/IndividualSurvey)[1]') 
        FROM inserted 
        WHERE [AW_Person].[AW_Person].[BusinessEntityID] = inserted.[BusinessEntityID] 
            AND inserted.[Demographics] IS NOT NULL 
            AND inserted.[Demographics].exist(N'declare default element namespace 
                "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
                /IndividualSurvey/TotalPurchaseYTD') <> 1;
    END;
END;
GO

CREATE TRIGGER [AW_Purchasing].[iPurchaseOrderDetail] ON [AW_Purchasing].[PurchaseOrderDetail] 
AFTER INSERT AS
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO [AW_Production].[TransactionHistory]
            ([ProductID]
            ,[ReferenceOrderID]
            ,[ReferenceOrderLineID]
            ,[TransactionType]
            ,[TransactionDate]
            ,[Quantity]
            ,[ActualCost])
        SELECT 
            inserted.[ProductID]
            ,inserted.[PurchaseOrderID]
            ,inserted.[PurchaseOrderDetailID]
            ,'P'
            ,GETDATE()
            ,inserted.[OrderQty]
            ,inserted.[UnitPrice]
        FROM inserted 
            INNER JOIN [AW_Purchasing].[PurchaseOrderHeader] 
            ON inserted.[PurchaseOrderID] = [AW_Purchasing].[PurchaseOrderHeader].[PurchaseOrderID];

        -- Update SubTotal in PurchaseOrderHeader record. Note that this causes the 
        -- PurchaseOrderHeader trigger to fire which will update the RevisionNumber.
        UPDATE [AW_Purchasing].[PurchaseOrderHeader]
        SET [AW_Purchasing].[PurchaseOrderHeader].[SubTotal] = 
            (SELECT SUM([AW_Purchasing].[PurchaseOrderDetail].[LineTotal])
                FROM [AW_Purchasing].[PurchaseOrderDetail]
                WHERE [AW_Purchasing].[PurchaseOrderHeader].[PurchaseOrderID] = [AW_Purchasing].[PurchaseOrderDetail].[PurchaseOrderID])
        WHERE [AW_Purchasing].[PurchaseOrderHeader].[PurchaseOrderID] IN (SELECT inserted.[PurchaseOrderID] FROM inserted);
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspPrintError];

        -- Rollback any active or uncommittable transactions before
        -- inserting information in the ErrorLog
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO

CREATE TRIGGER [AW_Purchasing].[uPurchaseOrderDetail] ON [AW_Purchasing].[PurchaseOrderDetail] 
AFTER UPDATE AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN TRY
        IF UPDATE([ProductID]) OR UPDATE([OrderQty]) OR UPDATE([UnitPrice])
        -- Insert record into TransactionHistory 
        BEGIN
            INSERT INTO [AW_Production].[TransactionHistory]
                ([ProductID]
                ,[ReferenceOrderID]
                ,[ReferenceOrderLineID]
                ,[TransactionType]
                ,[TransactionDate]
                ,[Quantity]
                ,[ActualCost])
            SELECT 
                inserted.[ProductID]
                ,inserted.[PurchaseOrderID]
                ,inserted.[PurchaseOrderDetailID]
                ,'P'
                ,GETDATE()
                ,inserted.[OrderQty]
                ,inserted.[UnitPrice]
            FROM inserted 
                INNER JOIN [AW_Purchasing].[PurchaseOrderDetail] 
                ON inserted.[PurchaseOrderID] = [AW_Purchasing].[PurchaseOrderDetail].[PurchaseOrderID];

            -- Update SubTotal in PurchaseOrderHeader record. Note that this causes the 
            -- PurchaseOrderHeader trigger to fire which will update the RevisionNumber.
            UPDATE [AW_Purchasing].[PurchaseOrderHeader]
            SET [AW_Purchasing].[PurchaseOrderHeader].[SubTotal] = 
                (SELECT SUM([AW_Purchasing].[PurchaseOrderDetail].[LineTotal])
                    FROM [AW_Purchasing].[PurchaseOrderDetail]
                    WHERE [AW_Purchasing].[PurchaseOrderHeader].[PurchaseOrderID] 
                        = [AW_Purchasing].[PurchaseOrderDetail].[PurchaseOrderID])
            WHERE [AW_Purchasing].[PurchaseOrderHeader].[PurchaseOrderID] 
                IN (SELECT inserted.[PurchaseOrderID] FROM inserted);

            UPDATE [AW_Purchasing].[PurchaseOrderDetail]
            SET [AW_Purchasing].[PurchaseOrderDetail].[ModifiedDate] = GETDATE()
            FROM inserted
            WHERE inserted.[PurchaseOrderID] = [AW_Purchasing].[PurchaseOrderDetail].[PurchaseOrderID]
                AND inserted.[PurchaseOrderDetailID] = [AW_Purchasing].[PurchaseOrderDetail].[PurchaseOrderDetailID];
        END;
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspPrintError];

        -- Rollback any active or uncommittable transactions before
        -- inserting information in the ErrorLog
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO

CREATE TRIGGER [AW_Purchasing].[uPurchaseOrderHeader] ON [AW_Purchasing].[PurchaseOrderHeader] 
AFTER UPDATE AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN TRY
        -- Update RevisionNumber for modification of any field EXCEPT the Status.
        IF NOT UPDATE([Status])
        BEGIN
            UPDATE [AW_Purchasing].[PurchaseOrderHeader]
            SET [AW_Purchasing].[PurchaseOrderHeader].[RevisionNumber] = 
                [AW_Purchasing].[PurchaseOrderHeader].[RevisionNumber] + 1
            WHERE [AW_Purchasing].[PurchaseOrderHeader].[PurchaseOrderID] IN 
                (SELECT inserted.[PurchaseOrderID] FROM inserted);
        END;
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspPrintError];

        -- Rollback any active or uncommittable transactions before
        -- inserting information in the ErrorLog
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO

CREATE TRIGGER [AW_Sales].[iduSalesOrderDetail] ON [AW_Sales].[SalesOrderDetail] 
AFTER INSERT, DELETE, UPDATE AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN TRY
        -- If inserting or updating these columns
        IF UPDATE([ProductID]) OR UPDATE([OrderQty]) OR UPDATE([UnitPrice]) OR UPDATE([UnitPriceDiscount]) 
        -- Insert record into TransactionHistory
        BEGIN
            INSERT INTO [AW_Production].[TransactionHistory]
                ([ProductID]
                ,[ReferenceOrderID]
                ,[ReferenceOrderLineID]
                ,[TransactionType]
                ,[TransactionDate]
                ,[Quantity]
                ,[ActualCost])
            SELECT 
                inserted.[ProductID]
                ,inserted.[SalesOrderID]
                ,inserted.[SalesOrderDetailID]
                ,'S'
                ,GETDATE()
                ,inserted.[OrderQty]
                ,inserted.[UnitPrice]
            FROM inserted 
                INNER JOIN [AW_Sales].[SalesOrderHeader] 
                ON inserted.[SalesOrderID] = [AW_Sales].[SalesOrderHeader].[SalesOrderID];

            UPDATE [AW_Person].[AW_Person] 
            SET [Demographics].modify('declare default element namespace 
                "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
                replace value of (/IndividualSurvey/TotalPurchaseYTD)[1] 
                with data(/IndividualSurvey/TotalPurchaseYTD)[1] + sql:column ("inserted.LineTotal")') 
            FROM inserted 
                INNER JOIN [AW_Sales].[SalesOrderHeader] AS SOH
                ON inserted.[SalesOrderID] = SOH.[SalesOrderID] 
                INNER JOIN [AW_Sales].[Customer] AS C
                ON SOH.[CustomerID] = C.[CustomerID]
            WHERE C.[AW_PersonID] = [AW_Person].[AW_Person].[BusinessEntityID];
        END;

        -- Update SubTotal in SalesOrderHeader record. Note that this causes the 
        -- SalesOrderHeader trigger to fire which will update the RevisionNumber.
        UPDATE [AW_Sales].[SalesOrderHeader]
        SET [AW_Sales].[SalesOrderHeader].[SubTotal] = 
            (SELECT SUM([AW_Sales].[SalesOrderDetail].[LineTotal])
                FROM [AW_Sales].[SalesOrderDetail]
                WHERE [AW_Sales].[SalesOrderHeader].[SalesOrderID] = [AW_Sales].[SalesOrderDetail].[SalesOrderID])
        WHERE [AW_Sales].[SalesOrderHeader].[SalesOrderID] IN (SELECT inserted.[SalesOrderID] FROM inserted);

        UPDATE [AW_Person].[AW_Person] 
        SET [Demographics].modify('declare default element namespace 
            "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
            replace value of (/IndividualSurvey/TotalPurchaseYTD)[1] 
            with data(/IndividualSurvey/TotalPurchaseYTD)[1] - sql:column("deleted.LineTotal")') 
        FROM deleted 
            INNER JOIN [AW_Sales].[SalesOrderHeader] 
            ON deleted.[SalesOrderID] = [AW_Sales].[SalesOrderHeader].[SalesOrderID] 
            INNER JOIN [AW_Sales].[Customer]
            ON [AW_Sales].[Customer].[CustomerID] = [AW_Sales].[SalesOrderHeader].[CustomerID]
        WHERE [AW_Sales].[Customer].[AW_PersonID] = [AW_Person].[AW_Person].[BusinessEntityID];
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspPrintError];

        -- Rollback any active or uncommittable transactions before
        -- inserting information in the ErrorLog
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO

CREATE TRIGGER [AW_Sales].[uSalesOrderHeader] ON [AW_Sales].[SalesOrderHeader] 
AFTER UPDATE NOT FOR REPLICATION AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN TRY
        -- Update RevisionNumber for modification of any field EXCEPT the Status.
        IF NOT UPDATE([Status])
        BEGIN
            UPDATE [AW_Sales].[SalesOrderHeader]
            SET [AW_Sales].[SalesOrderHeader].[RevisionNumber] = 
                [AW_Sales].[SalesOrderHeader].[RevisionNumber] + 1
            WHERE [AW_Sales].[SalesOrderHeader].[SalesOrderID] IN 
                (SELECT inserted.[SalesOrderID] FROM inserted);
        END;

        -- Update the SalesAW_Person SalesYTD when SubTotal is updated
        IF UPDATE([SubTotal])
        BEGIN
            DECLARE @StartDate datetime,
                    @EndDate datetime

            SET @StartDate = [dbo].[ufnGetAccountingStartDate]();
            SET @EndDate = [dbo].[ufnGetAccountingEndDate]();

            UPDATE [AW_Sales].[SalesAW_Person]
            SET [AW_Sales].[SalesAW_Person].[SalesYTD] = 
                (SELECT SUM([AW_Sales].[SalesOrderHeader].[SubTotal])
                FROM [AW_Sales].[SalesOrderHeader] 
                WHERE [AW_Sales].[SalesAW_Person].[BusinessEntityID] = [AW_Sales].[SalesOrderHeader].[SalesAW_PersonID]
                    AND ([AW_Sales].[SalesOrderHeader].[Status] = 5) -- Shipped
                    AND [AW_Sales].[SalesOrderHeader].[OrderDate] BETWEEN @StartDate AND @EndDate)
            WHERE [AW_Sales].[SalesAW_Person].[BusinessEntityID] 
                IN (SELECT DISTINCT inserted.[SalesAW_PersonID] FROM inserted 
                    WHERE inserted.[OrderDate] BETWEEN @StartDate AND @EndDate);

            -- Update the SalesTerritory SalesYTD when SubTotal is updated
            UPDATE [AW_Sales].[SalesTerritory]
            SET [AW_Sales].[SalesTerritory].[SalesYTD] = 
                (SELECT SUM([AW_Sales].[SalesOrderHeader].[SubTotal])
                FROM [AW_Sales].[SalesOrderHeader] 
                WHERE [AW_Sales].[SalesTerritory].[TerritoryID] = [AW_Sales].[SalesOrderHeader].[TerritoryID]
                    AND ([AW_Sales].[SalesOrderHeader].[Status] = 5) -- Shipped
                    AND [AW_Sales].[SalesOrderHeader].[OrderDate] BETWEEN @StartDate AND @EndDate)
            WHERE [AW_Sales].[SalesTerritory].[TerritoryID] 
                IN (SELECT DISTINCT inserted.[TerritoryID] FROM inserted 
                    WHERE inserted.[OrderDate] BETWEEN @StartDate AND @EndDate);
        END;
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspPrintError];

        -- Rollback any active or uncommittable transactions before
        -- inserting information in the ErrorLog
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO

CREATE TRIGGER [AW_Purchasing].[dVendor] ON [AW_Purchasing].[Vendor] 
INSTEAD OF DELETE NOT FOR REPLICATION AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @DeleteCount int;

        SELECT @DeleteCount = COUNT(*) FROM deleted;
        IF @DeleteCount > 0 
        BEGIN
            RAISERROR
                (N'Vendors cannot be deleted. They can only be marked as not active.', -- Message
                10, -- Severity.
                1); -- State.

        -- Rollback any active or uncommittable transactions
            IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION;
            END
        END;
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspPrintError];

        -- Rollback any active or uncommittable transactions before
        -- inserting information in the ErrorLog
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO

CREATE TRIGGER [AW_Production].[iWorkOrder] ON [AW_Production].[WorkOrder] 
AFTER INSERT AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO [AW_Production].[TransactionHistory](
            [ProductID]
            ,[ReferenceOrderID]
            ,[TransactionType]
            ,[TransactionDate]
            ,[Quantity]
            ,[ActualCost])
        SELECT 
            inserted.[ProductID]
            ,inserted.[WorkOrderID]
            ,'W'
            ,GETDATE()
            ,inserted.[OrderQty]
            ,0
        FROM inserted;
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspPrintError];

        -- Rollback any active or uncommittable transactions before
        -- inserting information in the ErrorLog
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO

CREATE TRIGGER [AW_Production].[uWorkOrder] ON [AW_Production].[WorkOrder] 
AFTER UPDATE AS 
BEGIN
    DECLARE @Count int;

    SET @Count = @@ROWCOUNT;
    IF @Count = 0 
        RETURN;

    SET NOCOUNT ON;

    BEGIN TRY
        IF UPDATE([ProductID]) OR UPDATE([OrderQty])
        BEGIN
            INSERT INTO [AW_Production].[TransactionHistory](
                [ProductID]
                ,[ReferenceOrderID]
                ,[TransactionType]
                ,[TransactionDate]
                ,[Quantity])
            SELECT 
                inserted.[ProductID]
                ,inserted.[WorkOrderID]
                ,'W'
                ,GETDATE()
                ,inserted.[OrderQty]
            FROM inserted;
        END;
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspPrintError];

        -- Rollback any active or uncommittable transactions before
        -- inserting information in the ErrorLog
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO


-- ******************************************************
-- Add database views.
-- ******************************************************
PRINT '';
PRINT '*** Creating Table Views';
GO

CREATE VIEW [AW_Person].[vAdditionalContactInfo] 
AS 
SELECT 
    [BusinessEntityID] 
    ,[FirstName]
    ,[MiddleName]
    ,[LastName]
    ,[ContactInfo].ref.value(N'declare namespace ci="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo"; 
        declare namespace act="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes"; 
        (act:telephoneNumber)[1]/act:number', 'nvarchar(50)') AS [TelephoneNumber] 
    ,LTRIM(RTRIM([ContactInfo].ref.value(N'declare namespace ci="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo"; 
        declare namespace act="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes"; 
        (act:telephoneNumber/act:SpecialInstructions/text())[1]', 'nvarchar(max)'))) AS [TelephoneSpecialInstructions] 
    ,[ContactInfo].ref.value(N'declare namespace ci="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo"; 
        declare namespace act="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes";
        (act:homePostalAddress/act:Street)[1]', 'nvarchar(50)') AS [Street] 
    ,[ContactInfo].ref.value(N'declare namespace ci="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo"; 
        declare namespace act="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes"; 
        (act:homePostalAddress/act:City)[1]', 'nvarchar(50)') AS [City] 
    ,[ContactInfo].ref.value(N'declare namespace ci="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo"; 
        declare namespace act="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes"; 
        (act:homePostalAddress/act:StateProvince)[1]', 'nvarchar(50)') AS [StateProvince] 
    ,[ContactInfo].ref.value(N'declare namespace ci="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo"; 
        declare namespace act="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes"; 
        (act:homePostalAddress/act:PostalCode)[1]', 'nvarchar(50)') AS [PostalCode] 
    ,[ContactInfo].ref.value(N'declare namespace ci="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo"; 
        declare namespace act="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes"; 
        (act:homePostalAddress/act:CountryRegion)[1]', 'nvarchar(50)') AS [CountryRegion] 
    ,[ContactInfo].ref.value(N'declare namespace ci="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo"; 
        declare namespace act="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes"; 
        (act:homePostalAddress/act:SpecialInstructions/text())[1]', 'nvarchar(max)') AS [HomeAddressSpecialInstructions] 
    ,[ContactInfo].ref.value(N'declare namespace ci="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo"; 
        declare namespace act="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes"; 
        (act:eMail/act:eMailAddress)[1]', 'nvarchar(128)') AS [EMailAddress] 
    ,LTRIM(RTRIM([ContactInfo].ref.value(N'declare namespace ci="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo"; 
        declare namespace act="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes"; 
        (act:eMail/act:SpecialInstructions/text())[1]', 'nvarchar(max)'))) AS [EMailSpecialInstructions] 
    ,[ContactInfo].ref.value(N'declare namespace ci="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo"; 
        declare namespace act="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactTypes"; 
        (act:eMail/act:SpecialInstructions/act:telephoneNumber/act:number)[1]', 'nvarchar(50)') AS [EMailTelephoneNumber] 
    ,[rowguid] 
    ,[ModifiedDate]
FROM [AW_Person].[AW_Person]
OUTER APPLY [AdditionalContactInfo].nodes(
    'declare namespace ci="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ContactInfo"; 
    /ci:AdditionalContactInfo') AS ContactInfo(ref) 
WHERE [AdditionalContactInfo] IS NOT NULL;
GO

CREATE VIEW [AW_HumanResources].[vEmployee] 
AS 
SELECT 
    e.[BusinessEntityID]
    ,p.[Title]
    ,p.[FirstName]
    ,p.[MiddleName]
    ,p.[LastName]
    ,p.[Suffix]
    ,e.[JobTitle]  
    ,pp.[PhoneNumber]
    ,pnt.[Name] AS [PhoneNumberType]
    ,ea.[EmailAddress]
    ,p.[EmailPromotion]
    ,a.[AddressLine1]
    ,a.[AddressLine2]
    ,a.[City]
    ,sp.[Name] AS [StateProvinceName] 
    ,a.[PostalCode]
    ,cr.[Name] AS [CountryRegionName] 
    ,p.[AdditionalContactInfo]
FROM [AW_HumanResources].[Employee] e
	INNER JOIN [AW_Person].[AW_Person] p
	ON p.[BusinessEntityID] = e.[BusinessEntityID]
    INNER JOIN [AW_Person].[BusinessEntityAddress] bea 
    ON bea.[BusinessEntityID] = e.[BusinessEntityID] 
    INNER JOIN [AW_Person].[Address] a 
    ON a.[AddressID] = bea.[AddressID]
    INNER JOIN [AW_Person].[StateProvince] sp 
    ON sp.[StateProvinceID] = a.[StateProvinceID]
    INNER JOIN [AW_Person].[CountryRegion] cr 
    ON cr.[CountryRegionCode] = sp.[CountryRegionCode]
    LEFT OUTER JOIN [AW_Person].[AW_PersonPhone] pp
    ON pp.BusinessEntityID = p.[BusinessEntityID]
    LEFT OUTER JOIN [AW_Person].[PhoneNumberType] pnt
    ON pp.[PhoneNumberTypeID] = pnt.[PhoneNumberTypeID]
    LEFT OUTER JOIN [AW_Person].[EmailAddress] ea
    ON p.[BusinessEntityID] = ea.[BusinessEntityID];
GO

CREATE VIEW [AW_HumanResources].[vEmployeeDepartment] 
AS 
SELECT 
    e.[BusinessEntityID] 
    ,p.[Title] 
    ,p.[FirstName] 
    ,p.[MiddleName] 
    ,p.[LastName] 
    ,p.[Suffix] 
    ,e.[JobTitle]
    ,d.[Name] AS [Department] 
    ,d.[GroupName] 
    ,edh.[StartDate] 
FROM [AW_HumanResources].[Employee] e
	INNER JOIN [AW_Person].[AW_Person] p
	ON p.[BusinessEntityID] = e.[BusinessEntityID]
    INNER JOIN [AW_HumanResources].[EmployeeDepartmentHistory] edh 
    ON e.[BusinessEntityID] = edh.[BusinessEntityID] 
    INNER JOIN [AW_HumanResources].[Department] d 
    ON edh.[DepartmentID] = d.[DepartmentID] 
WHERE edh.EndDate IS NULL
GO

CREATE VIEW [AW_HumanResources].[vEmployeeDepartmentHistory] 
AS 
SELECT 
    e.[BusinessEntityID] 
    ,p.[Title] 
    ,p.[FirstName] 
    ,p.[MiddleName] 
    ,p.[LastName] 
    ,p.[Suffix] 
    ,s.[Name] AS [Shift]
    ,d.[Name] AS [Department] 
    ,d.[GroupName] 
    ,edh.[StartDate] 
    ,edh.[EndDate]
FROM [AW_HumanResources].[Employee] e
	INNER JOIN [AW_Person].[AW_Person] p
	ON p.[BusinessEntityID] = e.[BusinessEntityID]
    INNER JOIN [AW_HumanResources].[EmployeeDepartmentHistory] edh 
    ON e.[BusinessEntityID] = edh.[BusinessEntityID] 
    INNER JOIN [AW_HumanResources].[Department] d 
    ON edh.[DepartmentID] = d.[DepartmentID] 
    INNER JOIN [AW_HumanResources].[Shift] s
    ON s.[ShiftID] = edh.[ShiftID];
GO

CREATE VIEW [AW_Sales].[vIndividualCustomer] 
AS 
SELECT 
    p.[BusinessEntityID]
    ,p.[Title]
    ,p.[FirstName]
    ,p.[MiddleName]
    ,p.[LastName]
    ,p.[Suffix]
    ,pp.[PhoneNumber]
	,pnt.[Name] AS [PhoneNumberType]
    ,ea.[EmailAddress]
    ,p.[EmailPromotion]
    ,at.[Name] AS [AddressType]
    ,a.[AddressLine1]
    ,a.[AddressLine2]
    ,a.[City]
    ,[StateProvinceName] = sp.[Name]
    ,a.[PostalCode]
    ,[CountryRegionName] = cr.[Name]
    ,p.[Demographics]
FROM [AW_Person].[AW_Person] p
    INNER JOIN [AW_Person].[BusinessEntityAddress] bea 
    ON bea.[BusinessEntityID] = p.[BusinessEntityID] 
    INNER JOIN [AW_Person].[Address] a 
    ON a.[AddressID] = bea.[AddressID]
    INNER JOIN [AW_Person].[StateProvince] sp 
    ON sp.[StateProvinceID] = a.[StateProvinceID]
    INNER JOIN [AW_Person].[CountryRegion] cr 
    ON cr.[CountryRegionCode] = sp.[CountryRegionCode]
    INNER JOIN [AW_Person].[AddressType] at 
    ON at.[AddressTypeID] = bea.[AddressTypeID]
	INNER JOIN [AW_Sales].[Customer] c
	ON c.[AW_PersonID] = p.[BusinessEntityID]
	LEFT OUTER JOIN [AW_Person].[EmailAddress] ea
	ON ea.[BusinessEntityID] = p.[BusinessEntityID]
	LEFT OUTER JOIN [AW_Person].[AW_PersonPhone] pp
	ON pp.[BusinessEntityID] = p.[BusinessEntityID]
	LEFT OUTER JOIN [AW_Person].[PhoneNumberType] pnt
	ON pnt.[PhoneNumberTypeID] = pp.[PhoneNumberTypeID]
WHERE c.StoreID IS NULL;
GO

CREATE VIEW [AW_Sales].[vAW_PersonDemographics] 
AS 
SELECT 
    p.[BusinessEntityID] 
    ,[IndividualSurvey].[ref].[value](N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        TotalPurchaseYTD[1]', 'money') AS [TotalPurchaseYTD] 
    ,CONVERT(datetime, REPLACE([IndividualSurvey].[ref].[value](N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        DateFirstPurchase[1]', 'nvarchar(20)') ,'Z', ''), 101) AS [DateFirstPurchase] 
    ,CONVERT(datetime, REPLACE([IndividualSurvey].[ref].[value](N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        BirthDate[1]', 'nvarchar(20)') ,'Z', ''), 101) AS [BirthDate] 
    ,[IndividualSurvey].[ref].[value](N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        MaritalStatus[1]', 'nvarchar(1)') AS [MaritalStatus] 
    ,[IndividualSurvey].[ref].[value](N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        YearlyIncome[1]', 'nvarchar(30)') AS [YearlyIncome] 
    ,[IndividualSurvey].[ref].[value](N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        Gender[1]', 'nvarchar(1)') AS [Gender] 
    ,[IndividualSurvey].[ref].[value](N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        TotalChildren[1]', 'integer') AS [TotalChildren] 
    ,[IndividualSurvey].[ref].[value](N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        NumberChildrenAtHome[1]', 'integer') AS [NumberChildrenAtHome] 
    ,[IndividualSurvey].[ref].[value](N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        Education[1]', 'nvarchar(30)') AS [Education] 
    ,[IndividualSurvey].[ref].[value](N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        Occupation[1]', 'nvarchar(30)') AS [Occupation] 
    ,[IndividualSurvey].[ref].[value](N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        HomeOwnerFlag[1]', 'bit') AS [HomeOwnerFlag] 
    ,[IndividualSurvey].[ref].[value](N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
        NumberCarsOwned[1]', 'integer') AS [NumberCarsOwned] 
FROM [AW_Person].[AW_Person] p 
CROSS APPLY p.[Demographics].nodes(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; 
    /IndividualSurvey') AS [IndividualSurvey](ref) 
WHERE [Demographics] IS NOT NULL;
GO

CREATE VIEW [AW_HumanResources].[vJobCandidate] 
AS 
SELECT 
    jc.[JobCandidateID] 
    ,jc.[BusinessEntityID] 
    ,[Resume].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (/Resume/Name/Name.Prefix)[1]', 'nvarchar(30)') AS [Name.Prefix] 
    ,[Resume].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume";
        (/Resume/Name/Name.First)[1]', 'nvarchar(30)') AS [Name.First] 
    ,[Resume].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (/Resume/Name/Name.Middle)[1]', 'nvarchar(30)') AS [Name.Middle] 
    ,[Resume].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (/Resume/Name/Name.Last)[1]', 'nvarchar(30)') AS [Name.Last] 
    ,[Resume].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (/Resume/Name/Name.Suffix)[1]', 'nvarchar(30)') AS [Name.Suffix] 
    ,[Resume].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (/Resume/Skills)[1]', 'nvarchar(max)') AS [Skills] 
    ,[Resume].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Address/Addr.Type)[1]', 'nvarchar(30)') AS [Addr.Type]
    ,[Resume].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Address/Addr.Location/Location/Loc.CountryRegion)[1]', 'nvarchar(100)') AS [Addr.Loc.CountryRegion]
    ,[Resume].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Address/Addr.Location/Location/Loc.State)[1]', 'nvarchar(100)') AS [Addr.Loc.State]
    ,[Resume].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Address/Addr.Location/Location/Loc.City)[1]', 'nvarchar(100)') AS [Addr.Loc.City]
    ,[Resume].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Address/Addr.PostalCode)[1]', 'nvarchar(20)') AS [Addr.PostalCode]
    ,[Resume].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (/Resume/EMail)[1]', 'nvarchar(max)') AS [EMail] 
    ,[Resume].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (/Resume/WebSite)[1]', 'nvarchar(max)') AS [WebSite] 
    ,jc.[ModifiedDate] 
FROM [AW_HumanResources].[JobCandidate] jc 
CROSS APPLY jc.[Resume].nodes(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
    /Resume') AS Resume(ref);
GO

CREATE VIEW [AW_HumanResources].[vJobCandidateEmployment] 
AS 
SELECT 
    jc.[JobCandidateID] 
    ,CONVERT(datetime, REPLACE([Employment].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Emp.StartDate)[1]', 'nvarchar(20)') ,'Z', ''), 101) AS [Emp.StartDate] 
    ,CONVERT(datetime, REPLACE([Employment].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Emp.EndDate)[1]', 'nvarchar(20)') ,'Z', ''), 101) AS [Emp.EndDate] 
    ,[Employment].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Emp.OrgName)[1]', 'nvarchar(100)') AS [Emp.OrgName]
    ,[Employment].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Emp.JobTitle)[1]', 'nvarchar(100)') AS [Emp.JobTitle]
    ,[Employment].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Emp.Responsibility)[1]', 'nvarchar(max)') AS [Emp.Responsibility]
    ,[Employment].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Emp.FunctionCategory)[1]', 'nvarchar(max)') AS [Emp.FunctionCategory]
    ,[Employment].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Emp.IndustryCategory)[1]', 'nvarchar(max)') AS [Emp.IndustryCategory]
    ,[Employment].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Emp.Location/Location/Loc.CountryRegion)[1]', 'nvarchar(max)') AS [Emp.Loc.CountryRegion]
    ,[Employment].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Emp.Location/Location/Loc.State)[1]', 'nvarchar(max)') AS [Emp.Loc.State]
    ,[Employment].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Emp.Location/Location/Loc.City)[1]', 'nvarchar(max)') AS [Emp.Loc.City]
FROM [AW_HumanResources].[JobCandidate] jc 
CROSS APPLY jc.[Resume].nodes(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
    /Resume/Employment') AS Employment(ref);
GO

CREATE VIEW [AW_HumanResources].[vJobCandidateEducation] 
AS 
SELECT 
    jc.[JobCandidateID] 
    ,[Education].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Edu.Level)[1]', 'nvarchar(max)') AS [Edu.Level]
    ,CONVERT(datetime, REPLACE([Education].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Edu.StartDate)[1]', 'nvarchar(20)') ,'Z', ''), 101) AS [Edu.StartDate] 
    ,CONVERT(datetime, REPLACE([Education].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Edu.EndDate)[1]', 'nvarchar(20)') ,'Z', ''), 101) AS [Edu.EndDate] 
    ,[Education].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Edu.Degree)[1]', 'nvarchar(50)') AS [Edu.Degree]
    ,[Education].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Edu.Major)[1]', 'nvarchar(50)') AS [Edu.Major]
    ,[Education].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Edu.Minor)[1]', 'nvarchar(50)') AS [Edu.Minor]
    ,[Education].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Edu.GPA)[1]', 'nvarchar(5)') AS [Edu.GPA]
    ,[Education].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Edu.GPAScale)[1]', 'nvarchar(5)') AS [Edu.GPAScale]
    ,[Education].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Edu.School)[1]', 'nvarchar(100)') AS [Edu.School]
    ,[Education].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Edu.Location/Location/Loc.CountryRegion)[1]', 'nvarchar(100)') AS [Edu.Loc.CountryRegion]
    ,[Education].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Edu.Location/Location/Loc.State)[1]', 'nvarchar(100)') AS [Edu.Loc.State]
    ,[Education].ref.value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
        (Edu.Location/Location/Loc.City)[1]', 'nvarchar(100)') AS [Edu.Loc.City]
FROM [AW_HumanResources].[JobCandidate] jc 
CROSS APPLY jc.[Resume].nodes(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume"; 
    /Resume/Education') AS [Education](ref);
GO

CREATE VIEW [AW_Production].[vProductAndDescription] 
WITH SCHEMABINDING 
AS 
-- View (indexed or standard) to display products and product descriptions by language.
SELECT 
    p.[ProductID] 
    ,p.[Name] 
    ,pm.[Name] AS [ProductModel] 
    ,pmx.[CultureID] 
    ,pd.[Description] 
FROM [AW_Production].[Product] p 
    INNER JOIN [AW_Production].[ProductModel] pm 
    ON p.[ProductModelID] = pm.[ProductModelID] 
    INNER JOIN [AW_Production].[ProductModelProductDescriptionCulture] pmx 
    ON pm.[ProductModelID] = pmx.[ProductModelID] 
    INNER JOIN [AW_Production].[ProductDescription] pd 
    ON pmx.[ProductDescriptionID] = pd.[ProductDescriptionID];
GO

-- Index the vProductAndDescription view
CREATE UNIQUE CLUSTERED INDEX [IX_vProductAndDescription] ON [AW_Production].[vProductAndDescription]([CultureID], [ProductID]);
GO

CREATE VIEW [AW_Production].[vProductModelCatalogDescription] 
AS 
SELECT 
    [ProductModelID] 
    ,[Name] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        declare namespace html="http://www.w3.org/1999/xhtml"; 
        (/p1:ProductDescription/p1:Summary/html:p)[1]', 'nvarchar(max)') AS [Summary] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        (/p1:ProductDescription/p1:Manufacturer/p1:Name)[1]', 'nvarchar(max)') AS [Manufacturer] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        (/p1:ProductDescription/p1:Manufacturer/p1:Copyright)[1]', 'nvarchar(30)') AS [Copyright] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        (/p1:ProductDescription/p1:Manufacturer/p1:ProductURL)[1]', 'nvarchar(256)') AS [ProductURL] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        declare namespace wm="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelWarrAndMain"; 
        (/p1:ProductDescription/p1:Features/wm:Warranty/wm:WarrantyPeriod)[1]', 'nvarchar(256)') AS [WarrantyPeriod] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        declare namespace wm="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelWarrAndMain"; 
        (/p1:ProductDescription/p1:Features/wm:Warranty/wm:Description)[1]', 'nvarchar(256)') AS [WarrantyDescription] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        declare namespace wm="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelWarrAndMain"; 
        (/p1:ProductDescription/p1:Features/wm:Maintenance/wm:NoOfYears)[1]', 'nvarchar(256)') AS [NoOfYears] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        declare namespace wm="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelWarrAndMain"; 
        (/p1:ProductDescription/p1:Features/wm:Maintenance/wm:Description)[1]', 'nvarchar(256)') AS [MaintenanceDescription] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        declare namespace wf="http://www.adventure-works.com/schemas/OtherFeatures"; 
        (/p1:ProductDescription/p1:Features/wf:wheel)[1]', 'nvarchar(256)') AS [Wheel] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        declare namespace wf="http://www.adventure-works.com/schemas/OtherFeatures"; 
        (/p1:ProductDescription/p1:Features/wf:saddle)[1]', 'nvarchar(256)') AS [Saddle] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        declare namespace wf="http://www.adventure-works.com/schemas/OtherFeatures"; 
        (/p1:ProductDescription/p1:Features/wf:pedal)[1]', 'nvarchar(256)') AS [Pedal] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        declare namespace wf="http://www.adventure-works.com/schemas/OtherFeatures"; 
        (/p1:ProductDescription/p1:Features/wf:BikeFrame)[1]', 'nvarchar(max)') AS [BikeFrame] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        declare namespace wf="http://www.adventure-works.com/schemas/OtherFeatures"; 
        (/p1:ProductDescription/p1:Features/wf:crankset)[1]', 'nvarchar(256)') AS [Crankset] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        (/p1:ProductDescription/p1:Picture/p1:Angle)[1]', 'nvarchar(256)') AS [PictureAngle] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        (/p1:ProductDescription/p1:Picture/p1:Size)[1]', 'nvarchar(256)') AS [PictureSize] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        (/p1:ProductDescription/p1:Picture/p1:ProductPhotoID)[1]', 'nvarchar(256)') AS [ProductPhotoID] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        (/p1:ProductDescription/p1:Specifications/Material)[1]', 'nvarchar(256)') AS [Material] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        (/p1:ProductDescription/p1:Specifications/Color)[1]', 'nvarchar(256)') AS [Color] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        (/p1:ProductDescription/p1:Specifications/ProductLine)[1]', 'nvarchar(256)') AS [ProductLine] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        (/p1:ProductDescription/p1:Specifications/Style)[1]', 'nvarchar(256)') AS [Style] 
    ,[CatalogDescription].value(N'declare namespace p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription"; 
        (/p1:ProductDescription/p1:Specifications/RiderExperience)[1]', 'nvarchar(1024)') AS [RiderExperience] 
    ,[rowguid] 
    ,[ModifiedDate]
FROM [AW_Production].[ProductModel] 
WHERE [CatalogDescription] IS NOT NULL;
GO

CREATE VIEW [AW_Production].[vProductModelInstructions] 
AS 
SELECT 
    [ProductModelID] 
    ,[Name] 
    ,[Instructions].value(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions"; 
        (/root/text())[1]', 'nvarchar(max)') AS [Instructions] 
    ,[MfgInstructions].ref.value('@LocationID[1]', 'int') AS [LocationID] 
    ,[MfgInstructions].ref.value('@SetupHours[1]', 'decimal(9, 4)') AS [SetupHours] 
    ,[MfgInstructions].ref.value('@MachineHours[1]', 'decimal(9, 4)') AS [MachineHours] 
    ,[MfgInstructions].ref.value('@LaborHours[1]', 'decimal(9, 4)') AS [LaborHours] 
    ,[MfgInstructions].ref.value('@LotSize[1]', 'int') AS [LotSize] 
    ,[Steps].ref.value('string(.)[1]', 'nvarchar(1024)') AS [Step] 
    ,[rowguid] 
    ,[ModifiedDate]
FROM [AW_Production].[ProductModel] 
CROSS APPLY [Instructions].nodes(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions"; 
    /root/Location') MfgInstructions(ref)
CROSS APPLY [MfgInstructions].ref.nodes('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions"; 
    step') Steps(ref);
GO

CREATE VIEW [AW_Sales].[vSalesAW_Person] 
AS 
SELECT 
    s.[BusinessEntityID]
    ,p.[Title]
    ,p.[FirstName]
    ,p.[MiddleName]
    ,p.[LastName]
    ,p.[Suffix]
    ,e.[JobTitle]
    ,pp.[PhoneNumber]
	,pnt.[Name] AS [PhoneNumberType]
    ,ea.[EmailAddress]
    ,p.[EmailPromotion]
    ,a.[AddressLine1]
    ,a.[AddressLine2]
    ,a.[City]
    ,[StateProvinceName] = sp.[Name]
    ,a.[PostalCode]
    ,[CountryRegionName] = cr.[Name]
    ,[TerritoryName] = st.[Name]
    ,[TerritoryGroup] = st.[Group]
    ,s.[SalesQuota]
    ,s.[SalesYTD]
    ,s.[SalesLastYear]
FROM [AW_Sales].[SalesAW_Person] s
    INNER JOIN [AW_HumanResources].[Employee] e 
    ON e.[BusinessEntityID] = s.[BusinessEntityID]
	INNER JOIN [AW_Person].[AW_Person] p
	ON p.[BusinessEntityID] = s.[BusinessEntityID]
    INNER JOIN [AW_Person].[BusinessEntityAddress] bea 
    ON bea.[BusinessEntityID] = s.[BusinessEntityID] 
    INNER JOIN [AW_Person].[Address] a 
    ON a.[AddressID] = bea.[AddressID]
    INNER JOIN [AW_Person].[StateProvince] sp 
    ON sp.[StateProvinceID] = a.[StateProvinceID]
    INNER JOIN [AW_Person].[CountryRegion] cr 
    ON cr.[CountryRegionCode] = sp.[CountryRegionCode]
    LEFT OUTER JOIN [AW_Sales].[SalesTerritory] st 
    ON st.[TerritoryID] = s.[TerritoryID]
	LEFT OUTER JOIN [AW_Person].[EmailAddress] ea
	ON ea.[BusinessEntityID] = p.[BusinessEntityID]
	LEFT OUTER JOIN [AW_Person].[AW_PersonPhone] pp
	ON pp.[BusinessEntityID] = p.[BusinessEntityID]
	LEFT OUTER JOIN [AW_Person].[PhoneNumberType] pnt
	ON pnt.[PhoneNumberTypeID] = pp.[PhoneNumberTypeID];
GO

CREATE VIEW [AW_Sales].[vSalesAW_PersonSalesByFiscalYears] 
AS 
SELECT 
    pvt.[SalesAW_PersonID]
    ,pvt.[FullName]
    ,pvt.[JobTitle]
    ,pvt.[SalesTerritory]
    ,pvt.[2002]
    ,pvt.[2003]
    ,pvt.[2004] 
FROM (SELECT 
        soh.[SalesAW_PersonID]
        ,p.[FirstName] + ' ' + COALESCE(p.[MiddleName], '') + ' ' + p.[LastName] AS [FullName]
        ,e.[JobTitle]
        ,st.[Name] AS [SalesTerritory]
        ,soh.[SubTotal]
        ,YEAR(DATEADD(m, 6, soh.[OrderDate])) AS [FiscalYear] 
    FROM [AW_Sales].[SalesAW_Person] sp 
        INNER JOIN [AW_Sales].[SalesOrderHeader] soh 
        ON sp.[BusinessEntityID] = soh.[SalesAW_PersonID]
        INNER JOIN [AW_Sales].[SalesTerritory] st 
        ON sp.[TerritoryID] = st.[TerritoryID] 
        INNER JOIN [AW_HumanResources].[Employee] e 
        ON soh.[SalesAW_PersonID] = e.[BusinessEntityID] 
		INNER JOIN [AW_Person].[AW_Person] p
		ON p.[BusinessEntityID] = sp.[BusinessEntityID]
	 ) AS soh 
PIVOT 
(
    SUM([SubTotal]) 
    FOR [FiscalYear] 
    IN ([2002], [2003], [2004])
) AS pvt;
GO

CREATE VIEW [AW_Person].[vStateProvinceCountryRegion] 
WITH SCHEMABINDING 
AS 
SELECT 
    sp.[StateProvinceID] 
    ,sp.[StateProvinceCode] 
    ,sp.[IsOnlyStateProvinceFlag] 
    ,sp.[Name] AS [StateProvinceName] 
    ,sp.[TerritoryID] 
    ,cr.[CountryRegionCode] 
    ,cr.[Name] AS [CountryRegionName]
FROM [AW_Person].[StateProvince] sp 
    INNER JOIN [AW_Person].[CountryRegion] cr 
    ON sp.[CountryRegionCode] = cr.[CountryRegionCode];
GO

-- Index the vStateProvinceCountryRegion view
CREATE UNIQUE CLUSTERED INDEX [IX_vStateProvinceCountryRegion] ON [AW_Person].[vStateProvinceCountryRegion]([StateProvinceID], [CountryRegionCode]);
GO

CREATE VIEW [AW_Sales].[vStoreWithDemographics] AS 
SELECT 
    s.[BusinessEntityID] 
    ,s.[Name] 
    ,s.[Demographics].value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; 
        (/StoreSurvey/AnnualSales)[1]', 'money') AS [AnnualSales] 
    ,s.[Demographics].value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; 
        (/StoreSurvey/AnnualRevenue)[1]', 'money') AS [AnnualRevenue] 
    ,s.[Demographics].value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; 
        (/StoreSurvey/BankName)[1]', 'nvarchar(50)') AS [BankName] 
    ,s.[Demographics].value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; 
        (/StoreSurvey/BusinessType)[1]', 'nvarchar(5)') AS [BusinessType] 
    ,s.[Demographics].value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; 
        (/StoreSurvey/YearOpened)[1]', 'integer') AS [YearOpened] 
    ,s.[Demographics].value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; 
        (/StoreSurvey/Specialty)[1]', 'nvarchar(50)') AS [Specialty] 
    ,s.[Demographics].value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; 
        (/StoreSurvey/SquareFeet)[1]', 'integer') AS [SquareFeet] 
    ,s.[Demographics].value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; 
        (/StoreSurvey/Brands)[1]', 'nvarchar(30)') AS [Brands] 
    ,s.[Demographics].value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; 
        (/StoreSurvey/Internet)[1]', 'nvarchar(30)') AS [Internet] 
    ,s.[Demographics].value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey"; 
        (/StoreSurvey/NumberEmployees)[1]', 'integer') AS [NumberEmployees] 
FROM [AW_Sales].[Store] s;
GO

CREATE VIEW [AW_Sales].[vStoreWithContacts] AS 
SELECT 
    s.[BusinessEntityID] 
    ,s.[Name] 
    ,ct.[Name] AS [ContactType] 
    ,p.[Title] 
    ,p.[FirstName] 
    ,p.[MiddleName] 
    ,p.[LastName] 
    ,p.[Suffix] 
    ,pp.[PhoneNumber] 
	,pnt.[Name] AS [PhoneNumberType]
    ,ea.[EmailAddress] 
    ,p.[EmailPromotion] 
FROM [AW_Sales].[Store] s
    INNER JOIN [AW_Person].[BusinessEntityContact] bec 
    ON bec.[BusinessEntityID] = s.[BusinessEntityID]
	INNER JOIN [AW_Person].[ContactType] ct
	ON ct.[ContactTypeID] = bec.[ContactTypeID]
	INNER JOIN [AW_Person].[AW_Person] p
	ON p.[BusinessEntityID] = bec.[AW_PersonID]
	LEFT OUTER JOIN [AW_Person].[EmailAddress] ea
	ON ea.[BusinessEntityID] = p.[BusinessEntityID]
	LEFT OUTER JOIN [AW_Person].[AW_PersonPhone] pp
	ON pp.[BusinessEntityID] = p.[BusinessEntityID]
	LEFT OUTER JOIN [AW_Person].[PhoneNumberType] pnt
	ON pnt.[PhoneNumberTypeID] = pp.[PhoneNumberTypeID];
GO

CREATE VIEW [AW_Sales].[vStoreWithAddresses] AS 
SELECT 
    s.[BusinessEntityID] 
    ,s.[Name] 
    ,at.[Name] AS [AddressType]
    ,a.[AddressLine1] 
    ,a.[AddressLine2] 
    ,a.[City] 
    ,sp.[Name] AS [StateProvinceName] 
    ,a.[PostalCode] 
    ,cr.[Name] AS [CountryRegionName] 
FROM [AW_Sales].[Store] s
    INNER JOIN [AW_Person].[BusinessEntityAddress] bea 
    ON bea.[BusinessEntityID] = s.[BusinessEntityID] 
    INNER JOIN [AW_Person].[Address] a 
    ON a.[AddressID] = bea.[AddressID]
    INNER JOIN [AW_Person].[StateProvince] sp 
    ON sp.[StateProvinceID] = a.[StateProvinceID]
    INNER JOIN [AW_Person].[CountryRegion] cr 
    ON cr.[CountryRegionCode] = sp.[CountryRegionCode]
    INNER JOIN [AW_Person].[AddressType] at 
    ON at.[AddressTypeID] = bea.[AddressTypeID];
GO

CREATE VIEW [AW_Purchasing].[vVendorWithContacts] AS 
SELECT 
    v.[BusinessEntityID]
    ,v.[Name]
    ,ct.[Name] AS [ContactType] 
    ,p.[Title] 
    ,p.[FirstName] 
    ,p.[MiddleName] 
    ,p.[LastName] 
    ,p.[Suffix] 
    ,pp.[PhoneNumber] 
	,pnt.[Name] AS [PhoneNumberType]
    ,ea.[EmailAddress] 
    ,p.[EmailPromotion] 
FROM [AW_Purchasing].[Vendor] v
    INNER JOIN [AW_Person].[BusinessEntityContact] bec 
    ON bec.[BusinessEntityID] = v.[BusinessEntityID]
	INNER JOIN [AW_Person].ContactType ct
	ON ct.[ContactTypeID] = bec.[ContactTypeID]
	INNER JOIN [AW_Person].[AW_Person] p
	ON p.[BusinessEntityID] = bec.[AW_PersonID]
	LEFT OUTER JOIN [AW_Person].[EmailAddress] ea
	ON ea.[BusinessEntityID] = p.[BusinessEntityID]
	LEFT OUTER JOIN [AW_Person].[AW_PersonPhone] pp
	ON pp.[BusinessEntityID] = p.[BusinessEntityID]
	LEFT OUTER JOIN [AW_Person].[PhoneNumberType] pnt
	ON pnt.[PhoneNumberTypeID] = pp.[PhoneNumberTypeID];
GO

CREATE VIEW [AW_Purchasing].[vVendorWithAddresses] AS 
SELECT 
    v.[BusinessEntityID]
    ,v.[Name]
    ,at.[Name] AS [AddressType]
    ,a.[AddressLine1] 
    ,a.[AddressLine2] 
    ,a.[City] 
    ,sp.[Name] AS [StateProvinceName] 
    ,a.[PostalCode] 
    ,cr.[Name] AS [CountryRegionName] 
FROM [AW_Purchasing].[Vendor] v
    INNER JOIN [AW_Person].[BusinessEntityAddress] bea 
    ON bea.[BusinessEntityID] = v.[BusinessEntityID] 
    INNER JOIN [AW_Person].[Address] a 
    ON a.[AddressID] = bea.[AddressID]
    INNER JOIN [AW_Person].[StateProvince] sp 
    ON sp.[StateProvinceID] = a.[StateProvinceID]
    INNER JOIN [AW_Person].[CountryRegion] cr 
    ON cr.[CountryRegionCode] = sp.[CountryRegionCode]
    INNER JOIN [AW_Person].[AddressType] at 
    ON at.[AddressTypeID] = bea.[AddressTypeID];
GO

-- ******************************************************
-- Add database functions.
-- ******************************************************
PRINT '';
PRINT '*** Creating Database Functions';
GO

CREATE FUNCTION [dbo].[ufnGetAccountingStartDate]()
RETURNS [datetime] 
AS 
BEGIN
    RETURN CONVERT(datetime, '20030701', 112);
END;
GO

CREATE FUNCTION [dbo].[ufnGetAccountingEndDate]()
RETURNS [datetime] 
AS 
BEGIN
    RETURN DATEADD(millisecond, -2, CONVERT(datetime, '20040701', 112));
END;
GO

CREATE FUNCTION [dbo].[ufnGetContactInformation](@AW_PersonID int)
RETURNS @retContactInformation TABLE 
(
    -- Columns returned by the function
    [AW_PersonID] int NOT NULL, 
    [FirstName] [nvarchar](50) NULL, 
    [LastName] [nvarchar](50) NULL, 
	[JobTitle] [nvarchar](50) NULL,
    [BusinessEntityType] [nvarchar](50) NULL
)
AS 
-- Returns the first name, last name, job title and business entity type for the specified contact.
-- Since a contact can serve multiple roles, more than one row may be returned.
BEGIN
	IF @AW_PersonID IS NOT NULL 
		BEGIN
		IF EXISTS(SELECT * FROM [AW_HumanResources].[Employee] e 
					WHERE e.[BusinessEntityID] = @AW_PersonID) 
			INSERT INTO @retContactInformation
				SELECT @AW_PersonID, p.FirstName, p.LastName, e.[JobTitle], 'Employee'
				FROM [AW_HumanResources].[Employee] AS e
					INNER JOIN [AW_Person].[AW_Person] p
					ON p.[BusinessEntityID] = e.[BusinessEntityID]
				WHERE e.[BusinessEntityID] = @AW_PersonID;

		IF EXISTS(SELECT * FROM [AW_Purchasing].[Vendor] AS v
					INNER JOIN [AW_Person].[BusinessEntityContact] bec 
					ON bec.[BusinessEntityID] = v.[BusinessEntityID]
					WHERE bec.[AW_PersonID] = @AW_PersonID)
			INSERT INTO @retContactInformation
				SELECT @AW_PersonID, p.FirstName, p.LastName, ct.[Name], 'Vendor Contact' 
				FROM [AW_Purchasing].[Vendor] AS v
					INNER JOIN [AW_Person].[BusinessEntityContact] bec 
					ON bec.[BusinessEntityID] = v.[BusinessEntityID]
					INNER JOIN [AW_Person].ContactType ct
					ON ct.[ContactTypeID] = bec.[ContactTypeID]
					INNER JOIN [AW_Person].[AW_Person] p
					ON p.[BusinessEntityID] = bec.[AW_PersonID]
				WHERE bec.[AW_PersonID] = @AW_PersonID;
		
		IF EXISTS(SELECT * FROM [AW_Sales].[Store] AS s
					INNER JOIN [AW_Person].[BusinessEntityContact] bec 
					ON bec.[BusinessEntityID] = s.[BusinessEntityID]
					WHERE bec.[AW_PersonID] = @AW_PersonID)
			INSERT INTO @retContactInformation
				SELECT @AW_PersonID, p.FirstName, p.LastName, ct.[Name], 'Store Contact' 
				FROM [AW_Sales].[Store] AS s
					INNER JOIN [AW_Person].[BusinessEntityContact] bec 
					ON bec.[BusinessEntityID] = s.[BusinessEntityID]
					INNER JOIN [AW_Person].ContactType ct
					ON ct.[ContactTypeID] = bec.[ContactTypeID]
					INNER JOIN [AW_Person].[AW_Person] p
					ON p.[BusinessEntityID] = bec.[AW_PersonID]
				WHERE bec.[AW_PersonID] = @AW_PersonID;

		IF EXISTS(SELECT * FROM [AW_Person].[AW_Person] AS p
					INNER JOIN [AW_Sales].[Customer] AS c
					ON c.[AW_PersonID] = p.[BusinessEntityID]
					WHERE p.[BusinessEntityID] = @AW_PersonID AND c.[StoreID] IS NULL) 
			INSERT INTO @retContactInformation
				SELECT @AW_PersonID, p.FirstName, p.LastName, NULL, 'Consumer' 
				FROM [AW_Person].[AW_Person] AS p
					INNER JOIN [AW_Sales].[Customer] AS c
					ON c.[AW_PersonID] = p.[BusinessEntityID]
					WHERE p.[BusinessEntityID] = @AW_PersonID AND c.[StoreID] IS NULL; 
		END

	RETURN;
END;
GO



CREATE FUNCTION [dbo].[ufnGetProductDealerPrice](@ProductID [int], @OrderDate [datetime])
RETURNS [money] 
AS 
-- Returns the dealer price for the product on a specific date.
BEGIN
    DECLARE @DealerPrice money;
    DECLARE @DealerDiscount money;

    SET @DealerDiscount = 0.60  -- 60% of list price

    SELECT @DealerPrice = plph.[ListPrice] * @DealerDiscount 
    FROM [AW_Production].[Product] p 
        INNER JOIN [AW_Production].[ProductListPriceHistory] plph 
        ON p.[ProductID] = plph.[ProductID] 
            AND p.[ProductID] = @ProductID 
            AND @OrderDate BETWEEN plph.[StartDate] AND COALESCE(plph.[EndDate], CONVERT(datetime, '99991231', 112)); -- Make sure we get all the prices!

    RETURN @DealerPrice;
END;
GO

CREATE FUNCTION [dbo].[ufnGetProductListPrice](@ProductID [int], @OrderDate [datetime])
RETURNS [money] 
AS 
BEGIN
    DECLARE @ListPrice money;

    SELECT @ListPrice = plph.[ListPrice] 
    FROM [AW_Production].[Product] p 
        INNER JOIN [AW_Production].[ProductListPriceHistory] plph 
        ON p.[ProductID] = plph.[ProductID] 
            AND p.[ProductID] = @ProductID 
            AND @OrderDate BETWEEN plph.[StartDate] AND COALESCE(plph.[EndDate], CONVERT(datetime, '99991231', 112)); -- Make sure we get all the prices!

    RETURN @ListPrice;
END;
GO

CREATE FUNCTION [dbo].[ufnGetProductStandardCost](@ProductID [int], @OrderDate [datetime])
RETURNS [money] 
AS 
-- Returns the standard cost for the product on a specific date.
BEGIN
    DECLARE @StandardCost money;

    SELECT @StandardCost = pch.[StandardCost] 
    FROM [AW_Production].[Product] p 
        INNER JOIN [AW_Production].[ProductCostHistory] pch 
        ON p.[ProductID] = pch.[ProductID] 
            AND p.[ProductID] = @ProductID 
            AND @OrderDate BETWEEN pch.[StartDate] AND COALESCE(pch.[EndDate], CONVERT(datetime, '99991231', 112)); -- Make sure we get all the prices!

    RETURN @StandardCost;
END;
GO

CREATE FUNCTION [dbo].[ufnGetStock](@ProductID [int])
RETURNS [int] 
AS 
-- Returns the stock level for the product. This function is used internally only
BEGIN
    DECLARE @ret int;
    
    SELECT @ret = SUM(p.[Quantity]) 
    FROM [AW_Production].[ProductInventory] p 
    WHERE p.[ProductID] = @ProductID 
        AND p.[LocationID] = '6'; -- Only look at inventory in the misc storage
    
    IF (@ret IS NULL) 
        SET @ret = 0
    
    RETURN @ret
END;
GO

CREATE FUNCTION [dbo].[ufnGetDocumentStatusText](@Status [tinyint])
RETURNS [nvarchar](16) 
AS 
-- Returns the sales order status text representation for the status value.
BEGIN
    DECLARE @ret [nvarchar](16);

    SET @ret = 
        CASE @Status
            WHEN 1 THEN N'Pending approval'
            WHEN 2 THEN N'Approved'
            WHEN 3 THEN N'Obsolete'
            ELSE N'** Invalid **'
        END;
    
    RETURN @ret
END;
GO

CREATE FUNCTION [dbo].[ufnGetPurchaseOrderStatusText](@Status [tinyint])
RETURNS [nvarchar](15) 
AS 
-- Returns the sales order status text representation for the status value.
BEGIN
    DECLARE @ret [nvarchar](15);

    SET @ret = 
        CASE @Status
            WHEN 1 THEN 'Pending'
            WHEN 2 THEN 'Approved'
            WHEN 3 THEN 'Rejected'
            WHEN 4 THEN 'Complete'
            ELSE '** Invalid **'
        END;
    
    RETURN @ret
END;
GO

CREATE FUNCTION [dbo].[ufnGetSalesOrderStatusText](@Status [tinyint])
RETURNS [nvarchar](15) 
AS 
-- Returns the sales order status text representation for the status value.
BEGIN
    DECLARE @ret [nvarchar](15);

    SET @ret = 
        CASE @Status
            WHEN 1 THEN 'In process'
            WHEN 2 THEN 'Approved'
            WHEN 3 THEN 'Backordered'
            WHEN 4 THEN 'Rejected'
            WHEN 5 THEN 'Shipped'
            WHEN 6 THEN 'Cancelled'
            ELSE '** Invalid **'
        END;
    
    RETURN @ret
END;
GO


-- ******************************************************
-- Create stored procedures
-- ******************************************************
PRINT '';
PRINT '*** Creating Stored Procedures';
GO

CREATE PROCEDURE [dbo].[uspGetBillOfMaterials]
    @StartProductID [int],
    @CheckDate [datetime]
AS
BEGIN
    SET NOCOUNT ON;

    -- Use recursive query to generate a multi-level Bill of Material (i.e. all level 1 
    -- components of a level 0 assembly, all level 2 components of a level 1 assembly)
    -- The CheckDate eliminates any components that are no longer used in the product on this date.
    WITH [BOM_cte]([ProductAssemblyID], [ComponentID], [ComponentDesc], [PerAssemblyQty], [StandardCost], [ListPrice], [BOMLevel], [RecursionLevel]) -- CTE name and columns
    AS (
        SELECT b.[ProductAssemblyID], b.[ComponentID], p.[Name], b.[PerAssemblyQty], p.[StandardCost], p.[ListPrice], b.[BOMLevel], 0 -- Get the initial list of components for the bike assembly
        FROM [AW_Production].[BillOfMaterials] b
            INNER JOIN [AW_Production].[Product] p 
            ON b.[ComponentID] = p.[ProductID] 
        WHERE b.[ProductAssemblyID] = @StartProductID 
            AND @CheckDate >= b.[StartDate] 
            AND @CheckDate <= ISNULL(b.[EndDate], @CheckDate)
        UNION ALL
        SELECT b.[ProductAssemblyID], b.[ComponentID], p.[Name], b.[PerAssemblyQty], p.[StandardCost], p.[ListPrice], b.[BOMLevel], [RecursionLevel] + 1 -- Join recursive member to anchor
        FROM [BOM_cte] cte
            INNER JOIN [AW_Production].[BillOfMaterials] b 
            ON b.[ProductAssemblyID] = cte.[ComponentID]
            INNER JOIN [AW_Production].[Product] p 
            ON b.[ComponentID] = p.[ProductID] 
        WHERE @CheckDate >= b.[StartDate] 
            AND @CheckDate <= ISNULL(b.[EndDate], @CheckDate)
        )
    -- Outer select from the CTE
    SELECT b.[ProductAssemblyID], b.[ComponentID], b.[ComponentDesc], SUM(b.[PerAssemblyQty]) AS [TotalQuantity] , b.[StandardCost], b.[ListPrice], b.[BOMLevel], b.[RecursionLevel]
    FROM [BOM_cte] b
    GROUP BY b.[ComponentID], b.[ComponentDesc], b.[ProductAssemblyID], b.[BOMLevel], b.[RecursionLevel], b.[StandardCost], b.[ListPrice]
    ORDER BY b.[BOMLevel], b.[ProductAssemblyID], b.[ComponentID]
    OPTION (MAXRECURSION 25) 
END;
GO

CREATE PROCEDURE [dbo].[uspGetEmployeeManagers]
    @BusinessEntityID [int]
AS
BEGIN
    SET NOCOUNT ON;

    -- Use recursive query to list out all Employees required for a particular Manager
    WITH [EMP_cte]([BusinessEntityID], [OrganizationNode], [FirstName], [LastName], [JobTitle], [RecursionLevel]) -- CTE name and columns
    AS (
        SELECT e.[BusinessEntityID], e.[OrganizationNode], p.[FirstName], p.[LastName], e.[JobTitle], 0 -- Get the initial Employee
        FROM [AW_HumanResources].[Employee] e 
			INNER JOIN [AW_Person].[AW_Person] as p
			ON p.[BusinessEntityID] = e.[BusinessEntityID]
        WHERE e.[BusinessEntityID] = @BusinessEntityID
        UNION ALL
        SELECT e.[BusinessEntityID], e.[OrganizationNode], p.[FirstName], p.[LastName], e.[JobTitle], [RecursionLevel] + 1 -- Join recursive member to anchor
        FROM [AW_HumanResources].[Employee] e 
            INNER JOIN [EMP_cte]
            ON e.[OrganizationNode] = [EMP_cte].[OrganizationNode].GetAncestor(1)
            INNER JOIN [AW_Person].[AW_Person] p 
            ON p.[BusinessEntityID] = e.[BusinessEntityID]
    )
    -- Join back to Employee to return the manager name 
    SELECT [EMP_cte].[RecursionLevel], [EMP_cte].[BusinessEntityID], [EMP_cte].[FirstName], [EMP_cte].[LastName], 
        [EMP_cte].[OrganizationNode].ToString() AS [OrganizationNode], p.[FirstName] AS 'ManagerFirstName', p.[LastName] AS 'ManagerLastName'  -- Outer select from the CTE
    FROM [EMP_cte] 
        INNER JOIN [AW_HumanResources].[Employee] e 
        ON [EMP_cte].[OrganizationNode].GetAncestor(1) = e.[OrganizationNode]
        INNER JOIN [AW_Person].[AW_Person] p 
        ON p.[BusinessEntityID] = e.[BusinessEntityID]
    ORDER BY [RecursionLevel], [EMP_cte].[OrganizationNode].ToString()
    OPTION (MAXRECURSION 25) 
END;
GO

CREATE PROCEDURE [dbo].[uspGetManagerEmployees]
    @BusinessEntityID [int]
AS
BEGIN
    SET NOCOUNT ON;

    -- Use recursive query to list out all Employees required for a particular Manager
    WITH [EMP_cte]([BusinessEntityID], [OrganizationNode], [FirstName], [LastName], [RecursionLevel]) -- CTE name and columns
    AS (
        SELECT e.[BusinessEntityID], e.[OrganizationNode], p.[FirstName], p.[LastName], 0 -- Get the initial list of Employees for Manager n
        FROM [AW_HumanResources].[Employee] e 
			INNER JOIN [AW_Person].[AW_Person] p 
			ON p.[BusinessEntityID] = e.[BusinessEntityID]
        WHERE e.[BusinessEntityID] = @BusinessEntityID
        UNION ALL
        SELECT e.[BusinessEntityID], e.[OrganizationNode], p.[FirstName], p.[LastName], [RecursionLevel] + 1 -- Join recursive member to anchor
        FROM [AW_HumanResources].[Employee] e 
            INNER JOIN [EMP_cte]
            ON e.[OrganizationNode].GetAncestor(1) = [EMP_cte].[OrganizationNode]
			INNER JOIN [AW_Person].[AW_Person] p 
			ON p.[BusinessEntityID] = e.[BusinessEntityID]
        )
    -- Join back to Employee to return the manager name 
    SELECT [EMP_cte].[RecursionLevel], [EMP_cte].[OrganizationNode].ToString() as [OrganizationNode], p.[FirstName] AS 'ManagerFirstName', p.[LastName] AS 'ManagerLastName',
        [EMP_cte].[BusinessEntityID], [EMP_cte].[FirstName], [EMP_cte].[LastName] -- Outer select from the CTE
    FROM [EMP_cte] 
        INNER JOIN [AW_HumanResources].[Employee] e 
        ON [EMP_cte].[OrganizationNode].GetAncestor(1) = e.[OrganizationNode]
			INNER JOIN [AW_Person].[AW_Person] p 
			ON p.[BusinessEntityID] = e.[BusinessEntityID]
    ORDER BY [RecursionLevel], [EMP_cte].[OrganizationNode].ToString()
    OPTION (MAXRECURSION 25) 
END;
GO

CREATE PROCEDURE [dbo].[uspGetWhereUsedProductID]
    @StartProductID [int],
    @CheckDate [datetime]
AS
BEGIN
    SET NOCOUNT ON;

    --Use recursive query to generate a multi-level Bill of Material (i.e. all level 1 components of a level 0 assembly, all level 2 components of a level 1 assembly)
    WITH [BOM_cte]([ProductAssemblyID], [ComponentID], [ComponentDesc], [PerAssemblyQty], [StandardCost], [ListPrice], [BOMLevel], [RecursionLevel]) -- CTE name and columns
    AS (
        SELECT b.[ProductAssemblyID], b.[ComponentID], p.[Name], b.[PerAssemblyQty], p.[StandardCost], p.[ListPrice], b.[BOMLevel], 0 -- Get the initial list of components for the bike assembly
        FROM [AW_Production].[BillOfMaterials] b
            INNER JOIN [AW_Production].[Product] p 
            ON b.[ProductAssemblyID] = p.[ProductID] 
        WHERE b.[ComponentID] = @StartProductID 
            AND @CheckDate >= b.[StartDate] 
            AND @CheckDate <= ISNULL(b.[EndDate], @CheckDate)
        UNION ALL
        SELECT b.[ProductAssemblyID], b.[ComponentID], p.[Name], b.[PerAssemblyQty], p.[StandardCost], p.[ListPrice], b.[BOMLevel], [RecursionLevel] + 1 -- Join recursive member to anchor
        FROM [BOM_cte] cte
            INNER JOIN [AW_Production].[BillOfMaterials] b 
            ON cte.[ProductAssemblyID] = b.[ComponentID]
            INNER JOIN [AW_Production].[Product] p 
            ON b.[ProductAssemblyID] = p.[ProductID] 
        WHERE @CheckDate >= b.[StartDate] 
            AND @CheckDate <= ISNULL(b.[EndDate], @CheckDate)
        )
    -- Outer select from the CTE
    SELECT b.[ProductAssemblyID], b.[ComponentID], b.[ComponentDesc], SUM(b.[PerAssemblyQty]) AS [TotalQuantity] , b.[StandardCost], b.[ListPrice], b.[BOMLevel], b.[RecursionLevel]
    FROM [BOM_cte] b
    GROUP BY b.[ComponentID], b.[ComponentDesc], b.[ProductAssemblyID], b.[BOMLevel], b.[RecursionLevel], b.[StandardCost], b.[ListPrice]
    ORDER BY b.[BOMLevel], b.[ProductAssemblyID], b.[ComponentID]
    OPTION (MAXRECURSION 25) 
END;
GO

CREATE PROCEDURE [AW_HumanResources].[uspUpdateEmployeeHireInfo]
    @BusinessEntityID [int], 
    @JobTitle [nvarchar](50), 
    @HireDate [datetime], 
    @RateChangeDate [datetime], 
    @Rate [money], 
    @PayFrequency [tinyint], 
    @CurrentFlag [dbo].[Flag] 
WITH EXECUTE AS CALLER
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [AW_HumanResources].[Employee] 
        SET [JobTitle] = @JobTitle 
            ,[HireDate] = @HireDate 
            ,[CurrentFlag] = @CurrentFlag 
        WHERE [BusinessEntityID] = @BusinessEntityID;

        INSERT INTO [AW_HumanResources].[EmployeePayHistory] 
            ([BusinessEntityID]
            ,[RateChangeDate]
            ,[Rate]
            ,[PayFrequency]) 
        VALUES (@BusinessEntityID, @RateChangeDate, @Rate, @PayFrequency);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback any active or uncommittable transactions before
        -- inserting information in the ErrorLog
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO

CREATE PROCEDURE [AW_HumanResources].[uspUpdateEmployeeLogin]
    @BusinessEntityID [int], 
    @OrganizationNode [hierarchyid],
    @LoginID [nvarchar](256),
    @JobTitle [nvarchar](50),
    @HireDate [datetime],
    @CurrentFlag [dbo].[Flag]
WITH EXECUTE AS CALLER
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE [AW_HumanResources].[Employee] 
        SET [OrganizationNode] = @OrganizationNode 
            ,[LoginID] = @LoginID 
            ,[JobTitle] = @JobTitle 
            ,[HireDate] = @HireDate 
            ,[CurrentFlag] = @CurrentFlag 
        WHERE [BusinessEntityID] = @BusinessEntityID;
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO

CREATE PROCEDURE [AW_HumanResources].[uspUpdateEmployeeAW_PersonalInfo]
    @BusinessEntityID [int], 
    @NationalIDNumber [nvarchar](15), 
    @BirthDate [datetime], 
    @MaritalStatus [nchar](1), 
    @Gender [nchar](1)
WITH EXECUTE AS CALLER
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE [AW_HumanResources].[Employee] 
        SET [NationalIDNumber] = @NationalIDNumber 
            ,[BirthDate] = @BirthDate 
            ,[MaritalStatus] = @MaritalStatus 
            ,[Gender] = @Gender 
        WHERE [BusinessEntityID] = @BusinessEntityID;
    END TRY
    BEGIN CATCH
        EXECUTE [dbo].[uspLogError];
    END CATCH;
END;
GO

--A stored procedure which demonstrates integrated full text search

CREATE PROCEDURE [dbo].[uspSearchCandidateResumes]
    @searchString [nvarchar](1000),   
    @useInflectional [bit]=0,
    @useThesaurus [bit]=0,
    @language[int]=0


WITH EXECUTE AS CALLER
AS
BEGIN
    SET NOCOUNT ON;

      DECLARE @string nvarchar(1050)
      --setting the lcid to the default instance LCID if needed
      IF @language = NULL OR @language = 0 
      BEGIN 
            SELECT @language =CONVERT(int, serverproperty('lcid'))  
      END
      

            --FREETEXTTABLE case as inflectional and Thesaurus were required
      IF @useThesaurus = 1 AND @useInflectional = 1  
        BEGIN
                  SELECT FT_TBL.[JobCandidateID], KEY_TBL.[RANK] FROM [AW_HumanResources].[JobCandidate] AS FT_TBL 
                        INNER JOIN FREETEXTTABLE([AW_HumanResources].[JobCandidate],*, @searchString,LANGUAGE @language) AS KEY_TBL
                   ON  FT_TBL.[JobCandidateID] =KEY_TBL.[KEY]
            END

      ELSE IF @useThesaurus = 1
            BEGIN
                  SELECT @string ='FORMSOF(THESAURUS,"'+@searchString +'"'+')'      
                  SELECT FT_TBL.[JobCandidateID], KEY_TBL.[RANK] FROM [AW_HumanResources].[JobCandidate] AS FT_TBL 
                        INNER JOIN CONTAINSTABLE([AW_HumanResources].[JobCandidate],*, @string,LANGUAGE @language) AS KEY_TBL
                   ON  FT_TBL.[JobCandidateID] =KEY_TBL.[KEY]
        END

      ELSE IF @useInflectional = 1
            BEGIN
                  SELECT @string ='FORMSOF(INFLECTIONAL,"'+@searchString +'"'+')'
                  SELECT FT_TBL.[JobCandidateID], KEY_TBL.[RANK] FROM [AW_HumanResources].[JobCandidate] AS FT_TBL 
                        INNER JOIN CONTAINSTABLE([AW_HumanResources].[JobCandidate],*, @string,LANGUAGE @language) AS KEY_TBL
                   ON  FT_TBL.[JobCandidateID] =KEY_TBL.[KEY]
        END
  
      ELSE --base case, plain CONTAINSTABLE
            BEGIN
                  SELECT @string='"'+@searchString +'"'
                  SELECT FT_TBL.[JobCandidateID],KEY_TBL.[RANK] FROM [AW_HumanResources].[JobCandidate] AS FT_TBL 
                        INNER JOIN CONTAINSTABLE([AW_HumanResources].[JobCandidate],*,@string,LANGUAGE @language) AS KEY_TBL
                   ON  FT_TBL.[JobCandidateID] =KEY_TBL.[KEY]
            END

END;
GO

-- ******************************************************
-- Add Extended Properties
-- ******************************************************
PRINT '';
PRINT '*** Creating Extended Properties';
GO

SET NOCOUNT ON;
GO

PRINT '    Database';
GO

-- Database
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'AdventureWorks 2016 Sample OLTP Database', NULL, NULL, NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Database trigger to audit all of the DDL changes made to the AdventureWorks 2016 database.', N'TRIGGER', [ddlDatabaseTriggerLog], NULL, NULL, NULL, NULL;
GO

PRINT '    Files and Filegroups';
GO

-- Files and Filegroups
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary filegroup for the AdventureWorks 2016 sample database.', N'FILEGROUP', [PRIMARY];
GO

PRINT '    Schemas';
GO

-- Schemas
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Contains objects related to employees and departments.', N'SCHEMA', [AW_HumanResources], NULL, NULL, NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Contains objects related to products, inventory, and manufacturing.', N'SCHEMA', [AW_Production], NULL, NULL, NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Contains objects related to vendors and purchase orders.', N'SCHEMA', [AW_Purchasing], NULL, NULL, NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Contains objects related to customers, sales orders, and sales territories.', N'SCHEMA', [AW_Sales], NULL, NULL, NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Contains objects related to names and addresses of customers, vendors, and employees', N'SCHEMA', [AW_Person], NULL, NULL, NULL, NULL;
GO

PRINT '    Tables and Columns';
GO

-- Tables and Columns
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Street address information for customers, employees, and vendors.', N'SCHEMA', [AW_Person], N'TABLE', [Address], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for Address records.', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'COLUMN', [AddressID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'First street address line.', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'COLUMN', [AddressLine1];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Second street address line.', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'COLUMN', [AddressLine2];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Name of the city.', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'COLUMN', [City];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique identification number for the state or province. Foreign key to StateProvince table.', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'COLUMN', [StateProvinceID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Postal code for the street address.', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'COLUMN', [PostalCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Latitude and longitude of this address.', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'COLUMN', [SpatialLocation];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Types of addresses stored in the Address table. ', N'SCHEMA', [AW_Person], N'TABLE', [AddressType], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for AddressType records.', N'SCHEMA', [AW_Person], N'TABLE', [AddressType], N'COLUMN', [AddressTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Address type description. For example, Billing, Home, or Shipping.', N'SCHEMA', [AW_Person], N'TABLE', [AddressType], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Person], N'TABLE', [AddressType], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Person], N'TABLE', [AddressType], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Current version number of the AdventureWorks 2016 sample database. ', N'SCHEMA', [dbo], N'TABLE', [AWBuildVersion], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for AWBuildVersion records.', N'SCHEMA', [dbo], N'TABLE', [AWBuildVersion], N'COLUMN', [SystemInformationID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Version number of the database in 9.yy.mm.dd.00 format.', N'SCHEMA', [dbo], N'TABLE', [AWBuildVersion], N'COLUMN', [Database Version];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [dbo], N'TABLE', [AWBuildVersion], N'COLUMN', [VersionDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [dbo], N'TABLE', [AWBuildVersion], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Items required to make bicycles and bicycle subassemblies. It identifies the heirarchical relationship between a parent product and its components.', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for BillOfMaterials records.', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'COLUMN', [BillOfMaterialsID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Parent product identification number. Foreign key to Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'COLUMN', [ProductAssemblyID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Component identification number. Foreign key to Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'COLUMN', [ComponentID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date the component started being used in the assembly item.', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'COLUMN', [StartDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date the component stopped being used in the assembly item.', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'COLUMN', [EndDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Standard code identifying the unit of measure for the quantity.', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'COLUMN', [UnitMeasureCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Indicates the depth the component is from its parent (AssemblyID).', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'COLUMN', [BOMLevel];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Quantity of the component needed to create the assembly.', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'COLUMN', [PerAssemblyQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Source of the ID that connects vendors, customers, and employees with address and contact information.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntity], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for all customers, vendors, and employees.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntity], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntity], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntity], N'COLUMN', [ModifiedDate];

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Cross-reference table mapping customers, vendors, and employees to their addresses.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityAddress], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to BusinessEntity.BusinessEntityID.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityAddress], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to Address.AddressID.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityAddress], N'COLUMN', [AddressID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to AddressType.AddressTypeID.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityAddress], N'COLUMN', [AddressTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityAddress], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityAddress], N'COLUMN', [ModifiedDate];

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Cross-reference table mapping stores, vendors, and employees to people', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityContact], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to BusinessEntity.BusinessEntityID.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityContact], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to AW_Person.BusinessEntityID.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityContact], N'COLUMN', [AW_PersonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key.  Foreign key to ContactType.ContactTypeID.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityContact], N'COLUMN', [ContactTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityContact], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityContact], N'COLUMN', [ModifiedDate];


EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Lookup table containing the types of business entity contacts.', N'SCHEMA', [AW_Person], N'TABLE', [ContactType], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for ContactType records.', N'SCHEMA', [AW_Person], N'TABLE', [ContactType], N'COLUMN', [ContactTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Contact type description.', N'SCHEMA', [AW_Person], N'TABLE', [ContactType], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Person], N'TABLE', [ContactType], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Cross-reference table mapping ISO currency codes to a country or region.', N'SCHEMA', [AW_Sales], N'TABLE', [CountryRegionCurrency], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ISO code for countries and regions. Foreign key to CountryRegion.CountryRegionCode.', N'SCHEMA', [AW_Sales], N'TABLE', [CountryRegionCurrency], N'COLUMN', [CountryRegionCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ISO standard currency code. Foreign key to Currency.CurrencyCode.', N'SCHEMA', [AW_Sales], N'TABLE', [CountryRegionCurrency], N'COLUMN', [CurrencyCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [CountryRegionCurrency], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Lookup table containing the ISO standard codes for countries and regions.', N'SCHEMA', [AW_Person], N'TABLE', [CountryRegion], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ISO standard code for countries and regions.', N'SCHEMA', [AW_Person], N'TABLE', [CountryRegion], N'COLUMN', [CountryRegionCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Country or region name.', N'SCHEMA', [AW_Person], N'TABLE', [CountryRegion], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Person], N'TABLE', [CountryRegion], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Customer credit card information.', N'SCHEMA', [AW_Sales], N'TABLE', [CreditCard], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for CreditCard records.', N'SCHEMA', [AW_Sales], N'TABLE', [CreditCard], N'COLUMN', [CreditCardID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Credit card name.', N'SCHEMA', [AW_Sales], N'TABLE', [CreditCard], N'COLUMN', [CardType];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Credit card number.', N'SCHEMA', [AW_Sales], N'TABLE', [CreditCard], N'COLUMN', [CardNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Credit card expiration month.', N'SCHEMA', [AW_Sales], N'TABLE', [CreditCard], N'COLUMN', [ExpMonth];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Credit card expiration year.', N'SCHEMA', [AW_Sales], N'TABLE', [CreditCard], N'COLUMN', [ExpYear];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [CreditCard], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Lookup table containing the languages in which some AdventureWorks data is stored.', N'SCHEMA', [AW_Production], N'TABLE', [Culture], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for Culture records.', N'SCHEMA', [AW_Production], N'TABLE', [Culture], N'COLUMN', [CultureID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Culture description.', N'SCHEMA', [AW_Production], N'TABLE', [Culture], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [Culture], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Lookup table containing standard ISO currencies.', N'SCHEMA', [AW_Sales], N'TABLE', [Currency], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The ISO code for the Currency.', N'SCHEMA', [AW_Sales], N'TABLE', [Currency], N'COLUMN', [CurrencyCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Currency name.', N'SCHEMA', [AW_Sales], N'TABLE', [Currency], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [Currency], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Currency exchange rates.', N'SCHEMA', [AW_Sales], N'TABLE', [CurrencyRate], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for CurrencyRate records.', N'SCHEMA', [AW_Sales], N'TABLE', [CurrencyRate], N'COLUMN', [CurrencyRateID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the exchange rate was obtained.', N'SCHEMA', [AW_Sales], N'TABLE', [CurrencyRate], N'COLUMN', [CurrencyRateDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Exchange rate was converted from this currency code.', N'SCHEMA', [AW_Sales], N'TABLE', [CurrencyRate], N'COLUMN', [FromCurrencyCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Exchange rate was converted to this currency code.', N'SCHEMA', [AW_Sales], N'TABLE', [CurrencyRate], N'COLUMN', [ToCurrencyCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Average exchange rate for the day.', N'SCHEMA', [AW_Sales], N'TABLE', [CurrencyRate], N'COLUMN', [AverageRate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Final exchange rate for the day.', N'SCHEMA', [AW_Sales], N'TABLE', [CurrencyRate], N'COLUMN', [EndOfDayRate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [CurrencyRate], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Current customer information. Also see the AW_Person and Store tables.', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key.', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'COLUMN', [CustomerID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key to AW_Person.BusinessEntityID', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'COLUMN', [AW_PersonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key to Store.BusinessEntityID', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'COLUMN', [StoreID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ID of the territory in which the customer is located. Foreign key to SalesTerritory.SalesTerritoryID.', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'COLUMN', [TerritoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique number identifying the customer assigned by the accounting system.', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'COLUMN', [AccountNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Audit table tracking all DDL changes made to the AdventureWorks database. Data is captured by the database trigger ddlDatabaseTriggerLog.', N'SCHEMA', [dbo], N'TABLE', [DatabaseLog], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for DatabaseLog records.', N'SCHEMA', [dbo], N'TABLE', [DatabaseLog], N'COLUMN', [DatabaseLogID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The date and time the DDL change occurred.', N'SCHEMA', [dbo], N'TABLE', [DatabaseLog], N'COLUMN', [PostTime];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The user who implemented the DDL change.', N'SCHEMA', [dbo], N'TABLE', [DatabaseLog], N'COLUMN', [DatabaseUser];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The type of DDL statement that was executed.', N'SCHEMA', [dbo], N'TABLE', [DatabaseLog], N'COLUMN', [Event];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The schema to which the changed object belongs.', N'SCHEMA', [dbo], N'TABLE', [DatabaseLog], N'COLUMN', [Schema];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The object that was changed by the DDL statment.', N'SCHEMA', [dbo], N'TABLE', [DatabaseLog], N'COLUMN', [Object];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The exact Transact-SQL statement that was executed.', N'SCHEMA', [dbo], N'TABLE', [DatabaseLog], N'COLUMN', [TSQL];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The raw XML data generated by database trigger.', N'SCHEMA', [dbo], N'TABLE', [DatabaseLog], N'COLUMN', [XmlEvent];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Lookup table containing the departments within the Adventure Works Cycles company.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Department], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for Department records.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Department], N'COLUMN', [DepartmentID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Name of the department.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Department], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Name of the group to which the department belongs.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Department], N'COLUMN', [GroupName];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Department], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product maintenance documents.', N'SCHEMA', [AW_Production], N'TABLE', [Document], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for Document records.', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'COLUMN', [DocumentNode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Depth in the document hierarchy.', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'COLUMN', [DocumentLevel];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Title of the document.', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'COLUMN', [Title];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Employee who controls the document.  Foreign key to Employee.BusinessEntityID', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'COLUMN', [Owner];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'0 = This is a folder, 1 = This is a document.', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'COLUMN', [FolderFlag];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'File name of the document', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'COLUMN', [FileName];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'File extension indicating the document type. For example, .doc or .txt.', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'COLUMN', [FileExtension];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Revision number of the document. ', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'COLUMN', [Revision];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Engineering change approval number.', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'COLUMN', [ChangeNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'1 = Pending approval, 2 = Approved, 3 = Obsolete', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'COLUMN', [Status];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Document abstract.', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'COLUMN', [DocumentSummary];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Complete document.', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'COLUMN', [Document];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Required for FileStream.', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Where to send a AW_Person email.', N'SCHEMA', [AW_Person], N'TABLE', [EmailAddress], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. AW_Person associated with this email address.  Foreign key to AW_Person.BusinessEntityID', N'SCHEMA', [AW_Person], N'TABLE', [EmailAddress], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. ID of this email address.', N'SCHEMA', [AW_Person], N'TABLE', [EmailAddress], N'COLUMN', [EmailAddressID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'E-mail address for the AW_Person.', N'SCHEMA', [AW_Person], N'TABLE', [EmailAddress], N'COLUMN', [EmailAddress];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Person], N'TABLE', [EmailAddress], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Person], N'TABLE', [EmailAddress], N'COLUMN', [ModifiedDate];


EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Employee information such as salary, department, and title.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for Employee records.  Foreign key to BusinessEntity.BusinessEntityID.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique national identification number such as a social security number.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'COLUMN', [NationalIDNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Network login.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'COLUMN', [LoginID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Where the employee is located in corporate hierarchy.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'COLUMN', [OrganizationNode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The depth of the employee in the corporate hierarchy.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'COLUMN', [OrganizationLevel];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Work title such as Buyer or Sales Representative.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'COLUMN', [JobTitle];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date of birth.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'COLUMN', [BirthDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'M = Married, S = Single', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'COLUMN', [MaritalStatus];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'M = Male, F = Female', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'COLUMN', [Gender];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Employee hired on this date.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'COLUMN', [HireDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Job classification. 0 = Hourly, not exempt from collective bargaining. 1 = Salaried, exempt from collective bargaining.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'COLUMN', [SalariedFlag];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Number of available vacation hours.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'COLUMN', [VacationHours];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Number of available sick leave hours.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'COLUMN', [SickLeaveHours];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'0 = Inactive, 1 = Active', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'COLUMN', [CurrentFlag];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Employee department transfers.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeeDepartmentHistory], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Employee identification number. Foreign key to Employee.BusinessEntityID.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeeDepartmentHistory], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Department in which the employee worked including currently. Foreign key to Department.DepartmentID.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeeDepartmentHistory], N'COLUMN', [DepartmentID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Identifies which 8-hour shift the employee works. Foreign key to Shift.Shift.ID.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeeDepartmentHistory], N'COLUMN', [ShiftID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date the employee started work in the department.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeeDepartmentHistory], N'COLUMN', [StartDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date the employee left the department. NULL = Current department.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeeDepartmentHistory], N'COLUMN', [EndDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeeDepartmentHistory], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Employee pay history.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeePayHistory], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Employee identification number. Foreign key to Employee.BusinessEntityID.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeePayHistory], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date the change in pay is effective', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeePayHistory], N'COLUMN', [RateChangeDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Salary hourly rate.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeePayHistory], N'COLUMN', [Rate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'1 = Salary received monthly, 2 = Salary received biweekly', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeePayHistory], N'COLUMN', [PayFrequency];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeePayHistory], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Audit table tracking errors in the the AdventureWorks database that are caught by the CATCH block of a TRY...CATCH construct. Data is inserted by stored procedure dbo.uspLogError when it is executed from inside the CATCH block of a TRY...CATCH construct.', N'SCHEMA', [dbo], N'TABLE', [ErrorLog], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for ErrorLog records.', N'SCHEMA', [dbo], N'TABLE', [ErrorLog], N'COLUMN', [ErrorLogID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The date and time at which the error occurred.', N'SCHEMA', [dbo], N'TABLE', [ErrorLog], N'COLUMN', [ErrorTime];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The user who executed the batch in which the error occurred.', N'SCHEMA', [dbo], N'TABLE', [ErrorLog], N'COLUMN', [UserName];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The error number of the error that occurred.', N'SCHEMA', [dbo], N'TABLE', [ErrorLog], N'COLUMN', [ErrorNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The severity of the error that occurred.', N'SCHEMA', [dbo], N'TABLE', [ErrorLog], N'COLUMN', [ErrorSeverity];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The state number of the error that occurred.', N'SCHEMA', [dbo], N'TABLE', [ErrorLog], N'COLUMN', [ErrorState];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The name of the stored procedure or trigger where the error occurred.', N'SCHEMA', [dbo], N'TABLE', [ErrorLog], N'COLUMN', [ErrorProcedure];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The line number at which the error occurred.', N'SCHEMA', [dbo], N'TABLE', [ErrorLog], N'COLUMN', [ErrorLine];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The message text of the error that occurred.', N'SCHEMA', [dbo], N'TABLE', [ErrorLog], N'COLUMN', [ErrorMessage];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Bicycle assembly diagrams.', N'SCHEMA', [AW_Production], N'TABLE', [Illustration], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for Illustration records.', N'SCHEMA', [AW_Production], N'TABLE', [Illustration], N'COLUMN', [IllustrationID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Illustrations used in manufacturing instructions. Stored as XML.', N'SCHEMA', [AW_Production], N'TABLE', [Illustration], N'COLUMN', [Diagram];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [Illustration], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Résumés submitted to Human Resources by job applicants.', N'SCHEMA', [AW_HumanResources], N'TABLE', [JobCandidate], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for JobCandidate records.', N'SCHEMA', [AW_HumanResources], N'TABLE', [JobCandidate], N'COLUMN', [JobCandidateID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Employee identification number if applicant was hired. Foreign key to Employee.BusinessEntityID.', N'SCHEMA', [AW_HumanResources], N'TABLE', [JobCandidate], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Résumé in XML format.', N'SCHEMA', [AW_HumanResources], N'TABLE', [JobCandidate], N'COLUMN', [Resume];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_HumanResources], N'TABLE', [JobCandidate], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product inventory and manufacturing locations.', N'SCHEMA', [AW_Production], N'TABLE', [Location], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for Location records.', N'SCHEMA', [AW_Production], N'TABLE', [Location], N'COLUMN', [LocationID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Location description.', N'SCHEMA', [AW_Production], N'TABLE', [Location], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Standard hourly cost of the manufacturing location.', N'SCHEMA', [AW_Production], N'TABLE', [Location], N'COLUMN', [CostRate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Work capacity (in hours) of the manufacturing location.', N'SCHEMA', [AW_Production], N'TABLE', [Location], N'COLUMN', [Availability];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [Location], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'One way hashed authentication information', N'SCHEMA', [AW_Person], N'TABLE', [Password], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Password for the e-mail account.', N'SCHEMA', [AW_Person], N'TABLE', [Password], N'COLUMN', [PasswordHash];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Random value concatenated with the password string before the password is hashed.', N'SCHEMA', [AW_Person], N'TABLE', [Password], N'COLUMN', [PasswordSalt];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Person], N'TABLE', [Password], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Person], N'TABLE', [Password], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Human beings involved with AdventureWorks: employees, customer contacts, and vendor contacts.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for AW_Person records.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary type of AW_Person: SC = Store Contact, IN = Individual (retail) customer, SP = Sales AW_Person, EM = Employee (non-sales), VC = Vendor contact, GC = General contact', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'COLUMN', [AW_PersonType];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'0 = The data in FirstName and LastName are stored in western style (first name, last name) order.  1 = Eastern style (last name, first name) order.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'COLUMN', [NameStyle];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'A courtesy title. For example, Mr. or Ms.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'COLUMN', [Title];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'First name of the AW_Person.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'COLUMN', [FirstName];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Middle name or middle initial of the AW_Person.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'COLUMN', [MiddleName];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Last name of the AW_Person.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'COLUMN', [LastName];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Surname suffix. For example, Sr. or Jr.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'COLUMN', [Suffix];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'0 = Contact does not wish to receive e-mail promotions, 1 = Contact does wish to receive e-mail promotions from AdventureWorks, 2 = Contact does wish to receive e-mail promotions from AdventureWorks and selected partners. ', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'COLUMN', [EmailPromotion];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'AW_Personal information such as hobbies, and income collected from online shoppers. Used for sales analysis.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'COLUMN', [Demographics];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Additional contact information about the AW_Person stored in xml format. ', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'COLUMN', [AdditionalContactInfo];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Cross-reference table mapping people to their credit card information in the CreditCard table. ', N'SCHEMA', [AW_Sales], N'TABLE', [AW_PersonCreditCard], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Business entity identification number. Foreign key to AW_Person.BusinessEntityID.', N'SCHEMA', [AW_Sales], N'TABLE', [AW_PersonCreditCard], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Credit card identification number. Foreign key to CreditCard.CreditCardID.', N'SCHEMA', [AW_Sales], N'TABLE', [AW_PersonCreditCard], N'COLUMN', [CreditCardID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [AW_PersonCreditCard], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Telephone number and type of a AW_Person.', N'SCHEMA', [AW_Person], N'TABLE', [AW_PersonPhone], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Business entity identification number. Foreign key to AW_Person.BusinessEntityID.', N'SCHEMA', [AW_Person], N'TABLE', [AW_PersonPhone], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Telephone number identification number.', N'SCHEMA', [AW_Person], N'TABLE', [AW_PersonPhone], N'COLUMN', [PhoneNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Kind of phone number. Foreign key to PhoneNumberType.PhoneNumberTypeID.', N'SCHEMA', [AW_Person], N'TABLE', [AW_PersonPhone], N'COLUMN', [PhoneNumberTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Person], N'TABLE', [AW_PersonPhone], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Type of phone number of a AW_Person.', N'SCHEMA', [AW_Person], N'TABLE', [PhoneNumberType], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for telephone number type records.', N'SCHEMA', [AW_Person], N'TABLE', [PhoneNumberType], N'COLUMN', [PhoneNumberTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Name of the telephone number type', N'SCHEMA', [AW_Person], N'TABLE', [PhoneNumberType], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Person], N'TABLE', [PhoneNumberType], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Products sold or used in the manfacturing of sold products.', N'SCHEMA', [AW_Production], N'TABLE', [Product], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for Product records.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Name of the product.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique product identification number.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [ProductNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'0 = Product is purchased, 1 = Product is manufactured in-house.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [MakeFlag];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'0 = Product is not a salable item. 1 = Product is salable.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [FinishedGoodsFlag];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product color.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [Color];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Minimum inventory quantity. ', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [SafetyStockLevel];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Inventory level that triggers a purchase order or work order. ', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [ReorderPoint];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Standard cost of the product.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [StandardCost];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Selling price.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [ListPrice];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product size.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [Size];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unit of measure for Size column.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [SizeUnitMeasureCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unit of measure for Weight column.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [WeightUnitMeasureCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product weight.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [Weight];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Number of days required to manufacture the product.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [DaysToManufacture];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'R = Road, M = Mountain, T = Touring, S = Standard', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [ProductLine];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'H = High, M = Medium, L = Low', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [Class];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'W = Womens, M = Mens, U = Universal', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [Style];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product is a member of this product subcategory. Foreign key to ProductSubCategory.ProductSubCategoryID. ', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [ProductSubcategoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product is a member of this product model. Foreign key to ProductModel.ProductModelID.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [ProductModelID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date the product was available for sale.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [SellStartDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date the product was no longer available for sale.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [SellEndDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date the product was discontinued.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [DiscontinuedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'High-level product categorization.', N'SCHEMA', [AW_Production], N'TABLE', [ProductCategory], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for ProductCategory records.', N'SCHEMA', [AW_Production], N'TABLE', [ProductCategory], N'COLUMN', [ProductCategoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Category description.', N'SCHEMA', [AW_Production], N'TABLE', [ProductCategory], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Production], N'TABLE', [ProductCategory], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [ProductCategory], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Changes in the cost of a product over time.', N'SCHEMA', [AW_Production], N'TABLE', [ProductCostHistory], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product identification number. Foreign key to Product.ProductID', N'SCHEMA', [AW_Production], N'TABLE', [ProductCostHistory], N'COLUMN', [ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product cost start date.', N'SCHEMA', [AW_Production], N'TABLE', [ProductCostHistory], N'COLUMN', [StartDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product cost end date.', N'SCHEMA', [AW_Production], N'TABLE', [ProductCostHistory], N'COLUMN', [EndDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Standard cost of the product.', N'SCHEMA', [AW_Production], N'TABLE', [ProductCostHistory], N'COLUMN', [StandardCost];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [ProductCostHistory], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product descriptions in several languages.', N'SCHEMA', [AW_Production], N'TABLE', [ProductDescription], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for ProductDescription records.', N'SCHEMA', [AW_Production], N'TABLE', [ProductDescription], N'COLUMN', [ProductDescriptionID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Description of the product.', N'SCHEMA', [AW_Production], N'TABLE', [ProductDescription], N'COLUMN', [Description];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Production], N'TABLE', [ProductDescription], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [ProductDescription], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Cross-reference table mapping products to related product documents.', N'SCHEMA', [AW_Production], N'TABLE', [ProductDocument], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product identification number. Foreign key to Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductDocument], N'COLUMN', [ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Document identification number. Foreign key to Document.DocumentNode.', N'SCHEMA', [AW_Production], N'TABLE', [ProductDocument], N'COLUMN', [DocumentNode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [ProductDocument], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product inventory information.', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product identification number. Foreign key to Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], N'COLUMN', [ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Inventory location identification number. Foreign key to Location.LocationID. ', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], N'COLUMN', [LocationID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Storage compartment within an inventory location.', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], N'COLUMN', [Shelf];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Storage container on a shelf in an inventory location.', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], N'COLUMN', [Bin];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Quantity of products in the inventory location.', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], N'COLUMN', [Quantity];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Changes in the list price of a product over time.', N'SCHEMA', [AW_Production], N'TABLE', [ProductListPriceHistory], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product identification number. Foreign key to Product.ProductID', N'SCHEMA', [AW_Production], N'TABLE', [ProductListPriceHistory], N'COLUMN', [ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'List price start date.', N'SCHEMA', [AW_Production], N'TABLE', [ProductListPriceHistory], N'COLUMN', [StartDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'List price end date', N'SCHEMA', [AW_Production], N'TABLE', [ProductListPriceHistory], N'COLUMN', [EndDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product list price.', N'SCHEMA', [AW_Production], N'TABLE', [ProductListPriceHistory], N'COLUMN', [ListPrice];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [ProductListPriceHistory], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product model classification.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModel], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for ProductModel records.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModel], N'COLUMN', [ProductModelID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product model description.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModel], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Detailed product catalog information in xml format.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModel], N'COLUMN', [CatalogDescription];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Manufacturing instructions in xml format.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModel], N'COLUMN', [Instructions];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModel], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModel], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Cross-reference table mapping product models and illustrations.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelIllustration], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to ProductModel.ProductModelID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelIllustration], N'COLUMN', [ProductModelID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to Illustration.IllustrationID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelIllustration], N'COLUMN', [IllustrationID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelIllustration], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Cross-reference table mapping product descriptions and the language the description is written in.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelProductDescriptionCulture], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to ProductModel.ProductModelID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelProductDescriptionCulture], N'COLUMN', [ProductModelID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to ProductDescription.ProductDescriptionID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelProductDescriptionCulture], N'COLUMN', [ProductDescriptionID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Culture identification number. Foreign key to Culture.CultureID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelProductDescriptionCulture], N'COLUMN', [CultureID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelProductDescriptionCulture], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product images.', N'SCHEMA', [AW_Production], N'TABLE', [ProductPhoto], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for ProductPhoto records.', N'SCHEMA', [AW_Production], N'TABLE', [ProductPhoto], N'COLUMN', [ProductPhotoID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Small image of the product.', N'SCHEMA', [AW_Production], N'TABLE', [ProductPhoto], N'COLUMN', [ThumbNailPhoto];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Small image file name.', N'SCHEMA', [AW_Production], N'TABLE', [ProductPhoto], N'COLUMN', [ThumbnailPhotoFileName];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Large image of the product.', N'SCHEMA', [AW_Production], N'TABLE', [ProductPhoto], N'COLUMN', [LargePhoto];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Large image file name.', N'SCHEMA', [AW_Production], N'TABLE', [ProductPhoto], N'COLUMN', [LargePhotoFileName];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [ProductPhoto], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Cross-reference table mapping products and product photos.', N'SCHEMA', [AW_Production], N'TABLE', [ProductProductPhoto], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product identification number. Foreign key to Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductProductPhoto], N'COLUMN', [ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product photo identification number. Foreign key to ProductPhoto.ProductPhotoID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductProductPhoto], N'COLUMN', [ProductPhotoID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'0 = Photo is not the principal image. 1 = Photo is the principal image.', N'SCHEMA', [AW_Production], N'TABLE', [ProductProductPhoto], N'COLUMN', [Primary];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [ProductProductPhoto], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Customer reviews of products they have purchased.', N'SCHEMA', [AW_Production], N'TABLE', [ProductReview], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for ProductReview records.', N'SCHEMA', [AW_Production], N'TABLE', [ProductReview], N'COLUMN', [ProductReviewID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product identification number. Foreign key to Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductReview], N'COLUMN', [ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Name of the reviewer.', N'SCHEMA', [AW_Production], N'TABLE', [ProductReview], N'COLUMN', [ReviewerName];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date review was submitted.', N'SCHEMA', [AW_Production], N'TABLE', [ProductReview], N'COLUMN', [ReviewDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Reviewer''s e-mail address.', N'SCHEMA', [AW_Production], N'TABLE', [ProductReview], N'COLUMN', [EmailAddress];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product rating given by the reviewer. Scale is 1 to 5 with 5 as the highest rating.', N'SCHEMA', [AW_Production], N'TABLE', [ProductReview], N'COLUMN', [Rating];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Reviewer''s comments', N'SCHEMA', [AW_Production], N'TABLE', [ProductReview], N'COLUMN', [Comments];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [ProductReview], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product subcategories. See ProductCategory table.', N'SCHEMA', [AW_Production], N'TABLE', [ProductSubcategory], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for ProductSubcategory records.', N'SCHEMA', [AW_Production], N'TABLE', [ProductSubcategory], N'COLUMN', [ProductSubcategoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product category identification number. Foreign key to ProductCategory.ProductCategoryID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductSubcategory], N'COLUMN', [ProductCategoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Subcategory description.', N'SCHEMA', [AW_Production], N'TABLE', [ProductSubcategory], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Production], N'TABLE', [ProductSubcategory], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [ProductSubcategory], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Cross-reference table mapping vendors with the products they supply.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to Product.ProductID.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'COLUMN', [ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to Vendor.BusinessEntityID.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The average span of time (in days) between placing an order with the vendor and receiving the purchased product.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'COLUMN', [AverageLeadTime];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The vendor''s usual selling price.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'COLUMN', [StandardPrice];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The selling price when last purchased.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'COLUMN', [LastReceiptCost];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date the product was last received by the vendor.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'COLUMN', [LastReceiptDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The maximum quantity that should be ordered.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'COLUMN', [MinOrderQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The minimum quantity that should be ordered.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'COLUMN', [MaxOrderQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The quantity currently on order.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'COLUMN', [OnOrderQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'The product''s unit of measure.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'COLUMN', [UnitMeasureCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Individual products associated with a specific purchase order. See PurchaseOrderHeader.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to PurchaseOrderHeader.PurchaseOrderID.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'COLUMN', [PurchaseOrderID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. One line number per purchased product.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'COLUMN', [PurchaseOrderDetailID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date the product is expected to be received.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'COLUMN', [DueDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Quantity ordered.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'COLUMN', [OrderQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product identification number. Foreign key to Product.ProductID.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'COLUMN', [ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Vendor''s selling price of a single product.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'COLUMN', [UnitPrice];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Per product subtotal. Computed as OrderQty * UnitPrice.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'COLUMN', [LineTotal];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Quantity actually received from the vendor.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'COLUMN', [ReceivedQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Quantity rejected during inspection.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'COLUMN', [RejectedQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Quantity accepted into inventory. Computed as ReceivedQty - RejectedQty.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'COLUMN', [StockedQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'General purchase order information. See PurchaseOrderDetail.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'COLUMN', [PurchaseOrderID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Incremental number to track changes to the purchase order over time.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'COLUMN', [RevisionNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Order current status. 1 = Pending; 2 = Approved; 3 = Rejected; 4 = Complete', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'COLUMN', [Status];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Employee who created the purchase order. Foreign key to Employee.BusinessEntityID.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'COLUMN', [EmployeeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Vendor with whom the purchase order is placed. Foreign key to Vendor.BusinessEntityID.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'COLUMN', [VendorID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Shipping method. Foreign key to ShipMethod.ShipMethodID.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'COLUMN', [ShipMethodID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Purchase order creation date.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'COLUMN', [OrderDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Estimated shipment date from the vendor.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'COLUMN', [ShipDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Purchase order subtotal. Computed as SUM(PurchaseOrderDetail.LineTotal)for the appropriate PurchaseOrderID.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'COLUMN', [SubTotal];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Tax amount.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'COLUMN', [TaxAmt];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Shipping cost.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'COLUMN', [Freight];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Total due to vendor. Computed as Subtotal + TaxAmt + Freight.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'COLUMN', [TotalDue];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Individual products associated with a specific sales order. See SalesOrderHeader.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to SalesOrderHeader.SalesOrderID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'COLUMN', [SalesOrderID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. One incremental unique number per product sold.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'COLUMN', [SalesOrderDetailID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Shipment tracking number supplied by the shipper.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'COLUMN', [CarrierTrackingNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Quantity ordered per product.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'COLUMN', [OrderQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product sold to customer. Foreign key to Product.ProductID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'COLUMN', [ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Promotional code. Foreign key to SpecialOffer.SpecialOfferID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'COLUMN', [SpecialOfferID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Selling price of a single product.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'COLUMN', [UnitPrice];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Discount amount.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'COLUMN', [UnitPriceDiscount];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Per product subtotal. Computed as UnitPrice * (1 - UnitPriceDiscount) * OrderQty.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'COLUMN', [LineTotal];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'General sales order information.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [SalesOrderID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Incremental number to track changes to the sales order over time.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [RevisionNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Dates the sales order was created.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [OrderDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date the order is due to the customer.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [DueDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date the order was shipped to the customer.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [ShipDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Order current status. 1 = In process; 2 = Approved; 3 = Backordered; 4 = Rejected; 5 = Shipped; 6 = Cancelled', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [Status];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'0 = Order placed by sales AW_Person. 1 = Order placed online by customer.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [OnlineOrderFlag];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique sales order identification number.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [SalesOrderNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Customer purchase order number reference. ', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [PurchaseOrderNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Financial accounting number reference.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [AccountNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Customer identification number. Foreign key to Customer.BusinessEntityID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [CustomerID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales AW_Person who created the sales order. Foreign key to SalesAW_Person.BusinessEntityID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [SalesAW_PersonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Territory in which the sale was made. Foreign key to SalesTerritory.SalesTerritoryID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [TerritoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Customer billing address. Foreign key to Address.AddressID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [BillToAddressID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Customer shipping address. Foreign key to Address.AddressID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [ShipToAddressID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Shipping method. Foreign key to ShipMethod.ShipMethodID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [ShipMethodID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Credit card identification number. Foreign key to CreditCard.CreditCardID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [CreditCardID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Approval code provided by the credit card company.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [CreditCardApprovalCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Currency exchange rate used. Foreign key to CurrencyRate.CurrencyRateID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [CurrencyRateID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales subtotal. Computed as SUM(SalesOrderDetail.LineTotal)for the appropriate SalesOrderID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [SubTotal];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Tax amount.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [TaxAmt];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Shipping cost.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [Freight];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Total due from customer. Computed as Subtotal + TaxAmt + Freight.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [TotalDue];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales representative comments.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [Comment];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Cross-reference table mapping sales orders to sales reason codes.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeaderSalesReason], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to SalesOrderHeader.SalesOrderID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeaderSalesReason], N'COLUMN', [SalesOrderID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to SalesReason.SalesReasonID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeaderSalesReason], N'COLUMN', [SalesReasonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeaderSalesReason], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales representative current information.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for SalesAW_Person records. Foreign key to Employee.BusinessEntityID', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Territory currently assigned to. Foreign key to SalesTerritory.SalesTerritoryID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'COLUMN', [TerritoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Projected yearly AW_Sales.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'COLUMN', [SalesQuota];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Bonus due if quota is met.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'COLUMN', [Bonus];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Commision percent received per sale.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'COLUMN', [CommissionPct];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales total year to date.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'COLUMN', [SalesYTD];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales total of previous year.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'COLUMN', [SalesLastYear];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales performance tracking.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_PersonQuotaHistory], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales AW_Person identification number. Foreign key to SalesAW_Person.BusinessEntityID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_PersonQuotaHistory], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales quota date.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_PersonQuotaHistory], N'COLUMN', [QuotaDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales quota amount.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_PersonQuotaHistory], N'COLUMN', [SalesQuota];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_PersonQuotaHistory], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_PersonQuotaHistory], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Lookup table of customer purchase reasons.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesReason], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for SalesReason records.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesReason], N'COLUMN', [SalesReasonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales reason description.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesReason], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Category the sales reason belongs to.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesReason], N'COLUMN', [ReasonType];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesReason], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Tax rate lookup table.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for SalesTaxRate records.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], N'COLUMN', [SalesTaxRateID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'State, province, or country/region the sales tax applies to.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], N'COLUMN', [StateProvinceID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'1 = Tax applied to retail transactions, 2 = Tax applied to wholesale transactions, 3 = Tax applied to all sales (retail and wholesale) transactions.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], N'COLUMN', [TaxType];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Tax rate amount.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], N'COLUMN', [TaxRate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Tax rate description.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales territory lookup table.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for SalesTerritory records.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'COLUMN', [TerritoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales territory description', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ISO standard country or region code. Foreign key to CountryRegion.CountryRegionCode. ', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'COLUMN', [CountryRegionCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Geographic area to which the sales territory belong.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'COLUMN', [Group];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales in the territory year to date.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'COLUMN', [SalesYTD];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales in the territory the previous year.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'COLUMN', [SalesLastYear];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Business costs in the territory year to date.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'COLUMN', [CostYTD];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Business costs in the territory the previous year.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'COLUMN', [CostLastYear];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales representative transfers to other sales territories.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritoryHistory], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. The sales rep.  Foreign key to SalesAW_Person.BusinessEntityID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritoryHistory], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Territory identification number. Foreign key to SalesTerritory.SalesTerritoryID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritoryHistory], N'COLUMN', [TerritoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Date the sales representive started work in the territory.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritoryHistory], N'COLUMN', [StartDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date the sales representative left work in the territory.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritoryHistory], N'COLUMN', [EndDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritoryHistory], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritoryHistory], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Manufacturing failure reasons lookup table.', N'SCHEMA', [AW_Production], N'TABLE', [ScrapReason], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for ScrapReason records.', N'SCHEMA', [AW_Production], N'TABLE', [ScrapReason], N'COLUMN', [ScrapReasonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Failure description.', N'SCHEMA', [AW_Production], N'TABLE', [ScrapReason], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [ScrapReason], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Work shift lookup table.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Shift], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for Shift records.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Shift], N'COLUMN', [ShiftID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Shift description.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Shift], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Shift start time.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Shift], N'COLUMN', [StartTime];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Shift end time.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Shift], N'COLUMN', [EndTime];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Shift], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Shipping company lookup table.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for ShipMethod records.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], N'COLUMN', [ShipMethodID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Shipping company name.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Minimum shipping charge.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], N'COLUMN', [ShipBase];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Shipping charge per pound.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], N'COLUMN', [ShipRate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Contains online customer orders until the order is submitted or cancelled.', N'SCHEMA', [AW_Sales], N'TABLE', [ShoppingCartItem], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for ShoppingCartItem records.', N'SCHEMA', [AW_Sales], N'TABLE', [ShoppingCartItem], N'COLUMN', [ShoppingCartItemID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Shopping cart identification number.', N'SCHEMA', [AW_Sales], N'TABLE', [ShoppingCartItem], N'COLUMN', [ShoppingCartID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product quantity ordered.', N'SCHEMA', [AW_Sales], N'TABLE', [ShoppingCartItem], N'COLUMN', [Quantity];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product ordered. Foreign key to Product.ProductID.', N'SCHEMA', [AW_Sales], N'TABLE', [ShoppingCartItem], N'COLUMN', [ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date the time the record was created.', N'SCHEMA', [AW_Sales], N'TABLE', [ShoppingCartItem], N'COLUMN', [DateCreated];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [ShoppingCartItem], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sale discounts lookup table.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for SpecialOffer records.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'COLUMN', [SpecialOfferID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Discount description.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'COLUMN', [Description];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Discount precentage.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'COLUMN', [DiscountPct];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Discount type category.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'COLUMN', [Type];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Group the discount applies to such as Reseller or Customer.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'COLUMN', [Category];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Discount start date.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'COLUMN', [StartDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Discount end date.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'COLUMN', [EndDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Minimum discount percent allowed.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'COLUMN', [MinQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Maximum discount percent allowed.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'COLUMN', [MaxQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Cross-reference table mapping products to special offer discounts.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOfferProduct], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for SpecialOfferProduct records.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOfferProduct], N'COLUMN', [SpecialOfferID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product identification number. Foreign key to Product.ProductID.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOfferProduct], N'COLUMN', [ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOfferProduct], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOfferProduct], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'State and province lookup table.', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for StateProvince records.', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'COLUMN', [StateProvinceID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ISO standard state or province code.', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'COLUMN', [StateProvinceCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ISO standard country or region code. Foreign key to CountryRegion.CountryRegionCode. ', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'COLUMN', [CountryRegionCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'0 = StateProvinceCode exists. 1 = StateProvinceCode unavailable, using CountryRegionCode.', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'COLUMN', [IsOnlyStateProvinceFlag];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'State or province description.', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ID of the territory in which the state or province is located. Foreign key to SalesTerritory.SalesTerritoryID.', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'COLUMN', [TerritoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Customers (resellers) of Adventure Works products.', N'SCHEMA', [AW_Sales], N'TABLE', [Store], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to Customer.BusinessEntityID.', N'SCHEMA', [AW_Sales], N'TABLE', [Store], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Name of the store.', N'SCHEMA', [AW_Sales], N'TABLE', [Store], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ID of the sales AW_Person assigned to the customer. Foreign key to SalesAW_Person.BusinessEntityID.', N'SCHEMA', [AW_Sales], N'TABLE', [Store], N'COLUMN', [SalesAW_PersonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Demographic informationg about the store such as the number of employees, annual sales and store type.', N'SCHEMA', [AW_Sales], N'TABLE', [Store], N'COLUMN', [Demographics];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'ROWGUIDCOL number uniquely identifying the record. Used to support a merge replication sample.', N'SCHEMA', [AW_Sales], N'TABLE', [Store], N'COLUMN', [rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Sales], N'TABLE', [Store], N'COLUMN', [ModifiedDate];
GO


EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Record of each purchase order, sales order, or work order transaction year to date.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for TransactionHistory records.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'COLUMN', [TransactionID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product identification number. Foreign key to Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'COLUMN', [ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Purchase order, sales order, or work order identification number.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'COLUMN', [ReferenceOrderID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Line number associated with the purchase order, sales order, or work order.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'COLUMN', [ReferenceOrderLineID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time of the transaction.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'COLUMN', [TransactionDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'W = WorkOrder, S = SalesOrder, P = PurchaseOrder', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'COLUMN', [TransactionType];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product quantity.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'COLUMN', [Quantity];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product cost.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'COLUMN', [ActualCost];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Transactions for previous years.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for TransactionHistoryArchive records.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'COLUMN', [TransactionID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product identification number. Foreign key to Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'COLUMN', [ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Purchase order, sales order, or work order identification number.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'COLUMN', [ReferenceOrderID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Line number associated with the purchase order, sales order, or work order.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'COLUMN', [ReferenceOrderLineID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time of the transaction.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'COLUMN', [TransactionDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'W = Work Order, S = Sales Order, P = Purchase Order', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'COLUMN', [TransactionType];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product quantity.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'COLUMN', [Quantity];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product cost.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'COLUMN', [ActualCost];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unit of measure lookup table.', N'SCHEMA', [AW_Production], N'TABLE', [UnitMeasure], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key.', N'SCHEMA', [AW_Production], N'TABLE', [UnitMeasure], N'COLUMN', [UnitMeasureCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unit of measure description.', N'SCHEMA', [AW_Production], N'TABLE', [UnitMeasure], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [UnitMeasure], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Companies from whom Adventure Works Cycles purchases parts or other goods.', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for Vendor records.  Foreign key to BusinessEntity.BusinessEntityID', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'COLUMN', [BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Vendor account (identification) number.', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'COLUMN', [AccountNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Company name.', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'COLUMN', [Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'1 = Superior, 2 = Excellent, 3 = Above average, 4 = Average, 5 = Below average', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'COLUMN', [CreditRating];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'0 = Do not use if another vendor is available. 1 = Preferred over other vendors supplying the same product.', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'COLUMN', [PreferredVendorStatus];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'0 = Vendor no longer used. 1 = Vendor is actively used.', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'COLUMN', [ActiveFlag];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Vendor URL.', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'COLUMN', [PurchasingWebServiceURL];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Manufacturing work orders.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key for WorkOrder records.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'COLUMN', [WorkOrderID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product identification number. Foreign key to Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'COLUMN', [ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product quantity to build.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'COLUMN', [OrderQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Quantity built and put in inventory.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'COLUMN', [StockedQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Quantity that failed inspection.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'COLUMN', [ScrappedQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Work order start date.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'COLUMN', [StartDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Work order end date.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'COLUMN', [EndDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Work order due date.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'COLUMN', [DueDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Reason for inspection failure.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'COLUMN', [ScrapReasonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'COLUMN', [ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Work order details.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to WorkOrder.WorkOrderID.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'COLUMN', [WorkOrderID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Foreign key to Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'COLUMN', [ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key. Indicates the manufacturing process sequence.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'COLUMN', [OperationSequence];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Manufacturing location where the part is processed. Foreign key to Location.LocationID.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'COLUMN', [LocationID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Planned manufacturing start date.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'COLUMN', [ScheduledStartDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Planned manufacturing end date.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'COLUMN', [ScheduledEndDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Actual start date.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'COLUMN', [ActualStartDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Actual end date.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'COLUMN', [ActualEndDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Number of manufacturing hours used.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'COLUMN', [ActualResourceHrs];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Estimated manufacturing cost.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'COLUMN', [PlannedCost];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Actual manufacturing cost.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'COLUMN', [ActualCost];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Date and time the record was last updated.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'COLUMN', [ModifiedDate];
GO

PRINT '    Triggers';
GO

-- Triggers
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'INSTEAD OF DELETE trigger which keeps Employees from being deleted.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'TRIGGER', [dEmployee];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'AFTER INSERT, UPDATE trigger inserting Individual only if the Customer does not exist in the Store table and setting the ModifiedDate column in the AW_Person table to the current date.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'TRIGGER', [iuAW_Person];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'AFTER INSERT trigger that inserts a row in the TransactionHistory table and updates the PurchaseOrderHeader.SubTotal column.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'TRIGGER', [iPurchaseOrderDetail];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'AFTER UPDATE trigger that inserts a row in the TransactionHistory table, updates ModifiedDate in PurchaseOrderDetail and updates the PurchaseOrderHeader.SubTotal column.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'TRIGGER', [uPurchaseOrderDetail];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'AFTER UPDATE trigger that updates the RevisionNumber and ModifiedDate columns in the PurchaseOrderHeader table.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'TRIGGER', [uPurchaseOrderHeader];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'AFTER INSERT, DELETE, UPDATE trigger that inserts a row in the TransactionHistory table, updates ModifiedDate in SalesOrderDetail and updates the SalesOrderHeader.SubTotal column.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'TRIGGER', [iduSalesOrderDetail];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'AFTER UPDATE trigger that updates the RevisionNumber and ModifiedDate columns in the SalesOrderHeader table.Updates the SalesYTD column in the SalesAW_Person and SalesTerritory tables.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'TRIGGER', [uSalesOrderHeader];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'INSTEAD OF DELETE trigger which keeps Vendors from being deleted.', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'TRIGGER', [dVendor];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'AFTER INSERT trigger that inserts a row in the TransactionHistory table.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'TRIGGER', [iWorkOrder];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'AFTER UPDATE trigger that inserts a row in the TransactionHistory table, updates ModifiedDate in the WorkOrder table.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'TRIGGER', [uWorkOrder];
GO

PRINT '    Views';
GO

-- Views
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Displays the contact name and content from each element in the xml column AdditionalContactInfo for that AW_Person.', N'SCHEMA', [AW_Person], N'VIEW', [vAdditionalContactInfo], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Employee names and addresses.', N'SCHEMA', [AW_HumanResources], N'VIEW', [vEmployee], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Returns employee name, title, and current department.', N'SCHEMA', [AW_HumanResources], N'VIEW', [vEmployeeDepartment], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Returns employee name and current and previous departments.', N'SCHEMA', [AW_HumanResources], N'VIEW', [vEmployeeDepartmentHistory], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Individual customers (names and addresses) that purchase Adventure Works Cycles products online.', N'SCHEMA', [AW_Sales], N'VIEW', [vIndividualCustomer], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Displays the content from each element in the xml column Demographics for each customer in the AW_Person.AW_Person table.', N'SCHEMA', [AW_Sales], N'VIEW', [vAW_PersonDemographics], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Job candidate names and resumes.', N'SCHEMA', [AW_HumanResources], N'VIEW', [vJobCandidate], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Displays the content from each employement history related element in the xml column Resume in the AW_HumanResources.JobCandidate table. The content has been localized into French, Simplified Chinese and Thai. Some data may not display correctly unless supplemental language support is installed.', N'SCHEMA', [AW_HumanResources], N'VIEW', [vJobCandidateEmployment], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Displays the content from each education related element in the xml column Resume in the AW_HumanResources.JobCandidate table. The content has been localized into French, Simplified Chinese and Thai. Some data may not display correctly unless supplemental language support is installed.', N'SCHEMA', [AW_HumanResources], N'VIEW', [vJobCandidateEducation], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Product names and descriptions. Product descriptions are provided in multiple languages.', N'SCHEMA', [AW_Production], N'VIEW', [vProductAndDescription], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Displays the content from each element in the xml column CatalogDescription for each product in the AW_Production.ProductModel table that has catalog data.', N'SCHEMA', [AW_Production], N'VIEW', [vProductModelCatalogDescription], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Displays the content from each element in the xml column Instructions for each product in the AW_Production.ProductModel table that has manufacturing instructions.', N'SCHEMA', [AW_Production], N'VIEW', [vProductModelInstructions], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Sales representiatives (names and addresses) and their sales-related information.', N'SCHEMA', [AW_Sales], N'VIEW', [vSalesAW_Person], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Uses PIVOT to return aggregated sales information for each sales representative.', N'SCHEMA', [AW_Sales], N'VIEW', [vSalesAW_PersonSalesByFiscalYears], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Joins StateProvince table with CountryRegion table.', N'SCHEMA', [AW_Person], N'VIEW', [vStateProvinceCountryRegion], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Stores (including demographics) that sell Adventure Works Cycles products to consumers.', N'SCHEMA', [AW_Sales], N'VIEW', [vStoreWithDemographics], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Stores (including store contacts) that sell Adventure Works Cycles products to consumers.', N'SCHEMA', [AW_Sales], N'VIEW', [vStoreWithContacts], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Stores (including store addresses) that sell Adventure Works Cycles products to consumers.', N'SCHEMA', [AW_Sales], N'VIEW', [vStoreWithAddresses], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Vendor (company) names  and the names of vendor employees to contact.', N'SCHEMA', [AW_Purchasing], N'VIEW', [vVendorWithContacts], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Vendor (company) names and addresses .', N'SCHEMA', [AW_Purchasing], N'VIEW', [vVendorWithAddresses], NULL, NULL;
GO

PRINT '    Indexes';
GO

-- Indexes
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'INDEX', [AK_Address_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'INDEX', [IX_Address_AddressLine1_AddressLine2_City_StateProvinceID_PostalCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'INDEX', [IX_Address_StateProvinceID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'INDEX', [PK_Address_AddressID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Person], N'TABLE', [AddressType], N'INDEX', [AK_AddressType_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Person], N'TABLE', [AddressType], N'INDEX', [AK_AddressType_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Person], N'TABLE', [AddressType], N'INDEX', [PK_AddressType_AddressTypeID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [dbo], N'TABLE', [AWBuildVersion], N'INDEX', [PK_AWBuildVersion_SystemInformationID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index.', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'INDEX', [AK_BillOfMaterials_ProductAssemblyID_ComponentID_StartDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'INDEX', [IX_BillOfMaterials_UnitMeasureCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'INDEX', [PK_BillOfMaterials_BillOfMaterialsID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntity], N'INDEX', [AK_BusinessEntity_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntity], N'INDEX', [PK_BusinessEntity_BusinessEntityID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityAddress], N'INDEX', [AK_BusinessEntityAddress_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityAddress], N'INDEX', [IX_BusinessEntityAddress_AddressID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityAddress], N'INDEX', [IX_BusinessEntityAddress_AddressTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityAddress], N'INDEX', [PK_BusinessEntityAddress_BusinessEntityID_AddressID_AddressTypeID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityContact], N'INDEX', [AK_BusinessEntityContact_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityContact], N'INDEX', [IX_BusinessEntityContact_AW_PersonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityContact], N'INDEX', [IX_BusinessEntityContact_ContactTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityContact], N'INDEX', [PK_BusinessEntityContact_BusinessEntityID_AW_PersonID_ContactTypeID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Person], N'TABLE', [ContactType], N'INDEX', [AK_ContactType_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Person], N'TABLE', [ContactType], N'INDEX', [PK_ContactType_ContactTypeID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Person], N'TABLE', [CountryRegion], N'INDEX', [AK_CountryRegion_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Person], N'TABLE', [CountryRegion], N'INDEX', [PK_CountryRegion_CountryRegionCode];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Sales], N'TABLE', [CountryRegionCurrency], N'INDEX', [IX_CountryRegionCurrency_CurrencyCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [CountryRegionCurrency], N'INDEX', [PK_CountryRegionCurrency_CountryRegionCode_CurrencyCode];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Sales], N'TABLE', [CreditCard], N'INDEX', [AK_CreditCard_CardNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [CreditCard], N'INDEX', [PK_CreditCard_CreditCardID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [Culture], N'INDEX', [AK_Culture_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [Culture], N'INDEX', [PK_Culture_CultureID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Sales], N'TABLE', [Currency], N'INDEX', [AK_Currency_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [Currency], N'INDEX', [PK_Currency_CurrencyCode];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Sales], N'TABLE', [CurrencyRate], N'INDEX', [AK_CurrencyRate_CurrencyRateDate_FromCurrencyCode_ToCurrencyCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [CurrencyRate], N'INDEX', [PK_CurrencyRate_CurrencyRateID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'INDEX', [AK_Customer_AccountNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'INDEX', [AK_Customer_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'INDEX', [IX_Customer_TerritoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'INDEX', [PK_Customer_CustomerID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index created by a primary key constraint.', N'SCHEMA', [dbo], N'TABLE', [DatabaseLog], N'INDEX', [PK_DatabaseLog_DatabaseLogID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Department], N'INDEX', [AK_Department_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Department], N'INDEX', [PK_Department_DepartmentID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'INDEX', [AK_Document_DocumentLevel_DocumentNode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'INDEX', [IX_Document_FileName_Revision];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'INDEX', [PK_Document_DocumentNode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support FileStream.', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'INDEX', [AK_Document_rowguid];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Person], N'TABLE', [EmailAddress], N'INDEX', [IX_EmailAddress_EmailAddress];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Person], N'TABLE', [EmailAddress], N'INDEX', [PK_EmailAddress_BusinessEntityID_EmailAddressID];


EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'INDEX', [AK_Employee_LoginID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'INDEX', [AK_Employee_NationalIDNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'INDEX', [AK_Employee_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'INDEX', [IX_Employee_OrganizationNode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'INDEX', [IX_Employee_OrganizationLevel_OrganizationNode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'INDEX', [PK_Employee_BusinessEntityID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeeDepartmentHistory], N'INDEX', [IX_EmployeeDepartmentHistory_DepartmentID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeeDepartmentHistory], N'INDEX', [IX_EmployeeDepartmentHistory_ShiftID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeeDepartmentHistory], N'INDEX', [PK_EmployeeDepartmentHistory_BusinessEntityID_StartDate_DepartmentID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeePayHistory], N'INDEX', [PK_EmployeePayHistory_BusinessEntityID_RateChangeDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [dbo], N'TABLE', [ErrorLog], N'INDEX', [PK_ErrorLog_ErrorLogID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [Illustration], N'INDEX', [PK_Illustration_IllustrationID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_HumanResources], N'TABLE', [JobCandidate], N'INDEX', [IX_JobCandidate_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_HumanResources], N'TABLE', [JobCandidate], N'INDEX', [PK_JobCandidate_JobCandidateID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [Location], N'INDEX', [AK_Location_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [Location], N'INDEX', [PK_Location_LocationID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Person], N'TABLE', [Password], N'INDEX', [PK_Password_BusinessEntityID];

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'INDEX', [AK_AW_Person_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'INDEX', [PK_AW_Person_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary XML index.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'INDEX', [PXML_AW_Person_Demographics];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Secondary XML index for path.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'INDEX', [XMLPATH_AW_Person_Demographics];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Secondary XML index for property.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'INDEX', [XMLPROPERTY_AW_Person_Demographics];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Secondary XML index for value.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'INDEX', [XMLVALUE_AW_Person_Demographics];

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary XML index.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'INDEX', [PXML_AW_Person_AddContact];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [AW_PersonCreditCard], N'INDEX', [PK_AW_PersonCreditCard_BusinessEntityID_CreditCardID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Person], N'TABLE', [AW_PersonPhone], N'INDEX', [PK_AW_PersonPhone_BusinessEntityID_PhoneNumber_PhoneNumberTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Person], N'TABLE', [AW_PersonPhone], N'INDEX', [IX_AW_PersonPhone_PhoneNumber];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Person], N'TABLE', [PhoneNumberType], N'INDEX', [PK_PhoneNumberType_PhoneNumberTypeID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'INDEX', [AK_Product_ProductNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'INDEX', [PK_Product_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'INDEX', [AK_Product_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'INDEX', [AK_Product_rowguid];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [ProductCategory], N'INDEX', [AK_ProductCategory_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Production], N'TABLE', [ProductCategory], N'INDEX', [AK_ProductCategory_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [ProductCategory], N'INDEX', [PK_ProductCategory_ProductCategoryID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [ProductCostHistory], N'INDEX', [PK_ProductCostHistory_ProductID_StartDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Production], N'TABLE', [ProductDescription], N'INDEX', [AK_ProductDescription_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [ProductDescription], N'INDEX', [PK_ProductDescription_ProductDescriptionID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [ProductDocument], N'INDEX', [PK_ProductDocument_ProductID_DocumentNode];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], N'INDEX', [PK_ProductInventory_ProductID_LocationID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [ProductListPriceHistory], N'INDEX', [PK_ProductListPriceHistory_ProductID_StartDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModel], N'INDEX', [AK_ProductModel_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModel], N'INDEX', [AK_ProductModel_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModel], N'INDEX', [PK_ProductModel_ProductModelID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary XML index.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModel], N'INDEX', [PXML_ProductModel_CatalogDescription];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary XML index.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModel], N'INDEX', [PXML_ProductModel_Instructions];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelIllustration], N'INDEX', [PK_ProductModelIllustration_ProductModelID_IllustrationID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelProductDescriptionCulture], N'INDEX', [PK_ProductModelProductDescriptionCulture_ProductModelID_ProductDescriptionID_CultureID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [ProductPhoto], N'INDEX', [PK_ProductPhoto_ProductPhotoID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [ProductProductPhoto], N'INDEX', [PK_ProductProductPhoto_ProductID_ProductPhotoID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [ProductReview], N'INDEX', [IX_ProductReview_ProductID_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [ProductReview], N'INDEX', [PK_ProductReview_ProductReviewID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [ProductSubcategory], N'INDEX', [AK_ProductSubcategory_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Production], N'TABLE', [ProductSubcategory], N'INDEX', [AK_ProductSubcategory_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [ProductSubcategory], N'INDEX', [PK_ProductSubcategory_ProductSubcategoryID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'INDEX', [IX_ProductVendor_UnitMeasureCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'INDEX', [IX_ProductVendor_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'INDEX', [PK_ProductVendor_ProductID_BusinessEntityID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'INDEX', [IX_PurchaseOrderDetail_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'INDEX', [PK_PurchaseOrderDetail_PurchaseOrderID_PurchaseOrderDetailID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'INDEX', [IX_PurchaseOrderHeader_EmployeeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'INDEX', [IX_PurchaseOrderHeader_VendorID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'INDEX', [PK_PurchaseOrderHeader_PurchaseOrderID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'INDEX', [AK_SalesOrderDetail_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'INDEX', [IX_SalesOrderDetail_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'INDEX', [PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'INDEX', [AK_SalesOrderHeader_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'INDEX', [AK_SalesOrderHeader_SalesOrderNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'INDEX', [IX_SalesOrderHeader_CustomerID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'INDEX', [IX_SalesOrderHeader_SalesAW_PersonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'INDEX', [PK_SalesOrderHeader_SalesOrderID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeaderSalesReason], N'INDEX', [PK_SalesOrderHeaderSalesReason_SalesOrderID_SalesReasonID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'INDEX', [AK_SalesAW_Person_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'INDEX', [PK_SalesAW_Person_BusinessEntityID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_PersonQuotaHistory], N'INDEX', [AK_SalesAW_PersonQuotaHistory_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_PersonQuotaHistory], N'INDEX', [PK_SalesAW_PersonQuotaHistory_BusinessEntityID_QuotaDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesReason], N'INDEX', [PK_SalesReason_SalesReasonID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], N'INDEX', [AK_SalesTaxRate_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], N'INDEX', [AK_SalesTaxRate_StateProvinceID_TaxType];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], N'INDEX', [PK_SalesTaxRate_SalesTaxRateID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'INDEX', [AK_SalesTerritory_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'INDEX', [AK_SalesTerritory_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'INDEX', [PK_SalesTerritory_TerritoryID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritoryHistory], N'INDEX', [AK_SalesTerritoryHistory_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritoryHistory], N'INDEX', [PK_SalesTerritoryHistory_BusinessEntityID_StartDate_TerritoryID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [ScrapReason], N'INDEX', [AK_ScrapReason_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [ScrapReason], N'INDEX', [PK_ScrapReason_ScrapReasonID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Shift], N'INDEX', [AK_Shift_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Shift], N'INDEX', [AK_Shift_StartTime_EndTime];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Shift], N'INDEX', [PK_Shift_ShiftID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], N'INDEX', [AK_ShipMethod_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], N'INDEX', [AK_ShipMethod_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], N'INDEX', [PK_ShipMethod_ShipMethodID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Sales], N'TABLE', [ShoppingCartItem], N'INDEX', [IX_ShoppingCartItem_ShoppingCartID_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [ShoppingCartItem], N'INDEX', [PK_ShoppingCartItem_ShoppingCartItemID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'INDEX', [AK_SpecialOffer_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'INDEX', [PK_SpecialOffer_SpecialOfferID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOfferProduct], N'INDEX', [AK_SpecialOfferProduct_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOfferProduct], N'INDEX', [IX_SpecialOfferProduct_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOfferProduct], N'INDEX', [PK_SpecialOfferProduct_SpecialOfferID_ProductID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'INDEX', [AK_StateProvince_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'INDEX', [AK_StateProvince_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'INDEX', [AK_StateProvince_StateProvinceCode_CountryRegionCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'INDEX', [PK_StateProvince_StateProvinceID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index. Used to support replication samples.', N'SCHEMA', [AW_Sales], N'TABLE', [Store], N'INDEX', [AK_Store_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Sales], N'TABLE', [Store], N'INDEX', [PK_Store_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Sales], N'TABLE', [Store], N'INDEX', [IX_Store_SalesAW_PersonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary XML index.', N'SCHEMA', [AW_Sales], N'TABLE', [Store], N'INDEX', [PXML_Store_Demographics];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'INDEX', [IX_TransactionHistory_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'INDEX', [IX_TransactionHistory_ReferenceOrderID_ReferenceOrderLineID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'INDEX', [PK_TransactionHistory_TransactionID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'INDEX', [IX_TransactionHistoryArchive_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'INDEX', [IX_TransactionHistoryArchive_ReferenceOrderID_ReferenceOrderLineID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'INDEX', [PK_TransactionHistoryArchive_TransactionID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [UnitMeasure], N'INDEX', [AK_UnitMeasure_Name];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [UnitMeasure], N'INDEX', [PK_UnitMeasure_UnitMeasureCode];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Unique nonclustered index.', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'INDEX', [AK_Vendor_AccountNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'INDEX', [PK_Vendor_BusinessEntityID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'INDEX', [IX_WorkOrder_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'INDEX', [IX_WorkOrder_ScrapReasonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'INDEX', [PK_WorkOrder_WorkOrderID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Nonclustered index.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'INDEX', [IX_WorkOrderRouting_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index created by a primary key constraint.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'INDEX', [PK_WorkOrderRouting_WorkOrderID_ProductID_OperationSequence];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index on the view vProductAndDescription.', N'SCHEMA', [AW_Production], N'VIEW', [vProductAndDescription], N'INDEX', [IX_vProductAndDescription];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Clustered index on the view vStateProvinceCountryRegion.', N'SCHEMA', [AW_Person], N'VIEW', [vStateProvinceCountryRegion], N'INDEX', [IX_vStateProvinceCountryRegion];
GO

PRINT '    Constraints - PK, FK, DF, CK';
GO

-- Constraints - PK, FK, DF, CK
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'CONSTRAINT', [PK_Address_AddressID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing StateProvince.StateProvinceID.', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'CONSTRAINT', [FK_Address_StateProvince_StateProvinceID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'CONSTRAINT', [DF_Address_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Person], N'TABLE', [Address], N'CONSTRAINT', [DF_Address_rowguid];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Person], N'TABLE', [AddressType], N'CONSTRAINT', [PK_AddressType_AddressTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Person], N'TABLE', [AddressType], N'CONSTRAINT', [DF_AddressType_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Person], N'TABLE', [AddressType], N'CONSTRAINT', [DF_AddressType_rowguid];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [dbo], N'TABLE', [AWBuildVersion], N'CONSTRAINT', [PK_AWBuildVersion_SystemInformationID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [dbo], N'TABLE', [AWBuildVersion], N'CONSTRAINT', [DF_AWBuildVersion_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'CONSTRAINT', [PK_BillOfMaterials_BillOfMaterialsID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Product.ComponentID.', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'CONSTRAINT', [FK_BillOfMaterials_Product_ComponentID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Product.ProductAssemblyID.', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'CONSTRAINT', [FK_BillOfMaterials_Product_ProductAssemblyID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing UnitMeasure.UnitMeasureCode.', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'CONSTRAINT', [FK_BillOfMaterials_UnitMeasure_UnitMeasureCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 1.0', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'CONSTRAINT', [DF_BillOfMaterials_PerAssemblyQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'CONSTRAINT', [DF_BillOfMaterials_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'CONSTRAINT', [DF_BillOfMaterials_StartDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [PerAssemblyQty] >= (1.00)', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'CONSTRAINT', [CK_BillOfMaterials_PerAssemblyQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [ProductAssemblyID] <> [ComponentID]', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'CONSTRAINT', [CK_BillOfMaterials_ProductAssemblyID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint EndDate] > [StartDate] OR [EndDate] IS NULL', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'CONSTRAINT', [CK_BillOfMaterials_EndDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [ProductAssemblyID] IS NULL AND [BOMLevel] = (0) AND [PerAssemblyQty] = (1) OR [ProductAssemblyID] IS NOT NULL AND [BOMLevel] >= (1)', N'SCHEMA', [AW_Production], N'TABLE', [BillOfMaterials], N'CONSTRAINT', [CK_BillOfMaterials_BOMLevel];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntity], N'CONSTRAINT', [PK_BusinessEntity_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntity], N'CONSTRAINT', [DF_BusinessEntity_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntity], N'CONSTRAINT', [DF_BusinessEntity_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityAddress], N'CONSTRAINT', [PK_BusinessEntityAddress_BusinessEntityID_AddressID_AddressTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Address.AddressID.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityAddress], N'CONSTRAINT', [FK_BusinessEntityAddress_Address_AddressID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing AddressType.AddressTypeID.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityAddress], N'CONSTRAINT', [FK_BusinessEntityAddress_AddressType_AddressTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing BusinessEntity.BusinessEntityID.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityAddress], N'CONSTRAINT', [FK_BusinessEntityAddress_BusinessEntity_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityAddress], N'CONSTRAINT', [DF_BusinessEntityAddress_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityAddress], N'CONSTRAINT', [DF_BusinessEntityAddress_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityContact], N'CONSTRAINT', [PK_BusinessEntityContact_BusinessEntityID_AW_PersonID_ContactTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing AW_Person.BusinessEntityID.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityContact], N'CONSTRAINT', [FK_BusinessEntityContact_AW_Person_AW_PersonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing ContactType.ContactTypeID.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityContact], N'CONSTRAINT', [FK_BusinessEntityContact_ContactType_ContactTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing BusinessEntity.BusinessEntityID.', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityContact], N'CONSTRAINT', [FK_BusinessEntityContact_BusinessEntity_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityContact], N'CONSTRAINT', [DF_BusinessEntityContact_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Person], N'TABLE', [BusinessEntityContact], N'CONSTRAINT', [DF_BusinessEntityContact_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Person], N'TABLE', [ContactType], N'CONSTRAINT', [PK_ContactType_ContactTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Person], N'TABLE', [ContactType], N'CONSTRAINT', [DF_ContactType_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Person], N'TABLE', [CountryRegion], N'CONSTRAINT', [PK_CountryRegion_CountryRegionCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Person], N'TABLE', [CountryRegion], N'CONSTRAINT', [DF_CountryRegion_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [CountryRegionCurrency], N'CONSTRAINT', [PK_CountryRegionCurrency_CountryRegionCode_CurrencyCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing CountryRegion.CountryRegionCode.', N'SCHEMA', [AW_Sales], N'TABLE', [CountryRegionCurrency], N'CONSTRAINT', [FK_CountryRegionCurrency_CountryRegion_CountryRegionCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Currency.CurrencyCode.', N'SCHEMA', [AW_Sales], N'TABLE', [CountryRegionCurrency], N'CONSTRAINT', [FK_CountryRegionCurrency_Currency_CurrencyCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [CountryRegionCurrency], N'CONSTRAINT', [DF_CountryRegionCurrency_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [CreditCard], N'CONSTRAINT', [PK_CreditCard_CreditCardID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [CreditCard], N'CONSTRAINT', [DF_CreditCard_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [Culture], N'CONSTRAINT', [PK_Culture_CultureID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [Culture], N'CONSTRAINT', [DF_Culture_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [Currency], N'CONSTRAINT', [PK_Currency_CurrencyCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [Currency], N'CONSTRAINT', [DF_Currency_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [CurrencyRate], N'CONSTRAINT', [PK_CurrencyRate_CurrencyRateID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Currency.FromCurrencyCode.', N'SCHEMA', [AW_Sales], N'TABLE', [CurrencyRate], N'CONSTRAINT', [FK_CurrencyRate_Currency_FromCurrencyCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Currency.ToCurrencyCode.', N'SCHEMA', [AW_Sales], N'TABLE', [CurrencyRate], N'CONSTRAINT', [FK_CurrencyRate_Currency_ToCurrencyCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [CurrencyRate], N'CONSTRAINT', [DF_CurrencyRate_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'CONSTRAINT', [PK_Customer_CustomerID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing AW_Person.BusinessEntityID.', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'CONSTRAINT', [FK_Customer_AW_Person_AW_PersonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Store.BusinessEntityID.', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'CONSTRAINT', [FK_Customer_Store_StoreID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing SalesTerritory.TerritoryID.', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'CONSTRAINT', [FK_Customer_SalesTerritory_TerritoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'CONSTRAINT', [DF_Customer_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Sales], N'TABLE', [Customer], N'CONSTRAINT', [DF_Customer_rowguid];
GO

EXEC [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (nonclustered) constraint', N'SCHEMA', [dbo], N'TABLE', [DatabaseLog], N'CONSTRAINT', [PK_DatabaseLog_DatabaseLogID];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_HumanResources], N'TABLE', [Department], N'CONSTRAINT', [PK_Department_DepartmentID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_HumanResources], N'TABLE', [Department], N'CONSTRAINT', [DF_Department_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'CONSTRAINT', [PK_Document_DocumentNode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Employee.BusinessEntityID.', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'CONSTRAINT', [FK_Document_Employee_Owner];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'CONSTRAINT', [DF_Document_ChangeNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'CONSTRAINT', [DF_Document_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [Status] BETWEEN (1) AND (3)', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'CONSTRAINT', [CK_Document_Status];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Production], N'TABLE', [Document], N'CONSTRAINT', [DF_Document_rowguid];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Person], N'TABLE', [EmailAddress], N'CONSTRAINT', [PK_EmailAddress_BusinessEntityID_EmailAddressID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing AW_Person.BusinessEntityID.', N'SCHEMA', [AW_Person], N'TABLE', [EmailAddress], N'CONSTRAINT', [FK_EmailAddress_AW_Person_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Person], N'TABLE', [EmailAddress], N'CONSTRAINT', [DF_EmailAddress_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Person], N'TABLE', [EmailAddress], N'CONSTRAINT', [DF_EmailAddress_rowguid];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'CONSTRAINT', [PK_Employee_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing AW_Person.BusinessEntityID.', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'CONSTRAINT', [FK_Employee_AW_Person_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'CONSTRAINT', [DF_Employee_SickLeaveHours];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'CONSTRAINT', [DF_Employee_VacationHours];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 1 (TRUE)', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'CONSTRAINT', [DF_Employee_SalariedFlag];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 1', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'CONSTRAINT', [DF_Employee_CurrentFlag];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'CONSTRAINT', [DF_Employee_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'CONSTRAINT', [DF_Employee_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [BirthDate] >= ''1930-01-01'' AND [BirthDate] <= dateadd(year,(-18),GETDATE())', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'CONSTRAINT', [CK_Employee_BirthDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [HireDate] >= ''1996-07-01'' AND [HireDate] <= dateadd(day,(1),GETDATE())', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'CONSTRAINT', [CK_Employee_HireDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [SickLeaveHours] >= (0) AND [SickLeaveHours] <= (120)', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'CONSTRAINT', [CK_Employee_SickLeaveHours];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [VacationHours] >= (-40) AND [VacationHours] <= (240)', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'CONSTRAINT', [CK_Employee_VacationHours];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [Gender]=''f'' OR [Gender]=''m'' OR [Gender]=''F'' OR [Gender]=''M''', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'CONSTRAINT', [CK_Employee_Gender];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [MaritalStatus]=''s'' OR [MaritalStatus]=''m'' OR [MaritalStatus]=''S'' OR [MaritalStatus]=''M''', N'SCHEMA', [AW_HumanResources], N'TABLE', [Employee], N'CONSTRAINT', [CK_Employee_MaritalStatus];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeeDepartmentHistory], N'CONSTRAINT', [PK_EmployeeDepartmentHistory_BusinessEntityID_StartDate_DepartmentID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Shift.ShiftID', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeeDepartmentHistory], N'CONSTRAINT', [FK_EmployeeDepartmentHistory_Shift_ShiftID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Department.DepartmentID.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeeDepartmentHistory], N'CONSTRAINT', [FK_EmployeeDepartmentHistory_Department_DepartmentID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Employee.EmployeeID.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeeDepartmentHistory], N'CONSTRAINT', [FK_EmployeeDepartmentHistory_Employee_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeeDepartmentHistory], N'CONSTRAINT', [DF_EmployeeDepartmentHistory_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [EndDate] >= [StartDate] OR [EndDate] IS NUL', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeeDepartmentHistory], N'CONSTRAINT', [CK_EmployeeDepartmentHistory_EndDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeePayHistory], N'CONSTRAINT', [PK_EmployeePayHistory_BusinessEntityID_RateChangeDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Employee.EmployeeID.', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeePayHistory], N'CONSTRAINT', [FK_EmployeePayHistory_Employee_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeePayHistory], N'CONSTRAINT', [DF_EmployeePayHistory_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [Rate] >= (6.50) AND [Rate] <= (200.00)', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeePayHistory], N'CONSTRAINT', [CK_EmployeePayHistory_Rate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [PayFrequency]=(3) OR [PayFrequency]=(2) OR [PayFrequency]=(1)', N'SCHEMA', [AW_HumanResources], N'TABLE', [EmployeePayHistory], N'CONSTRAINT', [CK_EmployeePayHistory_PayFrequency];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [dbo], N'TABLE', [ErrorLog], N'CONSTRAINT', [PK_ErrorLog_ErrorLogID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [dbo], N'TABLE', [ErrorLog], N'CONSTRAINT', [DF_ErrorLog_ErrorTime];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [Illustration], N'CONSTRAINT', [PK_Illustration_IllustrationID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [Illustration], N'CONSTRAINT', [DF_Illustration_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_HumanResources], N'TABLE', [JobCandidate], N'CONSTRAINT', [PK_JobCandidate_JobCandidateID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Employee.EmployeeID.', N'SCHEMA', [AW_HumanResources], N'TABLE', [JobCandidate], N'CONSTRAINT', [FK_JobCandidate_Employee_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_HumanResources], N'TABLE', [JobCandidate], N'CONSTRAINT', [DF_JobCandidate_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [Location], N'CONSTRAINT', [PK_Location_LocationID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.00', N'SCHEMA', [AW_Production], N'TABLE', [Location], N'CONSTRAINT', [DF_Location_Availability];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Production], N'TABLE', [Location], N'CONSTRAINT', [DF_Location_CostRate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [Location], N'CONSTRAINT', [DF_Location_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [Availability] >= (0.00)', N'SCHEMA', [AW_Production], N'TABLE', [Location], N'CONSTRAINT', [CK_Location_Availability];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [CostRate] >= (0.00)', N'SCHEMA', [AW_Production], N'TABLE', [Location], N'CONSTRAINT', [CK_Location_CostRate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Person], N'TABLE', [Password], N'CONSTRAINT', [PK_Password_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing AW_Person.BusinessEntityID.', N'SCHEMA', [AW_Person], N'TABLE', [Password], N'CONSTRAINT', [FK_Password_AW_Person_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Person], N'TABLE', [Password], N'CONSTRAINT', [DF_Password_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Person], N'TABLE', [Password], N'CONSTRAINT', [DF_Password_rowguid];

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'CONSTRAINT', [PK_AW_Person_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing BusinessEntity.BusinessEntityID.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'CONSTRAINT', [FK_AW_Person_BusinessEntity_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'CONSTRAINT', [DF_AW_Person_EmailPromotion];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'CONSTRAINT', [DF_AW_Person_NameStyle];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'CONSTRAINT', [DF_AW_Person_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'CONSTRAINT', [DF_AW_Person_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [EmailPromotion] >= (0) AND [EmailPromotion] <= (2)', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'CONSTRAINT', [CK_AW_Person_EmailPromotion];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [AW_PersonType] is one of SC, VC, IN, EM or SP.', N'SCHEMA', [AW_Person], N'TABLE', [AW_Person], N'CONSTRAINT', [CK_AW_Person_AW_PersonType];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [AW_PersonCreditCard], N'CONSTRAINT', [PK_AW_PersonCreditCard_BusinessEntityID_CreditCardID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing AW_Person.BusinessEntityID.', N'SCHEMA', [AW_Sales], N'TABLE', [AW_PersonCreditCard], N'CONSTRAINT', [FK_AW_PersonCreditCard_AW_Person_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing CreditCard.CreditCardID.', N'SCHEMA', [AW_Sales], N'TABLE', [AW_PersonCreditCard], N'CONSTRAINT', [FK_AW_PersonCreditCard_CreditCard_CreditCardID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [AW_PersonCreditCard], N'CONSTRAINT', [DF_AW_PersonCreditCard_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Person], N'TABLE', [AW_PersonPhone], N'CONSTRAINT', [PK_AW_PersonPhone_BusinessEntityID_PhoneNumber_PhoneNumberTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing AW_Person.BusinessEntityID.', N'SCHEMA', [AW_Person], N'TABLE', [AW_PersonPhone], N'CONSTRAINT', [FK_AW_PersonPhone_AW_Person_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing PhoneNumberType.PhoneNumberTypeID.', N'SCHEMA', [AW_Person], N'TABLE', [AW_PersonPhone], N'CONSTRAINT', [FK_AW_PersonPhone_PhoneNumberType_PhoneNumberTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Person], N'TABLE', [AW_PersonPhone], N'CONSTRAINT', [DF_AW_PersonPhone_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Person], N'TABLE', [PhoneNumberType], N'CONSTRAINT', [PK_PhoneNumberType_PhoneNumberTypeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Person], N'TABLE', [PhoneNumberType], N'CONSTRAINT', [DF_PhoneNumberType_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [PK_Product_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing ProductModel.ProductModelID.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [FK_Product_ProductModel_ProductModelID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing ProductSubcategory.ProductSubcategoryID.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [FK_Product_ProductSubcategory_ProductSubcategoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing UnitMeasure.UnitMeasureCode.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [FK_Product_UnitMeasure_SizeUnitMeasureCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing UnitMeasure.UnitMeasureCode.', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [FK_Product_UnitMeasure_WeightUnitMeasureCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of  1', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [DF_Product_FinishedGoodsFlag];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of  1', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [DF_Product_MakeFlag];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [DF_Product_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [DF_Product_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [DaysToManufacture] >= (0)', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [CK_Product_DaysToManufacture];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [ListPrice] >= (0.00)', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [CK_Product_ListPrice];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [ReorderPoint] > (0)', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [CK_Product_ReorderPoint];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [SafetyStockLevel] > (0)', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [CK_Product_SafetyStockLevel];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [SafetyStockLevel] > (0)', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [CK_Product_StandardCost];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [Weight] > (0.00)', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [CK_Product_Weight];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [Class]=''h'' OR [Class]=''m'' OR [Class]=''l'' OR [Class]=''H'' OR [Class]=''M'' OR [Class]=''L'' OR [Class] IS NULL', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [CK_Product_Class];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [ProductLine]=''r'' OR [ProductLine]=''m'' OR [ProductLine]=''t'' OR [ProductLine]=''s'' OR [ProductLine]=''R'' OR [ProductLine]=''M'' OR [ProductLine]=''T'' OR [ProductLine]=''S'' OR [ProductLine] IS NULL', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [CK_Product_ProductLine];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [SellEndDate] >= [SellStartDate] OR [SellEndDate] IS NULL', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [CK_Product_SellEndDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [Style]=''u'' OR [Style]=''m'' OR [Style]=''w'' OR [Style]=''U'' OR [Style]=''M'' OR [Style]=''W'' OR [Style] IS NULL', N'SCHEMA', [AW_Production], N'TABLE', [Product], N'CONSTRAINT', [CK_Product_Style];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [ProductCategory], N'CONSTRAINT', [PK_ProductCategory_ProductCategoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [ProductCategory], N'CONSTRAINT', [DF_ProductCategory_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()()', N'SCHEMA', [AW_Production], N'TABLE', [ProductCategory], N'CONSTRAINT', [DF_ProductCategory_rowguid];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [ProductCostHistory], N'CONSTRAINT', [PK_ProductCostHistory_ProductID_StartDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductCostHistory], N'CONSTRAINT', [FK_ProductCostHistory_Product_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [ProductCostHistory], N'CONSTRAINT', [DF_ProductCostHistory_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [StandardCost] >= (0.00)', N'SCHEMA', [AW_Production], N'TABLE', [ProductCostHistory], N'CONSTRAINT', [CK_ProductCostHistory_StandardCost];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [EndDate] >= [StartDate] OR [EndDate] IS NULL', N'SCHEMA', [AW_Production], N'TABLE', [ProductCostHistory], N'CONSTRAINT', [CK_ProductCostHistory_EndDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [ProductDescription], N'CONSTRAINT', [PK_ProductDescription_ProductDescriptionID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [ProductDescription], N'CONSTRAINT', [DF_ProductDescription_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Production], N'TABLE', [ProductDescription], N'CONSTRAINT', [DF_ProductDescription_rowguid];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [ProductDocument], N'CONSTRAINT', [PK_ProductDocument_ProductID_DocumentNode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Document.DocumentNode.', N'SCHEMA', [AW_Production], N'TABLE', [ProductDocument], N'CONSTRAINT', [FK_ProductDocument_Document_DocumentNode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductDocument], N'CONSTRAINT', [FK_ProductDocument_Product_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [ProductDocument], N'CONSTRAINT', [DF_ProductDocument_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], N'CONSTRAINT', [PK_ProductInventory_ProductID_LocationID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Location.LocationID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], N'CONSTRAINT', [FK_ProductInventory_Location_LocationID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], N'CONSTRAINT', [FK_ProductInventory_Product_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], N'CONSTRAINT', [DF_ProductInventory_Quantity];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], N'CONSTRAINT', [DF_ProductInventory_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], N'CONSTRAINT', [DF_ProductInventory_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [Bin] BETWEEN (0) AND (100)', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], N'CONSTRAINT', [CK_ProductInventory_Bin];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [Shelf] like ''[A-Za-z]'' OR [Shelf]=''N/A''', N'SCHEMA', [AW_Production], N'TABLE', [ProductInventory], N'CONSTRAINT', [CK_ProductInventory_Shelf];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [ProductListPriceHistory], N'CONSTRAINT', [PK_ProductListPriceHistory_ProductID_StartDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductListPriceHistory], N'CONSTRAINT', [FK_ProductListPriceHistory_Product_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [ProductListPriceHistory], N'CONSTRAINT', [DF_ProductListPriceHistory_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [ListPrice] > (0.00)', N'SCHEMA', [AW_Production], N'TABLE', [ProductListPriceHistory], N'CONSTRAINT', [CK_ProductListPriceHistory_ListPrice];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [EndDate] >= [StartDate] OR [EndDate] IS NULL', N'SCHEMA', [AW_Production], N'TABLE', [ProductListPriceHistory], N'CONSTRAINT', [CK_ProductListPriceHistory_EndDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [ProductModel], N'CONSTRAINT', [PK_ProductModel_ProductModelID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [ProductModel], N'CONSTRAINT', [DF_ProductModel_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Production], N'TABLE', [ProductModel], N'CONSTRAINT', [DF_ProductModel_rowguid];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelIllustration], N'CONSTRAINT', [PK_ProductModelIllustration_ProductModelID_IllustrationID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Illustration.IllustrationID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelIllustration], N'CONSTRAINT', [FK_ProductModelIllustration_Illustration_IllustrationID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing ProductModel.ProductModelID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelIllustration], N'CONSTRAINT', [FK_ProductModelIllustration_ProductModel_ProductModelID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelIllustration], N'CONSTRAINT', [DF_ProductModelIllustration_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelProductDescriptionCulture], N'CONSTRAINT', [PK_ProductModelProductDescriptionCulture_ProductModelID_ProductDescriptionID_CultureID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Culture.CultureID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelProductDescriptionCulture], N'CONSTRAINT', [FK_ProductModelProductDescriptionCulture_Culture_CultureID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing ProductDescription.ProductDescriptionID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelProductDescriptionCulture], N'CONSTRAINT', [FK_ProductModelProductDescriptionCulture_ProductDescription_ProductDescriptionID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing ProductModel.ProductModelID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelProductDescriptionCulture], N'CONSTRAINT', [FK_ProductModelProductDescriptionCulture_ProductModel_ProductModelID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [ProductModelProductDescriptionCulture], N'CONSTRAINT', [DF_ProductModelProductDescriptionCulture_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [ProductPhoto], N'CONSTRAINT', [PK_ProductPhoto_ProductPhotoID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [ProductPhoto], N'CONSTRAINT', [DF_ProductPhoto_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [ProductProductPhoto], N'CONSTRAINT', [PK_ProductProductPhoto_ProductID_ProductPhotoID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductProductPhoto], N'CONSTRAINT', [FK_ProductProductPhoto_Product_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing ProductPhoto.ProductPhotoID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductProductPhoto], N'CONSTRAINT', [FK_ProductProductPhoto_ProductPhoto_ProductPhotoID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0 (FALSE)', N'SCHEMA', [AW_Production], N'TABLE', [ProductProductPhoto], N'CONSTRAINT', [DF_ProductProductPhoto_Primary];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [ProductProductPhoto], N'CONSTRAINT', [DF_ProductProductPhoto_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [ProductReview], N'CONSTRAINT', [PK_ProductReview_ProductReviewID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductReview], N'CONSTRAINT', [FK_ProductReview_Product_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [ProductReview], N'CONSTRAINT', [DF_ProductReview_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [ProductReview], N'CONSTRAINT', [DF_ProductReview_ReviewDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [Rating] BETWEEN (1) AND (5)', N'SCHEMA', [AW_Production], N'TABLE', [ProductReview], N'CONSTRAINT', [CK_ProductReview_Rating];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [ProductSubcategory], N'CONSTRAINT', [PK_ProductSubcategory_ProductSubcategoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing ProductCategory.ProductCategoryID.', N'SCHEMA', [AW_Production], N'TABLE', [ProductSubcategory], N'CONSTRAINT', [FK_ProductSubcategory_ProductCategory_ProductCategoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [ProductSubcategory], N'CONSTRAINT', [DF_ProductSubcategory_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Production], N'TABLE', [ProductSubcategory], N'CONSTRAINT', [DF_ProductSubcategory_rowguid];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'CONSTRAINT', [PK_ProductVendor_ProductID_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'CONSTRAINT', [FK_ProductVendor_Product_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing UnitMeasure.UnitMeasureCode.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'CONSTRAINT', [FK_ProductVendor_UnitMeasure_UnitMeasureCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Vendor.BusinessEntityID.', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'CONSTRAINT', [FK_ProductVendor_Vendor_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'CONSTRAINT', [DF_ProductVendor_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [AverageLeadTime] >= (1)', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'CONSTRAINT', [CK_ProductVendor_AverageLeadTime];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [LastReceiptCost] > (0.00)', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'CONSTRAINT', [CK_ProductVendor_LastReceiptCost];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [MaxOrderQty] >= (1)', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'CONSTRAINT', [CK_ProductVendor_MaxOrderQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [MinOrderQty] >= (1)', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'CONSTRAINT', [CK_ProductVendor_MinOrderQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [OnOrderQty] >= (0)', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'CONSTRAINT', [CK_ProductVendor_OnOrderQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [StandardPrice] > (0.00)', N'SCHEMA', [AW_Purchasing], N'TABLE', [ProductVendor], N'CONSTRAINT', [CK_ProductVendor_StandardPrice];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'CONSTRAINT', [PK_PurchaseOrderDetail_PurchaseOrderID_PurchaseOrderDetailID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'CONSTRAINT', [FK_PurchaseOrderDetail_Product_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing PurchaseOrderHeader.PurchaseOrderID.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'CONSTRAINT', [FK_PurchaseOrderDetail_PurchaseOrderHeader_PurchaseOrderID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'CONSTRAINT', [DF_PurchaseOrderDetail_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [OrderQty] > (0)', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'CONSTRAINT', [CK_PurchaseOrderDetail_OrderQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [ReceivedQty] >= (0.00)', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'CONSTRAINT', [CK_PurchaseOrderDetail_ReceivedQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [RejectedQty] >= (0.00)', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'CONSTRAINT', [CK_PurchaseOrderDetail_RejectedQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [UnitPrice] >= (0.00)', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderDetail], N'CONSTRAINT', [CK_PurchaseOrderDetail_UnitPrice];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'CONSTRAINT', [PK_PurchaseOrderHeader_PurchaseOrderID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Employee.EmployeeID.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'CONSTRAINT', [FK_PurchaseOrderHeader_Employee_EmployeeID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing ShipMethod.ShipMethodID.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'CONSTRAINT', [FK_PurchaseOrderHeader_ShipMethod_ShipMethodID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Vendor.VendorID.', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'CONSTRAINT', [FK_PurchaseOrderHeader_Vendor_VendorID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'CONSTRAINT', [DF_PurchaseOrderHeader_RevisionNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'CONSTRAINT', [DF_PurchaseOrderHeader_Freight];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'CONSTRAINT', [DF_PurchaseOrderHeader_SubTotal];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'CONSTRAINT', [DF_PurchaseOrderHeader_TaxAmt];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 1', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'CONSTRAINT', [DF_PurchaseOrderHeader_Status];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'CONSTRAINT', [DF_PurchaseOrderHeader_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'CONSTRAINT', [DF_PurchaseOrderHeader_OrderDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [Freight] >= (0.00)', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'CONSTRAINT', [CK_PurchaseOrderHeader_Freight];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [SubTotal] >= (0.00)', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'CONSTRAINT', [CK_PurchaseOrderHeader_SubTotal];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [TaxAmt] >= (0.00)', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'CONSTRAINT', [CK_PurchaseOrderHeader_TaxAmt];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [ShipDate] >= [OrderDate] OR [ShipDate] IS NULL', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'CONSTRAINT', [CK_PurchaseOrderHeader_ShipDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [Status] BETWEEN (1) AND (4)', N'SCHEMA', [AW_Purchasing], N'TABLE', [PurchaseOrderHeader], N'CONSTRAINT', [CK_PurchaseOrderHeader_Status];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'CONSTRAINT', [PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing SalesOrderHeader.PurchaseOrderID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'CONSTRAINT', [FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing SpecialOfferProduct.SpecialOfferIDProductID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'CONSTRAINT', [FK_SalesOrderDetail_SpecialOfferProduct_SpecialOfferIDProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'CONSTRAINT', [DF_SalesOrderDetail_UnitPriceDiscount];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'CONSTRAINT', [DF_SalesOrderDetail_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'CONSTRAINT', [DF_SalesOrderDetail_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [OrderQty] > (0)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'CONSTRAINT', [CK_SalesOrderDetail_OrderQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [UnitPrice] >= (0.00)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'CONSTRAINT', [CK_SalesOrderDetail_UnitPrice];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [UnitPriceDiscount] >= (0.00)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderDetail], N'CONSTRAINT', [CK_SalesOrderDetail_UnitPriceDiscount];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [PK_SalesOrderHeader_SalesOrderID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Address.AddressID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [FK_SalesOrderHeader_Address_BillToAddressID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Address.AddressID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [FK_SalesOrderHeader_Address_ShipToAddressID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing CreditCard.CreditCardID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [FK_SalesOrderHeader_CreditCard_CreditCardID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing CurrencyRate.CurrencyRateID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [FK_SalesOrderHeader_CurrencyRate_CurrencyRateID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Customer.CustomerID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [FK_SalesOrderHeader_Customer_CustomerID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing SalesAW_Person.SalesAW_PersonID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [FK_SalesOrderHeader_SalesAW_Person_SalesAW_PersonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing SalesTerritory.TerritoryID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [FK_SalesOrderHeader_SalesTerritory_TerritoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing ShipMethod.ShipMethodID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [FK_SalesOrderHeader_ShipMethod_ShipMethodID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [DF_SalesOrderHeader_RevisionNumber];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [DF_SalesOrderHeader_Freight];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [DF_SalesOrderHeader_SubTotal];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [DF_SalesOrderHeader_TaxAmt];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 1 (TRUE)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [DF_SalesOrderHeader_OnlineOrderFlag];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 1', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [DF_SalesOrderHeader_Status];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [DF_SalesOrderHeader_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [DF_SalesOrderHeader_OrderDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [DF_SalesOrderHeader_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [Freight] >= (0.00)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [CK_SalesOrderHeader_Freight];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [SubTotal] >= (0.00)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [CK_SalesOrderHeader_SubTotal];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [TaxAmt] >= (0.00)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [CK_SalesOrderHeader_TaxAmt];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [DueDate] >= [OrderDate]', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [CK_SalesOrderHeader_DueDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [ShipDate] >= [OrderDate] OR [ShipDate] IS NULL', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [CK_SalesOrderHeader_ShipDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [Status] BETWEEN (0) AND (8)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeader], N'CONSTRAINT', [CK_SalesOrderHeader_Status];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeaderSalesReason], N'CONSTRAINT', [PK_SalesOrderHeaderSalesReason_SalesOrderID_SalesReasonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing SalesOrderHeader.SalesOrderID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeaderSalesReason], N'CONSTRAINT', [FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing SalesReason.SalesReasonID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeaderSalesReason], N'CONSTRAINT', [FK_SalesOrderHeaderSalesReason_SalesReason_SalesReasonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesOrderHeaderSalesReason], N'CONSTRAINT', [DF_SalesOrderHeaderSalesReason_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'CONSTRAINT', [PK_SalesAW_Person_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Employee.EmployeeID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'CONSTRAINT', [FK_SalesAW_Person_Employee_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing SalesTerritory.TerritoryID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'CONSTRAINT', [FK_SalesAW_Person_SalesTerritory_TerritoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'CONSTRAINT', [DF_SalesAW_Person_Bonus];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'CONSTRAINT', [DF_SalesAW_Person_CommissionPct];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'CONSTRAINT', [DF_SalesAW_Person_SalesLastYear];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'CONSTRAINT', [DF_SalesAW_Person_SalesYTD];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'CONSTRAINT', [DF_SalesAW_Person_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'CONSTRAINT', [DF_SalesAW_Person_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [Bonus] >= (0.00)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'CONSTRAINT', [CK_SalesAW_Person_Bonus];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [CommissionPct] >= (0.00)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'CONSTRAINT', [CK_SalesAW_Person_CommissionPct];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [SalesLastYear] >= (0.00)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'CONSTRAINT', [CK_SalesAW_Person_SalesLastYear];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [SalesQuota] > (0.00)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'CONSTRAINT', [CK_SalesAW_Person_SalesQuota];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [SalesYTD] >= (0.00)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_Person], N'CONSTRAINT', [CK_SalesAW_Person_SalesYTD];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_PersonQuotaHistory], N'CONSTRAINT', [PK_SalesAW_PersonQuotaHistory_BusinessEntityID_QuotaDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing SalesAW_Person.SalesAW_PersonID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_PersonQuotaHistory], N'CONSTRAINT', [FK_SalesAW_PersonQuotaHistory_SalesAW_Person_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_PersonQuotaHistory], N'CONSTRAINT', [DF_SalesAW_PersonQuotaHistory_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_PersonQuotaHistory], N'CONSTRAINT', [DF_SalesAW_PersonQuotaHistory_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [SalesQuota] > (0.00)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesAW_PersonQuotaHistory], N'CONSTRAINT', [CK_SalesAW_PersonQuotaHistory_SalesQuota];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [SalesReason], N'CONSTRAINT', [PK_SalesReason_SalesReasonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesReason], N'CONSTRAINT', [DF_SalesReason_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], N'CONSTRAINT', [PK_SalesTaxRate_SalesTaxRateID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing StateProvince.StateProvinceID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], N'CONSTRAINT', [FK_SalesTaxRate_StateProvince_StateProvinceID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], N'CONSTRAINT', [DF_SalesTaxRate_TaxRate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], N'CONSTRAINT', [DF_SalesTaxRate_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], N'CONSTRAINT', [DF_SalesTaxRate_rowguid]; 
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [TaxType] BETWEEN (1) AND (3)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTaxRate], N'CONSTRAINT', [CK_SalesTaxRate_TaxType];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'CONSTRAINT', [PK_SalesTerritory_TerritoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'CONSTRAINT', [DF_SalesTerritory_CostLastYear];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'CONSTRAINT', [DF_SalesTerritory_CostYTD];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'CONSTRAINT', [DF_SalesTerritory_SalesLastYear];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'CONSTRAINT', [DF_SalesTerritory_SalesYTD];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'CONSTRAINT', [DF_SalesTerritory_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'CONSTRAINT', [DF_SalesTerritory_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [CostLastYear] >= (0.00)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'CONSTRAINT', [CK_SalesTerritory_CostLastYear];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [CostYTD] >= (0.00)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'CONSTRAINT', [CK_SalesTerritory_CostYTD];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [SalesLastYear] >= (0.00)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'CONSTRAINT', [CK_SalesTerritory_SalesLastYear];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [SalesYTD] >= (0.00)', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'CONSTRAINT', [CK_SalesTerritory_SalesYTD];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing CountryRegion.CountryRegionCode.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritory], N'CONSTRAINT', [FK_SalesTerritory_CountryRegion_CountryRegionCode];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritoryHistory], N'CONSTRAINT', [PK_SalesTerritoryHistory_BusinessEntityID_StartDate_TerritoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing SalesAW_Person.SalesAW_PersonID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritoryHistory], N'CONSTRAINT', [FK_SalesTerritoryHistory_SalesAW_Person_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing SalesTerritory.TerritoryID.', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritoryHistory], N'CONSTRAINT', [FK_SalesTerritoryHistory_SalesTerritory_TerritoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritoryHistory], N'CONSTRAINT', [DF_SalesTerritoryHistory_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritoryHistory], N'CONSTRAINT', [DF_SalesTerritoryHistory_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [EndDate] >= [StartDate] OR [EndDate] IS NULL', N'SCHEMA', [AW_Sales], N'TABLE', [SalesTerritoryHistory], N'CONSTRAINT', [CK_SalesTerritoryHistory_EndDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [ScrapReason], N'CONSTRAINT', [PK_ScrapReason_ScrapReasonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [ScrapReason], N'CONSTRAINT', [DF_ScrapReason_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_HumanResources], N'TABLE', [Shift], N'CONSTRAINT', [PK_Shift_ShiftID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_HumanResources], N'TABLE', [Shift], N'CONSTRAINT', [DF_Shift_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], N'CONSTRAINT', [PK_ShipMethod_ShipMethodID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], N'CONSTRAINT', [DF_ShipMethod_ShipBase];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], N'CONSTRAINT', [DF_ShipMethod_ShipRate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], N'CONSTRAINT', [DF_ShipMethod_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], N'CONSTRAINT', [DF_ShipMethod_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [ShipBase] > (0.00)', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], N'CONSTRAINT', [CK_ShipMethod_ShipBase];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [ShipRate] > (0.00)', N'SCHEMA', [AW_Purchasing], N'TABLE', [ShipMethod], N'CONSTRAINT', [CK_ShipMethod_ShipRate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [ShoppingCartItem], N'CONSTRAINT', [PK_ShoppingCartItem_ShoppingCartItemID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', N'SCHEMA', [AW_Sales], N'TABLE', [ShoppingCartItem], N'CONSTRAINT', [FK_ShoppingCartItem_Product_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 1', N'SCHEMA', [AW_Sales], N'TABLE', [ShoppingCartItem], N'CONSTRAINT', [DF_ShoppingCartItem_Quantity];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [ShoppingCartItem], N'CONSTRAINT', [DF_ShoppingCartItem_DateCreated];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [ShoppingCartItem], N'CONSTRAINT', [DF_ShoppingCartItem_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [Quantity] >= (1)', N'SCHEMA', [AW_Sales], N'TABLE', [ShoppingCartItem], N'CONSTRAINT', [CK_ShoppingCartItem_Quantity];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'CONSTRAINT', [PK_SpecialOffer_SpecialOfferID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'CONSTRAINT', [DF_SpecialOffer_DiscountPct];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0.0', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'CONSTRAINT', [DF_SpecialOffer_MinQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'CONSTRAINT', [DF_SpecialOffer_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'CONSTRAINT', [DF_SpecialOffer_rowguid];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [DiscountPct] >= (0.00)', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'CONSTRAINT', [CK_SpecialOffer_DiscountPct];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [MaxQty] >= (0)', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'CONSTRAINT', [CK_SpecialOffer_MaxQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [MinQty] >= (0)', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'CONSTRAINT', [CK_SpecialOffer_MinQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [EndDate] >= [StartDate]', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOffer], N'CONSTRAINT', [CK_SpecialOffer_EndDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOfferProduct], N'CONSTRAINT', [PK_SpecialOfferProduct_SpecialOfferID_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOfferProduct], N'CONSTRAINT', [FK_SpecialOfferProduct_Product_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing SpecialOffer.SpecialOfferID.', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOfferProduct], N'CONSTRAINT', [FK_SpecialOfferProduct_SpecialOffer_SpecialOfferID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOfferProduct], N'CONSTRAINT', [DF_SpecialOfferProduct_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Sales], N'TABLE', [SpecialOfferProduct], N'CONSTRAINT', [DF_SpecialOfferProduct_rowguid];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'CONSTRAINT', [PK_StateProvince_StateProvinceID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing CountryRegion.CountryRegionCode.', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'CONSTRAINT', [FK_StateProvince_CountryRegion_CountryRegionCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing SalesTerritory.TerritoryID.', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'CONSTRAINT', [FK_StateProvince_SalesTerritory_TerritoryID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 1 (TRUE)', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'CONSTRAINT', [DF_StateProvince_IsOnlyStateProvinceFlag];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'CONSTRAINT', [DF_StateProvince_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Person], N'TABLE', [StateProvince], N'CONSTRAINT', [DF_StateProvince_rowguid];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Sales], N'TABLE', [Store], N'CONSTRAINT', [PK_Store_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing BusinessEntity.BusinessEntityID', N'SCHEMA', [AW_Sales], N'TABLE', [Store], N'CONSTRAINT', [FK_Store_BusinessEntity_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing SalesAW_Person.SalesAW_PersonID', N'SCHEMA', [AW_Sales], N'TABLE', [Store], N'CONSTRAINT', [FK_Store_SalesAW_Person_SalesAW_PersonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Sales], N'TABLE', [Store], N'CONSTRAINT', [DF_Store_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of NEWID()', N'SCHEMA', [AW_Sales], N'TABLE', [Store], N'CONSTRAINT', [DF_Store_rowguid];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'CONSTRAINT', [PK_TransactionHistory_TransactionID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'CONSTRAINT', [FK_TransactionHistory_Product_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'CONSTRAINT', [DF_TransactionHistory_ReferenceOrderLineID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'CONSTRAINT', [DF_TransactionHistory_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'CONSTRAINT', [DF_TransactionHistory_TransactionDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [TransactionType]=''p'' OR [TransactionType]=''s'' OR [TransactionType]=''w'' OR [TransactionType]=''P'' OR [TransactionType]=''S'' OR [TransactionType]=''W'')', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistory], N'CONSTRAINT', [CK_TransactionHistory_TransactionType];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'CONSTRAINT', [PK_TransactionHistoryArchive_TransactionID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 0', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'CONSTRAINT', [DF_TransactionHistoryArchive_ReferenceOrderLineID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'CONSTRAINT', [DF_TransactionHistoryArchive_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'CONSTRAINT', [DF_TransactionHistoryArchive_TransactionDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [TransactionType]=''p'' OR [TransactionType]=''s'' OR [TransactionType]=''w'' OR [TransactionType]=''P'' OR [TransactionType]=''S'' OR [TransactionType]=''W''', N'SCHEMA', [AW_Production], N'TABLE', [TransactionHistoryArchive], N'CONSTRAINT', [CK_TransactionHistoryArchive_TransactionType];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [UnitMeasure], N'CONSTRAINT', [PK_UnitMeasure_UnitMeasureCode];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [UnitMeasure], N'CONSTRAINT', [DF_UnitMeasure_ModifiedDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'CONSTRAINT', [PK_Vendor_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing BusinessEntity.BusinessEntityID', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'CONSTRAINT', [FK_Vendor_BusinessEntity_BusinessEntityID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 1 (TRUE)', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'CONSTRAINT', [DF_Vendor_ActiveFlag];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of 1 (TRUE)', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'CONSTRAINT', [DF_Vendor_PreferredVendorStatus];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'CONSTRAINT', [DF_Vendor_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [CreditRating] BETWEEN (1) AND (5)', N'SCHEMA', [AW_Purchasing], N'TABLE', [Vendor], N'CONSTRAINT', [CK_Vendor_CreditRating];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'CONSTRAINT', [PK_WorkOrder_WorkOrderID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Product.ProductID.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'CONSTRAINT', [FK_WorkOrder_Product_ProductID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing ScrapReason.ScrapReasonID.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'CONSTRAINT', [FK_WorkOrder_ScrapReason_ScrapReasonID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'CONSTRAINT', [DF_WorkOrder_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [OrderQty] > (0)', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'CONSTRAINT', [CK_WorkOrder_OrderQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [ScrappedQty] >= (0)', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'CONSTRAINT', [CK_WorkOrder_ScrappedQty];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [EndDate] >= [StartDate] OR [EndDate] IS NULL', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrder], N'CONSTRAINT', [CK_WorkOrder_EndDate];
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Primary key (clustered) constraint', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'CONSTRAINT', [PK_WorkOrderRouting_WorkOrderID_ProductID_OperationSequence];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing Location.LocationID.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'CONSTRAINT', [FK_WorkOrderRouting_Location_LocationID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Foreign key constraint referencing WorkOrder.WorkOrderID.', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'CONSTRAINT', [FK_WorkOrderRouting_WorkOrder_WorkOrderID];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Default constraint value of GETDATE()', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'CONSTRAINT', [DF_WorkOrderRouting_ModifiedDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [ActualCost] > (0.00)', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'CONSTRAINT', [CK_WorkOrderRouting_ActualCost];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [ActualResourceHrs] >= (0.0000)', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'CONSTRAINT', [CK_WorkOrderRouting_ActualResourceHrs];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [PlannedCost] > (0.00)', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'CONSTRAINT', [CK_WorkOrderRouting_PlannedCost];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [ActualEndDate] >= [ActualStartDate] OR [ActualEndDate] IS NULL OR [ActualStartDate] IS NULL', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'CONSTRAINT', [CK_WorkOrderRouting_ActualEndDate];
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Check constraint [ScheduledEndDate] >= [ScheduledStartDate]', N'SCHEMA', [AW_Production], N'TABLE', [WorkOrderRouting], N'CONSTRAINT', [CK_WorkOrderRouting_ScheduledEndDate];
GO

PRINT '    Functions';
GO

-- Functions
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Scalar function used in the uSalesOrderHeader trigger to set the starting account date.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetAccountingEndDate], NULL, NULL;
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Scalar function used in the uSalesOrderHeader trigger to set the ending account date.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetAccountingStartDate], NULL, NULL;
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Table value function returning the first name, last name, job title and contact type for a given contact.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetContactInformation], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the table value function ufnGetContactInformation. Enter a valid AW_PersonID from the AW_Person.Contact table.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetContactInformation], N'PARAMETER', '@AW_PersonID';
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Scalar function returning the text representation of the Status column in the Document table.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetDocumentStatusText], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the scalar function ufnGetDocumentStatusText. Enter a valid integer.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetDocumentStatusText], N'PARAMETER', '@Status';
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Scalar function returning the dealer price for a given product on a particular order date.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetProductDealerPrice], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the scalar function ufnGetProductDealerPrice. Enter a valid ProductID from the AW_Production.Product table.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetProductDealerPrice], N'PARAMETER', '@ProductID';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the scalar function ufnGetProductDealerPrice. Enter a valid order date.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetProductDealerPrice], N'PARAMETER', '@OrderDate';
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Scalar function returning the list price for a given product on a particular order date.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetProductListPrice], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the scalar function ufnGetProductListPrice. Enter a valid ProductID from the AW_Production.Product table.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetProductListPrice], N'PARAMETER', '@ProductID';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the scalar function ufnGetProductListPrice. Enter a valid order date.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetProductListPrice], N'PARAMETER', '@OrderDate';
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Scalar function returning the standard cost for a given product on a particular order date.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetProductStandardCost], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the scalar function ufnGetProductStandardCost. Enter a valid ProductID from the AW_Production.Product table.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetProductStandardCost], N'PARAMETER', '@ProductID';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the scalar function ufnGetProductStandardCost. Enter a valid order date.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetProductStandardCost], N'PARAMETER', '@OrderDate';
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Scalar function returning the text representation of the Status column in the PurchaseOrderHeader table.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetPurchaseOrderStatusText], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the scalar function ufnGetPurchaseOrdertStatusText. Enter a valid integer.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetPurchaseOrderStatusText], N'PARAMETER', '@Status';
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Scalar function returning the text representation of the Status column in the SalesOrderHeader table.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetSalesOrderStatusText], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the scalar function ufnGetSalesOrderStatusText. Enter a valid integer.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetSalesOrderStatusText], N'PARAMETER', '@Status';
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Scalar function returning the quantity of inventory in LocationID 6 (Miscellaneous Storage)for a specified ProductID.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetStock], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the scalar function ufnGetStock. Enter a valid ProductID from the AW_Production.ProductInventory table.', N'SCHEMA', [dbo], N'FUNCTION', [ufnGetStock], N'PARAMETER', '@ProductID';
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Scalar function used by the AW_Sales.Customer table to help set the account number.', N'SCHEMA', [dbo], N'FUNCTION', [ufnLeadingZeros], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the scalar function ufnLeadingZeros. Enter a valid integer.', N'SCHEMA', [dbo], N'FUNCTION', [ufnLeadingZeros], N'PARAMETER', '@Value';
GO

PRINT '    Stored Procedures';
GO

-- Stored Procedures
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Stored procedure using a recursive query to return a multi-level bill of material for the specified ProductID.', N'SCHEMA', [dbo], N'PROCEDURE', [uspGetBillOfMaterials], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspGetBillOfMaterials. Enter a valid ProductID from the AW_Production.Product table.', N'SCHEMA', [dbo], N'PROCEDURE', [uspGetBillOfMaterials], N'PARAMETER', '@StartProductID';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspGetBillOfMaterials used to eliminate components not used after that date. Enter a valid date.', N'SCHEMA', [dbo], N'PROCEDURE', [uspGetBillOfMaterials], N'PARAMETER', '@CheckDate';
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Stored procedure using a recursive query to return the direct and indirect managers of the specified employee.', N'SCHEMA', [dbo], N'PROCEDURE', [uspGetEmployeeManagers], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspGetEmployeeManagers. Enter a valid BusinessEntityID from the AW_HumanResources.Employee table.', N'SCHEMA', [dbo], N'PROCEDURE', [uspGetEmployeeManagers], N'PARAMETER', '@BusinessEntityID';
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Stored procedure using a recursive query to return the direct and indirect employees of the specified manager.', N'SCHEMA', [dbo], N'PROCEDURE', [uspGetManagerEmployees], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspGetManagerEmployees. Enter a valid BusinessEntityID of the manager from the AW_HumanResources.Employee table.', N'SCHEMA', [dbo], N'PROCEDURE', [uspGetManagerEmployees], N'PARAMETER', '@BusinessEntityID';
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Stored procedure using a recursive query to return all components or assemblies that directly or indirectly use the specified ProductID.', N'SCHEMA', [dbo], N'PROCEDURE', [uspGetWhereUsedProductID], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspGetWhereUsedProductID. Enter a valid ProductID from the AW_Production.Product table.', N'SCHEMA', [dbo], N'PROCEDURE', [uspGetWhereUsedProductID], N'PARAMETER', '@StartProductID';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspGetWhereUsedProductID used to eliminate components not used after that date. Enter a valid date.', N'SCHEMA', [dbo], N'PROCEDURE', [uspGetWhereUsedProductID], N'PARAMETER', '@CheckDate';
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Logs error information in the ErrorLog table about the error that caused execution to jump to the CATCH block of a TRY...CATCH construct. Should be executed from within the scope of a CATCH block otherwise it will return without inserting error information.', N'SCHEMA', [dbo], N'PROCEDURE', [uspLogError], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Output parameter for the stored procedure uspLogError. Contains the ErrorLogID value corresponding to the row inserted by uspLogError in the ErrorLog table.', N'SCHEMA', [dbo], N'PROCEDURE', [uspLogError], N'PARAMETER', '@ErrorLogID';
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Prints error information about the error that caused execution to jump to the CATCH block of a TRY...CATCH construct. Should be executed from within the scope of a CATCH block otherwise it will return without printing any error information.', N'SCHEMA', [dbo], N'PROCEDURE', [uspPrintError], NULL, NULL;
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Updates the Employee table and inserts a new row in the EmployeePayHistory table with the values specified in the input parameters.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeHireInfo], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeHireInfo. Enter a valid BusinessEntityID from the Employee table.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeHireInfo], N'PARAMETER', '@BusinessEntityID';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeHireInfo. Enter a title for the employee.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeHireInfo], N'PARAMETER', '@JobTitle';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeHireInfo. Enter a hire date for the employee.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeHireInfo], N'PARAMETER', '@HireDate';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeHireInfo. Enter the date the rate changed for the employee.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeHireInfo], N'PARAMETER', '@RateChangeDate';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeHireInfo. Enter the new rate for the employee.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeHireInfo], N'PARAMETER', '@Rate';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeHireInfo. Enter the pay frequency for the employee.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeHireInfo], N'PARAMETER', '@PayFrequency';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeHireInfo. Enter the current flag for the employee.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeHireInfo], N'PARAMETER', '@CurrentFlag';
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Updates the Employee table with the values specified in the input parameters for the given BusinessEntityID.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeLogin], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeLogin. Enter a valid EmployeeID from the Employee table.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeLogin], N'PARAMETER', '@BusinessEntityID';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeHireInfo. Enter a valid ManagerID for the employee.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeLogin], N'PARAMETER', '@OrganizationNode';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeHireInfo. Enter a valid login for the employee.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeLogin], N'PARAMETER', '@LoginID';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeHireInfo. Enter a title for the employee.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeLogin], N'PARAMETER', '@JobTitle';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeHireInfo. Enter a hire date for the employee.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeLogin], N'PARAMETER', '@HireDate';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeHireInfo. Enter the current flag for the employee.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeLogin], N'PARAMETER', '@CurrentFlag';
GO

EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Updates the Employee table with the values specified in the input parameters for the given EmployeeID.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeAW_PersonalInfo], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeAW_PersonalInfo. Enter a valid BusinessEntityID from the AW_HumanResources.Employee table.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeAW_PersonalInfo], N'PARAMETER', '@BusinessEntityID';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeHireInfo. Enter a national ID for the employee.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeAW_PersonalInfo], N'PARAMETER', '@NationalIDNumber';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeHireInfo. Enter a birth date for the employee.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeAW_PersonalInfo], N'PARAMETER', '@BirthDate';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeHireInfo. Enter a marital status for the employee.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeAW_PersonalInfo], N'PARAMETER', '@MaritalStatus';
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Input parameter for the stored procedure uspUpdateEmployeeHireInfo. Enter a gender for the employee.', N'SCHEMA', [AW_HumanResources], N'PROCEDURE', [uspUpdateEmployeeAW_PersonalInfo], N'PARAMETER', '@Gender';
GO

PRINT '    XML Schemas';
GO

-- XML Schemas
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Collection of XML schemas for the AdditionalContactInfo column in the AW_Person.Contact table.', N'SCHEMA', [AW_Person], N'XML SCHEMA COLLECTION', [AdditionalContactInfoSchemaCollection], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Collection of XML schemas for the Resume column in the AW_HumanResources.JobCandidate table.', N'SCHEMA', [AW_HumanResources], N'XML SCHEMA COLLECTION', [HRResumeSchemaCollection], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Collection of XML schemas for the Demographics column in the AW_Person.AW_Person table.', N'SCHEMA', [AW_Person], N'XML SCHEMA COLLECTION', [IndividualSurveySchemaCollection], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Collection of XML schemas for the Instructions column in the AW_Production.ProductModel table.', N'SCHEMA', [AW_Production], N'XML SCHEMA COLLECTION', [ManuInstructionsSchemaCollection], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Collection of XML schemas for the CatalogDescription column in the AW_Production.ProductModel table.', N'SCHEMA', [AW_Production], N'XML SCHEMA COLLECTION', [ProductDescriptionSchemaCollection], NULL, NULL;
EXECUTE [sys].[sp_addextendedproperty] N'MS_Description', N'Collection of XML schemas for the Demographics column in the AW_Sales.Store table.', N'SCHEMA', [AW_Sales], N'XML SCHEMA COLLECTION', [StoreSurveySchemaCollection], NULL, NULL;
GO

SET NOCOUNT OFF;
GO


-- ****************************************
-- Drop DDL Trigger for Database
-- ****************************************
PRINT '';
PRINT '*** Disabling DDL Trigger for Database';
GO

DISABLE TRIGGER [ddlDatabaseTriggerLog] 
ON DATABASE;
GO

/*
-- Output database object creation messages
SELECT [PostTime], [DatabaseUser], [Event], [Schema], [Object], [TSQL], [XmlEvent]
FROM [dbo].[DatabaseLog];
*/
GO


USE [master];
GO

PRINT 'Finished - ' + CONVERT(varchar, GETDATE(), 121);
GO


SET NOEXEC OFF

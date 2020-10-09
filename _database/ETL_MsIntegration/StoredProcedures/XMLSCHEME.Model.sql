SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- EXEC XMLSCHEME.[Model]

CREATE   PROCEDURE [XMLSCHEME].[Model]
AS
BEGIN
	

	DECLARE
		@Sql_Statement NVARCHAR(MAX)
	  , @Sql_Message   NVARCHAR(MAX)
	  , @Sql_Parameter NVARCHAR(MAX)
	  , @Sql_Crlf	   NVARCHAR(2) = CHAR(13) + CHAR(10)
	  , @Sql_Tab	   NVARCHAR(1) = CHAR(9)
	  , @Sql_Debug	   BIT		   = 1
	  , @Sql_Execute   BIT		   = 1

	-- Execute a SELECT statement that uses the OPENXML rowset provider.  
	DECLARE
		@RotoId	 VARCHAR(100)
	  , @TableId VARCHAR(100)


	IF NOT EXISTS (
		SELECT 1
		FROM sys.schemas
		WHERE name = 'XMLSCHEME')
	BEGIN
		SET @Sql_Statement = 'CREATE SCHEMA XMLSCHEME'
		EXEC @Sql_Statement
	END


	DROP TABLE IF EXISTS XMLSCHEME.Model

	CREATE TABLE XMLSCHEME.Model (
		ModelID SMALLINT IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , ModelName VARCHAR(100) NOT NULL
	  , ModelVersionMajor INT NOT NULL
	  , ModelVersionMinor INT NOT NULL
	  ,	ModelVersionTick  INT NOT NULL
	  , CreatedDT DATETIME2(7) NOT NULL DEFAULT GETDATE()
	  ,	UpdatedDT DATETIME2(7) NULL 
	  , IsActive BIT DEFAULT 1 
	)

	
	DROP TABLE IF EXISTS XMLSCHEME.ModelElement

	CREATE TABLE XMLSCHEME.ModelElement (
		ModelElementID INT IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , ModelID SMALLINT NOT NULL REFERENCES XMLSCHEME.Model (ModelID)
	  , ElementName VARCHAR(100) NOT NULL
	  , ModelElmentTypeID SMALLINT NOT NULL REFERENCES XMLSCHEME.ModelElementType
	  , ModelElementID_Parent INT NOT NULL
	  , CreatedDT DATETIME2(7) NOT NULL DEFAULT GETDATE()
	  ,	UpdatedDT DATETIME2(7) NULL 
	  , IsActive BIT DEFAULT 1 
	)

	DROP TABLE IF EXISTS XMLSCHEME.ModelElementType

	CREATE TABLE XMLSCHEME.ModelElementType (
		ModelElmentTypeID SMALLINT IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , ModelElmentID INT NOT NULL REFERENCES XMLSCHEME.ModelElement (ModelElementID)
	  , ElementTypeName VARCHAR(100) NOT NULL
	  , CreatedDT DATETIME2(7) NOT NULL DEFAULT GETDATE()
	  ,	UpdatedDT DATETIME2(7) NULL 
	  , IsActive BIT DEFAULT 1 
	)

	DROP TABLE IF EXISTS XMLSCHEME.ModelElementExtract

	CREATE TABLE XMLSCHEME.ModelElementExtract (
		ModelElementExtractID INT IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , ModelElmentID INT NOT NULL REFERENCES XMLSCHEME.ModelElement (ModelElementID)
	  , ExtractName VARCHAR(100) NOT NULL
	  , ExtractPrefix		NVARCHAR(1000)	NULL
	  , ExtractColumnName	NVARCHAR(128)	NULL
	  , ExtractColumnType	NVARCHAR(128)	NULL
	  , ExtractNode			NVARCHAR(1000)	NULL
	  , CreatedDT DATETIME2(7) NOT NULL DEFAULT GETDATE()
	  ,	UpdatedDT DATETIME2(7) NULL 
	  , IsActive BIT DEFAULT 1 
	)

	-- EXTRACT To Table
	-- Extract Fixed Variables

END
GO

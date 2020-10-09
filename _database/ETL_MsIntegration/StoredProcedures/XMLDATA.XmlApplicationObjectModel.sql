SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- EXEC XMLDATA.XmlApplicationObjectModel

CREATE PROCEDURE [XMLDATA].[XmlApplicationObjectModel]
AS
BEGIN
	

	DECLARE
		@sql_Statement NVARCHAR(MAX)
	  , @sql_Message   NVARCHAR(MAX)
	  , @sql_Parameter NVARCHAR(MAX)
	  , @sql_Crlf	   NVARCHAR(2) = CHAR(13) + CHAR(10)
	  , @sql_Tab	   NVARCHAR(1) = CHAR(9)
	  , @sql_Debug	   BIT		   = 1
	  , @sql_Execute   BIT		   = 1


	DECLARE
		@Xmldoc			 XML
	  , @IntDoc			 INT
	  , @Xml_Path		 NVARCHAR(100) = 'C:\Sage 300 2018 AOM\AOM-2018'
	  , @ExtentIon		 NVARCHAR(10)  = '.xml'
	  , @Version		 VARCHAR(30)   = '2018'
	  , @CurrentId		 INT		   = 1
	  , @CurrentFile	 NVARCHAR(512) = ''
	  , @CurrentFileType NVARCHAR(128) = ''
	  , @ApplicationName VARCHAR(100)
	  , @ApplicationPrefix VARCHAR(5) = ''
	  , @ApplicationId	 SMALLINT

	-- Execute a SELECT statement that uses the OPENXML rowset provider.  
	DECLARE
		@RotoId	 VARCHAR(100)
	  , @TableId VARCHAR(100)


	IF NOT EXISTS (
		SELECT 1
		FROM sys.schemas
		WHERE name = 'XMLDATA')
	BEGIN
		SET @sql_Statement = 'CREATE SCHEMA XMLDATA'
		EXEC @sql_Statement
	END


	DROP TABLE IF EXISTS XMLDATA.ApplicationObjectModel

	CREATE TABLE XMLDATA.ApplicationObjectModel (
		ApplicationID SMALLINT IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , Prefix VARCHAR(2) NOT NULL
	  , ApplicationName VARCHAR(100) NOT NULL
	  , ApplicationVersion VARCHAR(10) NOT NULL
	)

	DROP TABLE IF EXISTS XMLDATA.ApplicationView

	CREATE TABLE XMLDATA.ApplicationView (
		ApplicationViewID INT IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , ApplicationID SMALLINT NOT NULL-- REFERENCES XMLDATA.ApplicationObjectModel(ApplicationID)
	  , RotoID VARCHAR(25) NOT NULL
	  , TableCodes VARCHAR(25) NULL
	  , Title VARCHAR(150) NULL
	  , Dll VARCHAR(50) NULL
	--  , Composition VARCHAR(100) NULL
	)

	DROP TABLE IF EXISTS XMLDATA.ApplicationTable

	CREATE TABLE XMLDATA.ApplicationTable (
		ApplicationTableID INT IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , ApplicationID SMALLINT NOT NULL
	  , TableID VARCHAR(25) NOT NULL
	  , Title VARCHAR(150) NULL
	)

	DROP TABLE IF EXISTS XMLDATA.ApplicationObject

	CREATE TABLE XMLDATA.ApplicationObject (
		ApplicationObjectID INT IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , ApplicationID INT NOT NULL
	  , ObjectCode VARCHAR(50) NOT NULL 
	  , Protocol VARCHAR(50) NOT NULL
	)

	-- ATTRIBUTE LEVEL (OBJECT)
	----------------------------------------------------------------------
	DROP TABLE IF EXISTS XMLDATA.ApplicationViewAttribute

	CREATE TABLE XMLDATA.ApplicationViewAttribute (
		ApplicationViewAttributeID INT IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , ApplicationViewID INT NOT NULL
	  , AttributeKey VARCHAR(100) NOT NULL
	  , AttributeValue VARCHAR(50) NULL
	  , AttributeDescription VARCHAR(150) NULL
	)

	DROP TABLE IF EXISTS XMLDATA.[ApplicationTableAttribute]

	CREATE TABLE [XMLDATA].[ApplicationTableAttribute] (
		[ApplicationTableAttributeID] [INT] IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , [ApplicationTableID] [INT] NOT NULL
	  , [AttributeKey] VARCHAR(100) NOT NULL
	  , [AttributeValue] [VARCHAR](50) NULL
	  , [AttributeDescription] [VARCHAR](150) NULL
	)

	
	DROP TABLE IF EXISTS XMLDATA.[ApplicationObjectAttribute]

	CREATE TABLE [XMLDATA].[ApplicationObjectAttribute] (
		[ApplicationObjectAttributeID] [INT] IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , [ApplicationObjectID] [INT] NOT NULL
	  , [AttributeKey] VARCHAR(100) NOT NULL
	  , [AttributeValue] [VARCHAR](50) NULL
	  , [AttributeDescription] [VARCHAR](150) NULL
	)



	-- FIELD LEVEL
	----------------------------------------------------------------------
	-- VIEW KEYS
	DROP TABLE IF EXISTS XMLDATA.ApplicationViewKey

	CREATE TABLE XMLDATA.ApplicationViewKey (
		ApplicationViewKeyID INT IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , ApplicationViewID INT NULL
	  , ApplicationID SMALLINT NULL
	  , Title VARCHAR(150) NULL
	  , Fields VARCHAR(150) NULL
	)

	-- VIEW FIELDS
	DROP TABLE IF EXISTS XMLDATA.ApplicationViewField

	CREATE TABLE XMLDATA.ApplicationViewField (
		ApplicationViewFieldID INT IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , ApplicationViewID INT NULL
	  , FieldCode VARCHAR(50) NOT NULL
	  , FieldIndex SMALLINT NOT NULL
	  , FieldType VARCHAR(50) NOT NULL
	  , FieldTitle VARCHAR(150) NULL
	)

	-- TABLE KEYS
	DROP TABLE IF EXISTS XMLDATA.ApplicationTableKey

	CREATE TABLE XMLDATA.ApplicationTableKey (
		ApplicationTableKeyID INT IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , ApplicationTableID INT NULL
	  , Title VARCHAR(150) NULL
	  , Flags VARCHAR(100) NULL
	  , Fields VARCHAR(150) NULL
	)

	-- TABLE FIELDS 
	DROP TABLE IF EXISTS XMLDATA.ApplicationTableField

	CREATE TABLE XMLDATA.ApplicationTableField (
		ApplicationTableFieldID INT IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , ApplicationTableID INT NULL
	  , FieldCode VARCHAR(50) NOT NULL
	  , FieldType VARCHAR(150) NOT NULL
	  , FieldTitle VARCHAR(150) NOT NULL
	)

	-- ATTRIBUTE LEVEL (Field)
	--------------------------------------------------------------------
	DROP TABLE IF EXISTS XMLDATA.ApplicationViewFieldAttribute

	CREATE TABLE XMLDATA.ApplicationViewFieldAttribute (
		ApplicationViewFieldAttributeID INT IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , ApplicationViewFieldID INT NOT NULL
	  , AttributeFieldKey VARCHAR(100) NOT NULL
	  , AttributeFieldValue VARCHAR(50) NULL
	  , AttributeFieldDescription VARCHAR(150) NULL
	)

	DROP TABLE IF EXISTS XMLDATA.[ApplicationTableFieldAttribute]

	CREATE TABLE [XMLDATA].[ApplicationTableFieldAttribute] (
		[ApplicationTableFieldAttributeID] [INT] IDENTITY (1, 1) NOT NULL PRIMARY KEY
	  , [ApplicationTableFieldID] [INT] NOT NULL
	  , [AttributeFieldKey] VARCHAR(100) NOT NULL
	  , [AttributeFieldValue] [VARCHAR](50) NULL
	  , [AttributeFieldDescription] [VARCHAR](150) NULL
	)

	--Xp_dirtree has three parameters: 
	--directory – This is the directory you pass when you call the stored procedure; for example ‘D:Backup’.
	--depth  – This tells the stored procedure how many subfolder levels to display.  The default of 0 will display all subfolders.
	--file – This will either display files as well as each folder.  The default of 0 will not display any files.


	DROP TABLE IF EXISTS ##DirectoryTree

	CREATE TABLE ##DirectoryTree (
		[ID] INT IDENTITY (1, 1)
	  , [Directory] NVARCHAR(512) NULL
	  , [FileName] NVARCHAR(512) NULL
	  ,	[FilePath] AS [Directory] + '\' + [FileName]
	  , [Depth] INT NULL
	  , [IsFile] BIT NULL
	  , [FileType] VARCHAR(50) NULL
	  , [Version] VARCHAR(50) NULL
	  , [IsImported] BIT NULL
	  , [ImportLoadDT] DATETIME2(7) NULL
	  
	)

	
	-- Gets all the files to import
	INSERT INTO ##DirectoryTree (
		[FileName]
	  , [Depth]
	  , [IsFile]
	)
	EXEC master.sys.xp_dirtree @Xml_Path, 2, 1

	
	UPDATE
		##DirectoryTree
	SET
		[Directory] = @Xml_Path
	  , [Version] = @Version

	DELETE FROM ##DirectoryTree
	WHERE [FileName] NOT LIKE '%' + @Extention + '%'

	-------- TEST FOR CS
	--DELETE FROM ##DirectoryTree
	--WHERE [FileName] NOT LIKE 'UP%'
	---- AND [FileName]  NOT LIKE 'CS%'
	---- AND [FileName]  NOT LIKE 'AR%'
	---- AND [FileName]  NOT LIKE 'AP%'
	-- AND [FileName] NOT LIKE '%Advantage%'


	-- TEST FOR CS
	--DELETE FROM ##DirectoryTree
	--WHERE [FileType] != 'ApplicationObjectModel'
	--AND [FileType] != 'Application'


	UPDATE
		##DirectoryTree
	SET
		[FileType] = CASE
							  WHEN REPLACE([FileName], @ExtentIon, '') = 'Advantage'
								  THEN
									  'ApplicationObjectModel'
							  WHEN LEN(REPLACE([FileName], @ExtentIon, '')) = 2
								  THEN
									  'Application'
							  WHEN ISNUMERIC(SUBSTRING(REPLACE([FileName], @ExtentIon, ''), 3, 4)) = 1
								  THEN
									  'ApplicationView'
							  ELSE
								  'ApplicationTable'
					END


					
	DROP TABLE IF EXISTS ##ErrorTable

	CREATE TABLE ##ErrorTable(
		[ID] INT IDENTITY (1, 1)
	  , [CurrentID] INT NULL
	  , [FileName] NVARCHAR(512) NULL
	  , [FileType] VARCHAR(100) NULL
	  , [ErrorNumber] INT NULL
	  , [ErrorLine] INT NULL
	  , [ErrorMessage] VARCHAR(4000) NULL
	  , [ErrorDT] DATETIME2(7)
	)



	-- START LOOPING THROUGH THE ITEMS
	WHILE (@CurrentId <= (
		SELECT MAX([ID])
		FROM ##DirectoryTree)
	)
	BEGIN
	BEGIN TRY



		SET @CurrentFile = (
			SELECT [FilePath]
			FROM ##DirectoryTree
			WHERE [ID] = @CurrentId)

		SET @CurrentFileType = (
			SELECT [FileType]
			FROM ##DirectoryTree
			WHERE [ID] = @CurrentId)

		--SELECT @currentID, @currentFile, @currentFile

		SET @sql_Statement = '
			SET @xmldoc = (
			SELECT
				CONVERT(XML, [BulkColumn]) AS [BulkColumn]
			FROM
				OPENROWSET(BULK ''' + @CurrentFile + ''', SINGLE_BLOB) AS x
			)'

		SET @sql_Parameter = '@xmldoc XML OUTPUT'

		IF (@sql_Debug = 1)
		BEGIN
			RAISERROR (@sql_Statement, 0, 1) WITH NOWAIT
		END

		IF (@sql_Execute = 1)
		BEGIN
			EXEC sp_executesql @Stmt = @sql_Statement
							 , @ParAm = @sql_Parameter
							 , @Xmldoc = @Xmldoc OUTPUT
		END


		-- SELECT statement that uses the OPENXML rowset provider.  
		EXEC sp_xml_preparedocument @IntDoc OUTPUT
								  , @Xmldoc

		IF (@CurrentFileType = 'ApplicationObjectModel')
		BEGIN

			INSERT INTO XMLDATA.ApplicationObjectModel (
				Prefix
			  , ApplicationName
			  , ApplicationVersion
			)
			SELECT  DISTINCT 
				LTRIM(RTRIM([Prefix]))
			,	LTRIM(RTRIM([ApplicationName]))
			,	@Version
			FROM
			OPENXML(
				@IntDoc, '/page/pagebody/aom/applicationlist/application', 1
			)
			WITH (
				[Prefix] VARCHAR(10) '@prefix'
			,	[ApplicationName] VARCHAR(100) '@name'
			--, [ApplicationVersion] VARCHAR(20) '@version'
			);
		END

		-- APPLICATION
		------------------------------------------------------------------------------------------------
		ELSE IF (@CurrentFileType = 'Application')
		BEGIN

			-- Gets the Application Name
			SELECT @ApplicationPrefix = SUBSTRING(ApplicationPrefix, 1, CHARINDEX(' ', ApplicationPrefix))
			FROM
			OPENXML (
				@IntDoc, '/page/pagehead', 1
			)
			WITH (
				ApplicationPrefix VARCHAR(100) 'keywords'
			)

			SET @ApplicationId = (
				SELECT ApplicationID
				FROM XMLDATA.ApplicationObjectModel
				WHERE [Prefix] = @ApplicationPrefix
			)

			--SELECT @ApplicationId

			-- Application View
			-----------------------------------------------------------------------------------
			INSERT INTO XMLDATA.ApplicationView (
				ApplicationID
			  , RotoID
			  , TableCodes
			  , Title
			  , Dll
			)
			SELECT DISTINCT
				   ApplicationID = @ApplicationId
				 , RotoID = LTRIM(RTRIM(xmlnew.[RotoID]))
				 , TableCodes = LTRIM(RTRIM(xmlnew.[TableCodes]))
				 , Title = LTRIM(RTRIM(xmlnew.[Title]))
				 , Dll = LTRIM(RTRIM(xmlnew.[Dll]))
			FROM
			OPENXML(
				@IntDoc, '/page/pagebody/application/viewlist/view', 1
			) 
			WITH (
				[RotoID] VARCHAR(100) '@name',
				[TableCodes] VARCHAR(100) 'viewtablelist/table/@name',
				[Title] VARCHAR(100) '@desc',
				[Dll] VARCHAR(100) '@dllname'
			) AS xmlnew
			LEFT JOIN  XMLDATA.ApplicationView AS vw
			ON vw.RotoID = xmlnew.RotoID
			WHERE 
				vw.ApplicationViewID IS NULL


			-- View Attributes 
			-----------------------------------
			INSERT INTO [XMLDATA].[ApplicationViewAttribute] (
				[ApplicationViewID]
			  , [AttributeKey]
			  , [AttributeValue]
			  , [AttributeDescription]
			)
			SELECT  DISTINCT 
				[ApplicationViewID]		= XMLDATA.[usp_get_ApplicationViewID](@ApplicationId, [RotoID], @Version)
			,	[AttributeKey]			= 'Compositions'
			,	[AttributeValue]		= LTRIM(RTRIM([name]))
			,	[AttributeDescription]	= LTRIM(RTRIM([desc]))
			FROM
			OPENXML(
				@IntDoc, '/page/pagebody/application/viewlist/view/viewcomplist/viewcomp', 1
			)
			WITH (
				[RotoID] VARCHAR(100)		'../../@name'
			,	[name] VARCHAR(100)			'@name'
			,	[desc] VARCHAR(100)			'@desc'
			)


			-- APPLICATION TABLE
			------------------------------------------------------------------------------------------------
			INSERT INTO XMLDATA.ApplicationTable (
				[ApplicationID]
			  , [TableID]
			  , [Title]
			)
			SELECT DISTINCT 
				[ApplicationID] = @ApplicationId
			,	[TableID]		= LTRIM(RTRIM(xmlnew.[TableID]))
			,	[Title]			= LTRIM(RTRIM(xmlnew.[Title]))
			FROM
			OPENXML(
				@IntDoc, '/page/pagebody/application/tablelist/table', 1
			)
			WITH (
				  [TableID] VARCHAR(10) '@name'
				, [Title] VARCHAR(100) '@desc'
			) AS xmlnew
			LEFT JOIN  
				XMLDATA.ApplicationTable AS tab
				ON tab.[TableID] = xmlnew.[TableID]
			WHERE 
				tab.ApplicationTableID IS NULL

			-- Table Attributes 
			-----------------------------------

			-- APPLICATION OBJECT
			------------------------------------------------------------------------------------------
			INSERT INTO XMLDATA.ApplicationObject (
				ApplicationID
			  , ObjectCode
			  , Protocol
			)
			SELECT DISTINCT 
				   ApplicationID	= @ApplicationId
				 , ObjectCode		= LTRIM(RTRIM(xmlnew.[ObjectCode]))
				 , Protocol			= LTRIM(RTRIM(xmlnew.[Protocol]))
			FROM
			OPENXML(
				@IntDoc, '/page/pagebody/application/objectlist/object/objectviewlist/objectview', 1
			)
			WITH (
					[ObjectCode] VARCHAR(100) '../../@name'
				,	[Protocol] VARCHAR(100) '../../protocolflag/@value'
			) AS xmlnew
			LEFT JOIN  
				XMLDATA.ApplicationObject AS obj
				ON obj.[ObjectCode] = xmlnew.[ObjectCode]
			WHERE 
				obj.ApplicationObjectID IS NULL


			-- Objects Attributes 
			-----------------------------------
			INSERT INTO [XMLDATA].[ApplicationObjectAttribute] (
				[ApplicationObjectID]
	 		  , [AttributeKey]
			  , [AttributeValue]
			  , [AttributeDescription]
			)
			SELECT  DISTINCT 
				[ApplicationObjectID] = XMLDATA.[usp_get_ApplicationObjectID](@ApplicationID, [ObjectCode], @Version)
			,	[AttributeKey] = 'Views'
			,	[AttributeValue] = LTRIM(RTRIM([name]))
			,	[AttributeDescription] = LTRIM(RTRIM([desc]))
			FROM
			OPENXML(
				@IntDoc, '/page/pagebody/application/objectlist/object/objectviewlist/objectview', 1
			)
			WITH (
				[ObjectCode] VARCHAR(100)	'../../@name'
			,	[name] VARCHAR(100)			'@name'
			,	[desc] VARCHAR(100)			'@desc'
			)


			--select XMLDATA.[usp_get_ApplicationObjectID]('UP0128', '2018')


		END

		ELSE IF (@CurrentFileType = 'ApplicationView')
		BEGIN


			-- Gets the View ID
			SELECT @RotoId = [RotoID]
			FROM
			OPENXML(
				@IntDoc, '/page/pagebody/view', 2
			)
			WITH (
					RotoID VARCHAR(100) 'rotoid'
			)

			SET @ApplicationId = (
				SELECT ApplicationID
				FROM XMLDATA.ApplicationObjectModel
				WHERE [Prefix] =  SUBSTRING(@RotoId, 1, 2) 
			)

			-- SELECT THE ELEMENTS OF THE VIEW 
			INSERT INTO XMLDATA.ApplicationViewField (
				[ApplicationViewID]
			  , [FieldCode]
			  , [FieldIndex]
			  , [FieldType]
			  , [FieldTitle]
			)
			SELECT DISTINCT 
				[XMLDATA].[usp_get_ApplicationViewID](@ApplicationId, @RotoId, @Version) AS applicationviewid
			,	LTRIM(RTRIM([FieldName]))
			,	LTRIM(RTRIM([FieldIndex]))
			,	LTRIM(RTRIM([FieldType]))
			,	LTRIM(RTRIM([FieldDescription]))
			FROM
			OPENXML(
				@IntDoc, '/page/pagebody/view/fieldlist/field', 1
			)
			WITH (
				[FieldName]			VARCHAR(100)	'fieldname'
			,	[FieldIndex]		INT				'fieldindex'
			,	[FieldType]			VARCHAR(100)	'fieldtype'
			,	[FieldDescription]	VARCHAR(100)	'fielddesc'
			)

			--SELECT @rotoid, @Version
			-- GETS THE ATTRIBUTES
			-- Wrap in fucntion to return Field ID
			-- IMPORTANT NEED TO CONVERT THE FIELD NAME TO FIELD ID
			INSERT INTO [XMLDATA].[ApplicationViewFieldAttribute] (
				[ApplicationViewFieldID]
			,	[AttributeFieldKey]
			,	[AttributeFieldValue]
			,	[AttributeFieldDescription]
			)
			SELECT  DISTINCT 
				[ApplicationViewFieldID]	= XMLDATA.usp_get_ApplicationViewFieldID(@RotoId, @Version, [FieldIndex])
			,	[AttributeFieldKey]			=  'Attributes' --LTRIM(RTRIM([type]))
			,	[AttributeFieldValue]		= LTRIM(RTRIM([value]))
			,	[AttributeFieldDescription] = LTRIM(RTRIM([desc]))
			FROM
			OPENXML(
				@IntDoc, '/page/pagebody/view/fieldlist/field/attributeflaglist/attributeflag', 1
			)
			WITH (
				[FieldIndex]	INT				'../../fieldindex'
			--,	[type]			VARCHAR(100)	'@type'
			,	[value]			VARCHAR(100)	'@value'
			,	[desc]			VARCHAR(100)	'@desc'
			)


			INSERT INTO [XMLDATA].[ApplicationViewFieldAttribute] (
				[ApplicationViewFieldID]
			  , [AttributeFieldKey]
			  , [AttributeFieldValue]
			  , [AttributeFieldDescription]
			)
			SELECT  DISTINCT 
				[ApplicationViewFieldID]	= XMLDATA.usp_get_ApplicationViewFieldID(@RotoId, @Version, [FieldIndex])
			,	[AttributeFieldKey]			=  'Presentation' --LTRIM(RTRIM([type]))
			,	[AttributeFieldValue]		= LTRIM(RTRIM([value]))
			,	[AttributeFieldDescription] = LTRIM(RTRIM([desc]))
			FROM
			OPENXML (
				@IntDoc, '/page/pagebody/view/fieldlist/field/fieldpresentlist/fieldpresent', 1
			)
			WITH (
				[FieldIndex]	INT				'../../fieldindex'
			--,	[type]			VARCHAR(100)	'@type'
			,	[value]			VARCHAR(100)	'@index'
			,	[desc]			VARCHAR(100)	'@value'
			)

		END

		ELSE IF (@CurrentFileType = 'ApplicationTable')
		BEGIN

			SELECT 
				@TableId = tableid
			FROM
			OPENXML(
				@IntDoc, '/page/pagebody/table', 2
			)
			WITH (
				tableid VARCHAR(100) '@name'
			)

			--SELECT @tableid

			-- SELECT THE ELEMENTS OF THE TABLE 
			INSERT INTO XMLDATA.ApplicationTableField (
				[ApplicationTableID]
			  , [FieldCode]
			  , [FieldType]
			  , [FieldTitle]
			)
			SELECT  DISTINCT 
				[ApplicationTableID] = XMLDATA.usp_get_ApplicationTableID(@TableId, @Version)
			,	[FieldCode]  = LTRIM(RTRIM([FieldName]))
			,	[FieldType]  = LTRIM(RTRIM([FieldType]))
			,	[FieldTitle] = LTRIM(RTRIM([FieldDescription]))
			FROM
			OPENXML(
				@IntDoc, '/page/pagebody/table/fieldlist/field', 1
			)
			WITH (
				[FieldName]			VARCHAR(100) 'fieldname',
				[FieldType]			VARCHAR(100) 'fieldtype',
				[FieldDescription]	VARCHAR(100) 'fielddesc'
			)


			INSERT INTO [XMLDATA].[ApplicationTableFieldAttribute] (
				[ApplicationTableFieldID]
			  , [AttributeFieldKey]
			  , [AttributeFieldValue]
			  , [AttributeFieldDescription]
			)

			SELECT  DISTINCT 
				[ApplicationTableFieldID]	= XMLDATA.usp_get_ApplicationTableFieldID(@TableId, @Version, [FieldName])
			,	[AttributeFieldKey]			= 'Presentation' --LTRIM(RTRIM([type])) -- Presentation
			,	[AttributeFieldValue]		= LTRIM(RTRIM([index]))	
			,	[AttributeFieldDescription] = LTRIM(RTRIM([value]))
			FROM
			OPENXML(
				@IntDoc, '/page/pagebody/table/fieldlist/field/fieldpresentlist/fieldpresent', 1
			)
			WITH (
				[FieldName]		VARCHAR(100)	'../../fieldname'
			--,	[type]			VARCHAR(100)	'@type'
			,	[index]			VARCHAR(100)	'@index'
			,	[value]			VARCHAR(100)	'@value'
			)

		END

		ELSE
		BEGIN
			SET @sql_message = 'UNKNOWN INPUT TYPE FOR ID ' + CONVERT(varchar, @CurrentId) + ' : ' + ISNULL(@CurrentFile, '') + ' (' + ISNULL(@CurrentFileType, '') + ')' 
			RAISERROR(@sql_message, 1, 50001)
		END


		EXEC sp_xml_removedocument @IntDoc

		--IF(@CurrentId = 1)
		--BEGIN
		--	SET @CurrentId = 2480
		--END
		--ELSE
		--BEGIN
			SET @CurrentId += 1
		--END

		UPDATE 
			##DirectoryTree
		SET 
			IsImported = 1
		,	ImportLoadDT = GETDATE()
		WHERE
			ID = @CurrentId

		END TRY
		BEGIN CATCH  

			--SELECT @CurrentId

			--;THROW 

			

			INSERT INTO ##ErrorTable(
				[CurrentID] 
			  , [FileName]
			  , [FileType]
			  , [ErrorNumber]
			  , [ErrorLine]
			  , [ErrorMessage]
			  , [ErrorDT]
			)
			SELECT 
				@CurrentId
			,	@CurrentFile
			,	@CurrentFileType
			,	ERROR_NUMBER()
			,	ERROR_LINE()
			,	ERROR_MESSAGE()
			,	GETDATE()


			UPDATE 
				##DirectoryTree
			SET 
				IsImported = 0
			,	ImportLoadDT = GETDATE()
			WHERE
				ID = @CurrentId

			IF(@CurrentId <> 1)
			BEGIN
				SET @CurrentId += 1
			END
			ELSE
			BEGIN
				SET @CurrentId= (SELECT MIN(Id) FROM ##DirectoryTree WHERE ID <> 1)
			END

		END CATCH

	END



	SELECT * FROM ##ErrorTable

END


GO

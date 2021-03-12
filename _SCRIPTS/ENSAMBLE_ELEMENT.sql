USE [MetricsVault]
GO

/****** Object:  Table [dbo].[Ensamble_Element]    Script Date: 2020/05/24 6:24:51 PM ******/
DROP TABLE [dbo].[Ensamble_Element]
GO

/****** Object:  Table [dbo].[Ensamble_Element]    Script Date: 2020/05/24 6:24:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Ensamble_Element](
	[ElementID] [smallint] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[EnsambleID] [smallint] NOT NULL,
	[ElementTypeID] smallint NOT NULL,
	[ElementServerName] SYSNAME NOT NULL,
	[ElementDatabaseName] SYSNAME NOT NULL,
	[ElementSchemaName] SYSNAME NOT NULL,
	[ElementEntityName] SYSNAME NOT NULL,
	[ElementFullyQualified] AS ISNULL(QUOTENAME([ElementServerName]), QUOTENAME(@@SERVERNAME)) + '.' +
							   ISNULL(QUOTENAME([ElementDatabaseName]), '') + '.' +
							   ISNULL(QUOTENAME([ElementSchemaName]), '') + '.' +
							   ISNULL(QUOTENAME([ElementEntityName]), '') ,
	[CreatedDT] DATETIME2(7) NOT NULL DEFAULT GETDATE(),
	[UpdatedDT] DATETIME2(7) NULL,
	[IsActive] BIT NOT NULL DEFAULT 1
) ON [PRIMARY]
GO

--CREATE UNIQUE NONCLUSTERED INDEX uncix_Ensamble_ElementFullyQualified ON [dbo].[Ensamble_Element] ([ElementFullyQualified])
--INCLUDE ([ElementServerName], [ElementDatabaseName], [ElementSchemaName], [ElementEntiyName])


INSERT INTO [dbo].[Ensamble_Element]([EnsambleID], [ElementTypeID], [ElementServerName],[ElementDatabaseName],[ElementSchemaName],[ElementEntityName])
VALUES 
	(5, 1, @@SERVERNAME, 'DataVault', 'raw','HUB_Terminal')
,	(5, 3, @@SERVERNAME, 'DataVault', 'raw','SAT_Terminal_XT_LVD')

SELECT * FROM [dbo].[Ensamble_Element]


/*
	Written by	: Emile Fraser	
	Date		: 2020-05-20
	Function	: Insert or Updates new Ensamble Elements
*/
CREATE PROCEDURE [dbo].[sp_set_Ensamble_Element]
	@ElementID					SMALLINT	= NULL
,	@EnsambleID					SMALLINT	= NULL
,	@ElementTypeID				SMALLINT	= NULL
,	@ElementServerName			SYSNAME		= @@SERVERNAME
,	@ElementDatabaseName		SYSNAME		= NULL
,	@ElementSchemaName			SYSNAME		= NULL
,	@ElementEntiyName			SYSNAME		= NULL

AS 
BEGIN
	
	-- SET THE DATE TIME FOR THE UPDATE/INSERT
	DECLARE @CurrentDT DATETIME2(7) = GETDATE()

	-- First need to determine if this is an Insert/Update or a "Other"
	-- Check if this is Possibly update?
	IF(@ElementID IS NOT NULL)
	BEGIN
		-- UPDATE 
		IF EXISTS (
					SELECT 
						1
					FROM 
						[dbo].[sp_set_Ensamble_Element]
					WHERE
						ElementID = @ElementID
		)
		BEGIN

			UPDATE 
				[dbo].[Ensamble_Element]
			SET 
				[EnsambleID]			= COALESCE(@EnsambleID, [EnsambleID])
			,	[ElementTypeID]			= COALESCE(@ElementTypeID, [ElementTypeID])
			,	[ElementServerName]		= COALESCE(@ElementServerName, [ElementServerName])
			,	[ElementDatabaseName]	= COALESCE(@ElementDatabaseName, [ElementDatabaseName])
			,	[ElementSchemaName]		= COALESCE(@ElementSchemaName, [ElementSchemaName])
			,	[ElementEntiyName]		= COALESCE(@ElementEntiyName, [ElementEntiyName])
			WHERE
				[ElementID] = @ElementID
				
		END
		ELSE

		-- ERRONEOUS UPDATE attempt (error out without updating)
		BEGIN
			RAISERROR('The ElementID does not exists', 0, 1) WITH NOWAIT
		END
	END
	ELSE

	--INSERT 
	BEGIN
		IF(@EnsambleID IS NULL OR @ElementTypeID IS NULL OR @ElementDatabaseName IS NULL OR @ElementSchemaName IS NULL OR @ElementEntiyName IS NULL)
		-- ERRORNEOUS INSERT ATTEMPT
		BEGIN
			RAISERROR('Plese supply valid values for @EnsambleID, @ElementTypeID, @ElementDatabaseName, @ElementSchemaName and @ElementEntiyName', 0, 1) WITH NOWAIT
		END
		ELSE	
		BEGIN
			INSERT INTO 
				[dbo].[Ensamble_Element] (
					[EnsambleID]
				,	[ElementTypeID]
				,	[ElementServerName]
				,	[ElementDatabaseName]
				,	[ElementSchemaName]
				,	[ElementEntiyName]
			)
			SELECT 
				@EnsambleID
			,	@ElementTypeID
			,	ISNULL(@ElementServerName , @@SERVERNAME) 
			,	@ElementDatabaseName
			,	@ElementSchemaName
			,	@ElementEntiyName
		END
	END

END

	
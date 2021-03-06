USE [MetricsVault]
GO
/****** Object:  StoredProcedure [dbo].[sp_set_Ensamble_JoinType]    Script Date: 2020/06/08 10:18:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Written by	: Emile Fraser	
	Date		: 2020-05-20
	Function	: Personal Crud for inserting new Join Types

	Sample Execution:

	DECLARE
		@JoinTypeID					SMALLINT		= 6				-- Only needed for updates
	,	@JoinTypeCode				NVARCHAR(30)	= 'HUB-SAT'
	,	@JoinTypeDescription		NVARCHAR(100)	= 'Hub to Satellite'
	,	@SourceElementTypeID		SMALLINT		= 1
	,	@TargetElementTypeID		SMALLINT		= 3
	,	@IsActive					BIT				= NULL				-- Only needed for updates

	EXEC [dbo].[sp_set_Ensamble_JoinType]
		@JoinTypeID						= @JoinTypeID
	,	@JoinTypeCode					= @JoinTypeCode
	,	@JoinTypeDescription			= @JoinTypeDescription
	,	@SourceElementTypeID			= @SourceElementTypeID
	,	@TargetElementTypeID			= @TargetElementTypeID
	,	@IsActive						= @IsActive

	******** Bulk Load (ONLY NEEDED ONCE) **************
		DELETE FROM dbo.Ensamble_JoinType
		DBCC CHECKIDENT ('dbo.Ensamble_JoinType', RESEED, 0)
		DBCC CHECKIDENT ('dbo.Ensamble_JoinType', RESEED, 0)

	DECLARE @cursor_load CURSOR
	DECLARE @JoinTypeCode VARCHAR(30), @JoinTypeDescription VARCHAR(100), @SourceElementTypeID SMALLINT, @TargetElementTypeID SMALLINT, @CanSelfTypeJoin BIT
	SET @cursor_load = CURSOR FOR
	SELECT 
		et1.ELementTypeCode + '-' +  et2.ElementTypeCode
	,	et1.ELementTypeName + ' to ' +  et2.ElementTypeName + ' join'
	,	et1.ElementTypeID
	,	et2.ElementTypeID
	,	et1.CanSelfTypeJoin
	FROM 
		dbo.Ensamble_ElementType AS et1 CROSS JOIN dbo.Ensamble_ElementType AS et2

	OPEN @cursor_load
	FETCH NEXT FROM @cursor_load INTO @JoinTypeCode, @JoinTypeDescription, @SourceElementTypeID, @TargetElementTypeID, @CanSelfTypeJoin

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		
		IF((@SourceElementTypeID != @TargetElementTypeID) OR ((@SourceElementTypeID = @TargetElementTypeID) AND (@CanSelfTypeJoin = 1)))
		BEGIN

			EXEC [dbo].[sp_set_Ensamble_JoinType]
					@JoinTypeID						= NULL
				,	@JoinTypeCode					= @JoinTypeCode
				,	@JoinTypeDescription			= @JoinTypeDescription
				,	@SourceElementTypeID			= @SourceElementTypeID
				,	@TargetElementTypeID			= @TargetElementTypeID
				,	@IsActive						= NULL
		END
		
		FETCH NEXT FROM @cursor_load INTO @JoinTypeCode, @JoinTypeDescription, @SourceElementTypeID, @TargetElementTypeID, @CanSelfTypeJoin
	END


*/
ALTER     PROCEDURE [dbo].[sp_set_Ensamble_JoinType]
	@JoinTypeID					SMALLINT		= NULL
,	@JoinTypeCode				NVARCHAR(30)	= NULL
,	@JoinTypeDescription		NVARCHAR(100)	= NULL
,	@SourceElementTypeID		SMALLINT		= NULL
,	@TargetElementTypeID		SMALLINT		= NULL
,	@IsActive					BIT				= NULL
AS 
BEGIN
	
	-- SET THE DATE TIME FOR THE UPDATE/INSERT
	DECLARE @CurrentDT DATETIME2(7) = GETDATE()

	-- If Table totally blank
	IF NOT EXISTS (	
		SELECT * FROM [dbo].[Ensamble_JoinType]
	)
	BEGIN
		-- If nothing in table, automatically do an insert
		GOTO INSERTSTATEMENT

	END
	ELSE
	BEGIN
		-- Check if Parameters are sent in
		IF(@JoinTypeID IS NULL)
		BEGIN
			-- Check if JoinTypeID can be derived from Join Type Code 
			SET @JoinTypeID = (SELECT [JoinTypeID] FROM [dbo].[Ensamble_JoinType] WHERE [JoinTypeCode] = @JoinTypeCode)
			
			-- IF NULL After the check to the UNIQUE Contraint, we are dealing with an Insert
			IF(@JoinTypeID IS NULL)
			BEGIN
				GOTO INSERTSTATEMENT
			END
			
			-- ELSE we will do an update
			ELSE 
			BEGIN
				GOTO UPDATESTATEMENT
			END

		END
		ELSE
		-- We have an JoinTypeID so lets try an Update
		BEGIN
			GOTO UPDATESTATEMENT

		END
	END



INSERTSTATEMENT:
	INSERT INTO 
					[dbo].[Ensamble_JoinType] (
						[JoinTypeCode]
					,	[JoinTypeDescription]
					,	[SourceElementTypeID]
					,	[TargetElementTypeID]
				)
				SELECT 
					@JoinTypeCode
				,	@JoinTypeDescription
				,	@SourceElementTypeID
				,	@TargetElementTypeID

	RETURN 0
	
UPDATESTATEMENT:
			UPDATE 
				[dbo].[Ensamble_JoinType]
			SET 				
				[JoinTypeCode]			= COALESCE(@JoinTypeCode, [JoinTypeCode])
			,	[JoinTypeDescription]	= COALESCE(@JoinTypeDescription, [JoinTypeDescription])
			,	[SourceElementTypeID]	= COALESCE(@SourceElementTypeID, [SourceElementTypeID])
			,	[TargetElementTypeID]	= COALESCE(@TargetElementTypeID, [TargetElementTypeID])
			,	[UpdatedDT]				= @CurrentDT
			,	[IsActive]				= COALESCE(@IsActive, [IsActive])
			WHERE
				[JoinTypeID] = @JoinTypeID

	RETURN 0

END
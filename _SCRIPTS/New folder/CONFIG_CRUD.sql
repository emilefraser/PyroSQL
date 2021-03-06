USE [MetricsVault]
GO
/****** Object:  StoredProcedure [dbo].[sp_set_Ensamble_Element]    Script Date: 2020/05/24 10:48:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Written by	: Emile Fraser	
	Date		: 2020-05-20
	Function	: Insert or Updates new Ensamble Configs

	DECLARE @ElementID SMALLINT = (SELECT ElementID FROM dbo.Ensamble_Element WHERE ElementEntityName = 'HUB_Terminal')
	DECLARE @MetricTypeID SMALLINT = (SELECT MetricTypeID FROM dbo.Ensamble_MetricType WHERE MetricTypeCode = 'RC')
	DECLARE @ScheduleID SMALLINT = (SELECT TimeGrainID FROM dbo.Ensamble_Timegrain WHERE TimeGrainCode = 'ALL')
	DECLARE @TimeGrainID SMALLINT = (SELECT TimeGrainID FROM dbo.Ensamble_Timegrain WHERE TimeGrainCode = 'ALL')
	DECLARE @GroupByFieldName SYSNAME = 'LoadDT'	

	EXEC [dbo].[sp_set_Ensamble_Config] 
		@ConfigID = NULL
	,	@ElementID = @ElementID
	,	@MetricTypeID = @MetricTypeID
	,	@ScheduleID = @ScheduleID
	,	@TimeGrainID = @TimeGrainID
	,	@GroupByFieldName = @GroupByFieldName

*/
CREATE OR ALTER PROCEDURE [dbo].[sp_set_Ensamble_Config]
	@ConfigID					SMALLINT	= NULL
,	@ElementID					SMALLINT	= NULL
,	@MetricTypeID				SMALLINT	= NULL
,	@ScheduleID					SMALLINT	= NULL
,	@TimeGrainID				SMALLINT	= NULL
,	@GroupByFieldName			SYSNAME		= NULL
,	@IsActive					BIT			= NULL
AS 
BEGIN
	
	-- SET THE DATE TIME FOR THE UPDATE/INSERT
	DECLARE @CurrentDT DATETIME2(7) = GETDATE()

	-- First need to determine if this is an Insert/Update or a "Other"
	-- Check if this is Possibly update?
	IF EXISTS (
				SELECT 
					1
				FROM	
					[dbo].[Ensamble_Config]
				WHERE
					ElementID = @ElementID
				AND
					MetricTypeID = @MetricTypeID
				AND 
					ScheduleID = @ScheduleID
				AND
					TimeGrainID = @TimeGrainID
	) OR (
			@ConfigID IS NOT NULL
		AND
			EXISTS (
						SELECT 
							1
						FROM 
							[dbo].[Ensamble_Config]
						WHERE
							ConfigID = @ConfigID
			)
	)
	BEGIN

		UPDATE 
			[dbo].[Ensamble_Config]
		SET 
			[ElementID]				= COALESCE(@ElementID, [ElementID])
		,	[MetricTypeID]			= COALESCE(@MetricTypeID, [MetricTypeID])
		,	[ScheduleID]			= COALESCE(@ScheduleID, [ScheduleID])
		,	[TimeGrainID]			= COALESCE(@TimeGrainID, [TimeGrainID])
		,	[GroupByFieldName]		= COALESCE(@GroupByFieldName, [GroupByFieldName])
		,	[IsActive]				= COALESCE(@IsActive, [IsActive])
		,	[UpdatedDT]				= GETDATE()
		WHERE
			[ConfigID] = @ConfigID

	END
	ELSE

	--INSERT 
	BEGIN
		IF( @ElementID IS NULL OR @MetricTypeID IS NULL OR @ScheduleID IS NULL OR @TimeGrainID IS NULL)
		-- ERRORNEOUS INSERT ATTEMPT
		BEGIN
			RAISERROR('Plese supply valid values for @ElementID, @MetricTypeID, @ScheduleID and @TimeGrainID', 0, 1) WITH NOWAIT
		END
		ELSE	
		BEGIN
			INSERT INTO 
				[dbo].[Ensamble_Config] (
					[ElementID]
				,	[MetricTypeID]
				,	[ScheduleID]
				,	[TimeGrainID]
				,	[GroupByFieldName]
			)
			SELECT 
				@ElementID
			,	@MetricTypeID
			,	@ScheduleID
			,	@TimeGrainID
			,	@GroupByFieldName
		END
	END

END

	

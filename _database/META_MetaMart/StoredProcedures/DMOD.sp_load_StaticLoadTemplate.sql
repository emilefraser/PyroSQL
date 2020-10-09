SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
--===============================================================================================================================
--Stored Proc Template Version Control
--===============================================================================================================================
/*
	--Stored Proc Tempalte Version No.:	| V 1.0
	--Template last update date:			| 2019-04-18
	--Template Load Type Code:			| TODO: (Add LoadTypeCode for reference)
	--Template Load Type:					| Incremental with no history update for staging 
	--Table for this template:			| [StageArea].[XT].[dbo_ClockHistory_KEYS]
	Author:								| Frans Germishuizen
	Stored Proc Create Date:			| 2019-05-06
	Stored Proc Description:			| Stored proc is used to load the static template of the paramatarised load templates into the DMOD.LoadType table
										| This is a developer proc at the moment
										| A developer needs to manually run this proc to inject the script
*/

CREATE PROCEDURE [DMOD].[sp_load_StaticLoadTemplate]
	@LoadTypeID int = NULL
	, @ErrorMessage varchar(1000) OUTPUT
	--Inputs for insert statement
	, @IsMajorVersionUpdate int = 0
	, @LoadTypeCode varchar(50) = NULL
	, @LoadTypeName varchar(50) = NULL
	, @LoadTypeDescription varchar(500) = NULL

AS
/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
--Stored Proc Management
	--===============================================================================================================================
	--Variable workbench
	--===============================================================================================================================
	--Stored Proc Variables

	--Log Variables

	--Testing variables (COMMENT OUT BEFORE ALTERING THE PROC)
	/*
		DECLARE	@LoadTypeID int = NULL
				, @TableName varchar(50) = 'Department'
				, @SourceSystemAbbr varchar(50) = 'XT'
				, @LoadMethodCode varchar(50) = 'stageLoad'
				, @IsMajorVersionUpdate int = 0
				, @ErrorMessage varchar(1000) --OUTPUT
				--Inputs for insert statement
				, @LoadTypeCode varchar(50) = NULL
				, @LoadTypeName varchar(50) = NULL
				, @LoadTypeDescription varchar(500) = NULL
	--*/

/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
BEGIN TRY
	--===============================================================================================================================
	--Copy current load type into version history table if the load type is being updated
	--===============================================================================================================================
	
	IF @LoadTypeID IS NOT NULL
		BEGIN

			EXECUTE [DMOD].[sp_audit_LoadType] @LoadTypeID
		
		END
	
	--===============================================================================================================================
	--Load static template for a load type 
	--===============================================================================================================================
	IF	(select COUNT(1) from DMOD.Stage_StaticLoadTemplate) = 1 -- There must be at least 1 record in the table
		BEGIN
			--======================================================================================================================
			--Select from DMOD.Stage_StaticLoadTemplate and update / insert new static template
			--======================================================================================================================
			
			IF @LoadTypeID IS NULL
				BEGIN --Then INSERT new LoadType Record
					
					--======================================================================================================================
					--INSERT DMOD.LoadType.[LoadScriptTemplate]
					--======================================================================================================================
    
					INSERT INTO [DMOD].[LoadType]
							   ([LoadTypeCode]
							   ,[LoadTypeName]
							   ,[LoadTypeDescription]
							   ,[ParameterisedTemplateScript]
							   ,[StaticTemplateScript]
							   ,[LoadScriptVersionNo]
							   ,[IsStaticTemplateProcessed]
							   ,[CreatedDT]
							   ,[ModifiedDT]
							   ,[IsActive])
					SELECT	TOP 1 @LoadTypeCode
							,@LoadTypeName
							,@LoadTypeDescription
							,[ParameterisedTemplateScript] = NULL
							,[StaticTemplateScript] = SQLTEXT
							,LoadScriptVersionNo = 1
							,IsStaticTemplateProcessed = 0 --Means it has not yet been processed into a ParameterisedTemplateScript
							,CreatedDT = GETDATE()
							,ModifiedDT = NULL
							,IsActive = 1 --TODO: Determine if it should be active yet
					FROM	DMOD.Stage_StaticLoadTemplate

				END
				ELSE
					BEGIN --Else update the record's static tempalte
						
						--======================================================================================================================
						--Update DMOD.LoadType.[LoadScriptTemplate]
						--======================================================================================================================
    
						UPDATE	[DMOD].[LoadType]
						SET		[LoadTypeDescription] = @LoadTypeDescription
								,[StaticTemplateScript] = SQLTEXT
								,[LoadScriptVersionNo] = CASE WHEN @IsMajorVersionUpdate = 0
															THEN LoadScriptVersionNo + 0.1 -- Minor version update
															ELSE LoadScriptVersionNo + 1 --Major version update
														 END
								,IsStaticTemplateProcessed = 0 --Means it has not yet been processed into a ParameterisedTemplateScript
								,[ModifiedDT] = GETDATE()
						FROM	
								(
									SELECT	TOP 1 SQLTEXT 
									FROM	DMOD.Stage_StaticLoadTemplate
								)Stage_StaticLoadTemplate
						where	LoadTypeID = @LoadTypeID
						
					END

			
		END
		ELSE
			BEGIN
				SET @ErrorMessage = 'There is no static templates loaded in DMOD.Stage_StaticLoadTemplate'
			END

END TRY 
BEGIN CATCH

	SET @ErrorMessage = 'A error occured during the import of the static template.' + CHAR(10) + CHAR(13) +
						CONVERT(varchar(max), @@ERROR)

END CATCH

GO

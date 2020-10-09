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
	Stored Proc Description:			| Stored proc is used to keep history of the load type templates 
										| When static or paramatarised code gets update, a history entry will get created
*/

CREATE PROCEDURE [DMOD].[sp_audit_LoadType]
	@LoadTypeID int
AS

/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/
--Stored Proc Management
	--===============================================================================================================================
	--Variable workbench
	--===============================================================================================================================
	--Stored Proc Variables
	
	--Log Variables

	--Testing variables (COMMENT OUT BEFORE ALTERING THE PROC)
	--DECLARE	@LoadTypeID int
/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*/

--===============================================================================================================================
--Copy current load type into version history table if the load type is being updated
--===============================================================================================================================

INSERT INTO [DMOD].[LoadTypeTemplateHistory]
           ([LoadTypeID]
           ,[LoadTypeCode]
           ,[LoadTypeName]
           ,[LoadTypeDescription]
           ,[ParameterisedTemplateScript]
           ,[StaticTemplateScript]
           ,[LoadScriptVersionNo]
           ,[CreatedDT]
           ,[IsActive])
SELECT	[LoadTypeID]
		,[LoadTypeCode]
		,[LoadTypeName]
		,[LoadTypeDescription]
		,[ParameterisedTemplateScript]
		,[StaticTemplateScript]
		,[LoadScriptVersionNo]
		,[CreatedDT] = GETDATE()
		,[IsActive]
FROM	[DMOD].[LoadType]
where	LoadTypeID = @LoadTypeID

GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:      Frans Germishuizen
-- Create Date: 2018-12-13
-- Description: Create a HUB modelling object in the working tables based on a stagearea tables
-- Tables:		[DMOD].[Hub_Working]
--				[DMOD].[HubBusinessKey_Working]
-- =============================================

-- Sample execution: exec DMOD.sp_working_create_Hub 2281,'Hub_Department',22593, 1

CREATE PROCEDURE [DMOD].[sp_working_create_Hub]
	@DataEntityID int
	, @HubName varchar(150)
	, @FieldID int --used to create the HUB BK entry in the [DMOD].[HubBusinessKey_Working] table
	, @SessionID int
AS
	
	--======================================================================================================================
	--Variable declerations
	Declare @CheckExists_Hub int
			, @CheckExists_HubBK int
			, @HubID int

		--------------------------------------------------------------------------------------------------------------------
		/*
		-- Testing variables (comment out after use and testing)
		declare @DataEntityID int
		, @HubName varchar(150)
		, @FieldID int --used to create the HUB BK entry in the [DMOD].[HubBusinessKey_Working] table
		, @SessionID int

		set		@DataEntityID = 2281 --Stage Area dbo_DEPARTMENT
		set		@HubName = 'HUB_Department'
		set		@FieldID = 22593 --DPT_CODE from stagearea table dbo_DEPARTMENT
		set		@SessionID = 1
		------------------------------------------------------------------------------------------------------------------*/
	--======================================================================================================================
	
	--======================================================================================================================
	--Select parameters into a temp table
	--======================================================================================================================
	select	@DataEntityID AS DataEntityID
			, @HubName AS HubName
			, @FieldID AS FieldID
			, @SessionID AS SessionID
	into	#Hub
	--======================================================================================================================
	--Check if the Hub entry exists for this session
	--======================================================================================================================
	select	@CheckExists_Hub = COUNT(1)
	from	DMOD.Hub_Working whub
	where	EXISTS 
					(
						select	*
						from	#Hub hub
						where	whub.DataEntityID = hub.DataEntityID --TODO: Discuss if this should rather be an OR, because 2 HUB's with the same name should not exist
							and whub.HubName = hub.HubName
							and whub.SessionID = hub.SessionID
					)
	--======================================================================================================================
	--Check if the Hub BK entry exists for this session
	--======================================================================================================================
	select	@CheckExists_HubBK = COUNT(1)
	from	[DMOD].Hub_Working whub
		inner join [DMOD].[HubBusinessKey_Working] whubbk on whub.HubID = whubbk.HubID
	where	EXISTS 
					(
						select	*
						from	#Hub hub
						where	whub.DataEntityID = hub.DataEntityID --TODO: Discuss if this should rather be an OR, because 2 HUB's with the same name should not exist
							and whub.HubName = hub.HubName
							and whubbk.SessionID = hub.SessionID
							and whubbk.FieldID = hub.FieldID
					)
	
	--======================================================================================================================
	--If no entries exists, add entry to tables, else give error messages
	--======================================================================================================================
	
	IF (@CheckExists_Hub = 0 and @CheckExists_HubBK = 0)
		BEGIN
			--------------------------------------------
			--Insert Hub entry
			--------------------------------------------
			INSERT INTO [DMOD].[Hub_Working]
			   ([DataEntityID]
			   ,[HubName]
			   ,[SessionID])
			select	DataEntityID
					, HubName
					, SessionID
			from	#Hub

			--------------------------------------------
			--Get HubID for BK Link entry
			--------------------------------------------
			select	@HubID = HubID
			from	[DMOD].[Hub_Working]
			where	DataEntityID = @DataEntityID
				and HubName = @HubName
				and SessionID = @SessionID
			
			--------------------------------------------
			--Insert Hub BK entry
			--------------------------------------------
			INSERT INTO [DMOD].[HubBusinessKey_Working]
				([HubID]
				,[FieldID]
				,[SessionID])
			select	@HubID
					, FieldID
					, SessionID
			from	#Hub
		END
		ELSE IF (@CheckExists_Hub > 0)
			PRINT 'The Hub and Hub BK key specified already exists for this session'
		ELSE IF (@CheckExists_Hub > 0)
			PRINT 'The Hub already exists for this session'
		ELSE IF (@CheckExists_HubBK > 0)
			PRINT 'The Hub Business Key specified already exists for this session and Hub'

	--======================================================================================================================
	--Garbage Cleanup
	--======================================================================================================================
	drop table #Hub

GO

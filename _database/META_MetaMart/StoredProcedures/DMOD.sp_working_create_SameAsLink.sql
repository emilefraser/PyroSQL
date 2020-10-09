SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:      Frans Germishuizen
-- Create Date: 2018-12-19
-- Description: Create a Same-As-Link modelling object in the working tables based on a stagearea tables
-- Tables:		[DMOD].[Hub_Working]
--				[DMOD].[SameAsLink_Working]
-- =============================================

-- Sample execution: exec DMOD.sp_working_create_Hub 2281,'Hub_Department',22593, 1

CREATE PROCEDURE [DMOD].[sp_working_create_SameAsLink]
	@HubID int
	, @SameAsLinkName varchar(150)
	, @SessionID int
AS
	
	--======================================================================================================================
	--Variable declerations
	Declare @CheckExists_SameAsLink int

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
	select	@HubID AS HubID
			, @SameAsLinkName AS SameAsLinkName
			, @SessionID AS SessionID
	into	#SameAsLinkName
	--======================================================================================================================
	--Check if the Hub entry exists for this session
	--======================================================================================================================
	select	@CheckExists_SameAsLink = COUNT(1)
	from	DMOD.SameAsLink_Working wsal
	where	EXISTS 
					(
						select	*
						from	#SameAsLinkName sal
						where	wsal.HubID = sal.HubID --TODO: Discuss if this should rather be an OR, because 2 HUB's with the same name should not exist
							and wsal.SameAsLinkName = sal.SameAsLinkName
							and wsal.SessionID = sal.SessionID
					)
	
	--======================================================================================================================
	--If no entries exists, add entry to tables, else give error messages
	--======================================================================================================================
	
	IF (@CheckExists_SameAsLink = 0)
		BEGIN
			--------------------------------------------
			--Insert Hub entry
			--------------------------------------------
			INSERT INTO [DMOD].[SameAsLink_Working]
			   ([SameAsLinkName]
			   ,[HubID]
			   ,[SessionID])
			select	[SameAsLinkName]
					,[HubID]
					,[SessionID]
			from	#SameAsLinkName

		END
		ELSE IF (@CheckExists_SameAsLink > 0)
			PRINT 'The Hub already has a same as link specified'

	--======================================================================================================================
	--Garbage Cleanup
	--======================================================================================================================
	drop table #SameAsLinkName

GO

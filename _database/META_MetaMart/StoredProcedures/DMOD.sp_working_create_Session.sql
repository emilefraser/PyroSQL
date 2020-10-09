SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Frans Germishuizen
-- Create Date: 2018-12-13
-- Description: Check if a session exists for a user, if not, load the tables with DC information as at that time
-- Tables:		[DMOD].[DataEntity_Working]
--				[DMOD].[Field_Working]
--				[DMOD].[FieldRelation_Working]
--				[DMOD].[FieldTypeField_Working]
-- =============================================

-- Sample execution:


CREATE PROCEDURE [DMOD].[sp_working_create_Session]
	@Username varchar(100)
AS
BEGIN
	
	--======================================================================================================================
	--Variable declerations
	Declare @CheckExists_Session_Active int
			, @CheckExists_Session_NotActive int
			, @NewSessionID int

		--------------------------------------------------------------------------------------------------------------------
		/*
		-- Testing variables (comment out after use and testing)
		declare @Username varchar(100)

		set		@Username = SUSER_NAME() --Stage Area dbo_DEPARTMENT
		
		------------------------------------------------------------------------------------------------------------------*/
	--======================================================================================================================

	--======================================================================================================================
	--Check if an active session exists for a user
	--======================================================================================================================

	select	@CheckExists_Session_Active = COUNT(1)
	from	DMOD.WorkingSession
	where	SessionUsername = @Username
		and IsDeleted = 0 -- Not deleted
		and SessionState = 1 --Active

	--======================================================================================================================
	--Check if an in-active session exists for a user
	--======================================================================================================================

	select	@CheckExists_Session_NotActive = COUNT(1)
	from	DMOD.WorkingSession
	where	SessionUsername = @Username
		and IsDeleted = 0 -- Not deleted
		and SessionState = 0 --Not Active

	--======================================================================================================================
	--If no entries exists, add entry to tables, else give error messages
	--======================================================================================================================
	
	IF (@CheckExists_Session_Active = 0 and @CheckExists_Session_NotActive = 0)
		BEGIN
			--------------------------------------------
			--Insert Session entry
			--------------------------------------------
			INSERT INTO [DMOD].[WorkingSession]
					   ([SessionUsername]
					   ,[SessionState]
					   ,[IsDeleted]
					   ,[CreatedDT])
			select	@Username
					, 1 --Active
					, 0 --Not Deleted
					, GETDATE() --CreatedDT

			select	@NewSessionID = @@IDENTITY
			from	DMOD.WorkingSession
			where	SessionID = @@IDENTITY

			--------------------------------------------
			--Load DC working DMOD tables for this session id
			--------------------------------------------
			--Load [DMOD].[DataEntity_Working]
			exec DMOD.sp_working_load_DataEntity_Working @NewSessionID

			--Load [DMOD].[Field_Working]
			exec DMOD.sp_working_load_Field_Working @NewSessionID

			--Load [DMOD].[FieldRelation_Working]
			exec DMOD.sp_working_load_FieldRelation_Working @NewSessionID
			
			--Load [DMOD].[FieldTypeField_Working]
			exec DMOD.sp_working_load_FieldTypeField_Working @NewSessionID


		END
		ELSE IF (@CheckExists_Session_Active > 0)
			PRINT 'A session for this user already exists that is active, would you like to resume this session?'
		ELSE IF (@CheckExists_Session_NotActive > 0)
			PRINT 'A session for this user already exists that is in-active, would you like to resume this session?'
		
END

GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [APP].[sp_CRUD_Reporting_Hierarchy_User_Access](

--all table fields, remove the ones you dont need
@IsDefaultHierarchyItem bit,
--fields required from other tables
@ReportingHierarchyItemID int, -- primary key for reporting hierarchy item table
 --required params, please do not remove
@TransactionAction nvarchar(20) = null, -- type of transaction, "Assign", "UnAssign"
@PersonAccessControlListIDsString nvarchar(max) -- multiple ids received for assign/unassign
)

AS

BEGIN

DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction
DECLARE @JSONData varchar(max) = null -- to store in audit table

DECLARE @PrimaryKeyID int = null -- primary key value for the table

DECLARE @TableName VARCHAR(50) = 'ACCESS.[ReportingHierarchyUserAccess' -- table name
DECLARE @TransactionPerson varchar(100)
DECLARE @MasterEntity varchar(50) 
--DECLARE @IsDefaultHierarchyItem bit = 1
--DECLARE @ReportingHierarchyItemID int = 1854
--DECLARE @TransactionAction nvarchar(20) = null
--DECLARE @PersonAccessControlListIDsString nvarchar(max) = '1838,1111,'
--TODO + all comments
--DECLARE @EmployeePositionID int

----test for link
--IF (not exists(SELECT EmployeePositionID FROM [ACCESS].[ReportPosition] WHERE ReportPositionID = @ReportPositionID))
--	BEGIN
--		--insert link record
--		INSERT INTO [ACCESS].[ReportPosition] (EmployeePositionID,NonEmployeeReportUserID, CreatedDT)
--		VALUES (@EmployeePositionID,@NonEmployeeReportUserID, @TransactionDT)

--		SET @ReportPositionID = @@IDENTITY -- get link id to insert into LinkBKCombination
--	END
--ELSE
--	BEGIN
--	--get reportpositionid of existing link
--		SET @ReportPositionID = (SELECT ReportPositionID FROM [ACCESS].[ReportPosition] WHERE ReportPositionID = @ReportPositionID)
--	END
--Assign record
		--REPORT USER DETAILS
		--get employee details for id string supplied
		DECLARE @TempRHUserAccessTable Table
		(
			[ReportingHierarchyItemID] int,
			[PersonAccessControlListID] int,
			[IsDefaultHierarchyItem] bit
		)

		--split employee id's and insert into table with other parameters
			INSERT INTO @TempRHUserAccessTable (PersonAccessControlListID,ReportingHierarchyItemID, IsDefaultHierarchyItem)
			SELECT value, --value is the split up employee id's
			@ReportingHierarchyItemID, --the node to which to assign to
			@IsDefaultHierarchyItem --default or aux role
			FROM  DC.tvf_Split_StringWithDelimiter(@PersonAccessControlListIDsString, ',') -- call split function


	DELETE FROM @TempRHUserAccessTable
		WHERE PersonAccessControlListID = 0 

			--testing
			--select * from @TempRHUserAccessTable

IF @TransactionAction = 'Assign'
	BEGIN

		--get report id for supplied employee id as per supplied string 
		DECLARE @NewRHUToLink Table
		(
			[ReportingHierarchyItemID] int,
			[PersonAccessControlListID] int,
			[IsDefaultHierarchyItem] bit
		)
	
		--get report user values, inserts into seperate table first
		INSERT INTO @NewRHUToLink (PersonAccessControlListID,ReportingHierarchyItemID,IsDefaultHierarchyItem)
		SELECT RHU.PersonAccessControlListID,
			   RHU.ReportingHierarchyItemID,
			   RHU.IsDefaultHierarchyItem
			   FROM @TempRHUserAccessTable RHU

		WHERE NOT EXISTS (SELECT * FROM [ACCESS].[ReportingHierarchyUserAccess] ARHU
						 WHERE
						 RHU.PersonAccessControlListID = ARHU.PersonAccessControlListID
						 AND
						 RHU.ReportingHierarchyItemID =  ARHU.ReportingHierarchyItemID
						 AND
						 RHU.IsDefaultHierarchyItem = ARHU.IsDefaultHierarchyItem
						 )
--testing				
--SELECT * FROM @NewRHUToLink

	  INSERT INTO [ACCESS].[ReportingHierarchyUserAccess]
	  (ReportingHierarchyItemID,PersonAccessControlListID,IsDefaultHierarchyItem,CreatedDT,IsActive)
	  SELECT ReportingHierarchyItemID,PersonAccessControlListID,IsDefaultHierarchyItem,@TransactionDT,1
	  FROM @NewRHUToLink
								
	  DECLARE @UpdateRHUToLink Table
	  (
		ReportingHierarchyUserAccessID int,
		ReportingHierarchyItemID int,
		PersonAccessControlListID int,
		IsDefaultHierarchyItem bit
	  )					

	INSERT INTO @UpdateRHUToLink(
			ReportingHierarchyUserAccessID,		
			ReportingHierarchyItemID,
			PersonAccessControlListID,
			IsDefaultHierarchyItem
			)
							
	SELECT  RHU.ReportingHierarchyUserAccessID,		
			RHU.ReportingHierarchyItemID,
			RHU.PersonAccessControlListID,
			RHU.IsDefaultHierarchyItem
	FROM [ACCESS].[ReportingHierarchyUserAccess] RHU
	WHERE EXISTS(SELECT * FROM @TempRHUserAccessTable TRHU
	WHERE TRHU.PersonAccessControlListID = RHU.PersonAccessControlListID
	AND TRHU.ReportingHierarchyItemID = RHU.ReportingHierarchyItemID
	AND TRHU.IsDefaultHierarchyItem = RHU.IsDefaultHierarchyItem)
	AND RHU.IsActive = 0


	--testing
	--select * from @UpdateRHUToLink

	UPDATE [ACCESS].[ReportingHierarchyUserAccess] 
	SET IsActive = 1,
	UpdatedDT = @TransactionDT
	FROM @UpdateRHUToLink URHU
	LEFT JOIN [ACCESS].[ReportingHierarchyUserAccess] RHU 
	on
	URHU.ReportingHierarchyUserAccessID = RHU.ReportingHierarchyUserAccessID

END

   if @TransactionAction = 'UnAssign'
Begin 

DECLARE @RHUAToUnAssign Table
(
	ReportingHierarchyUserAccessID int,
		ReportingHierarchyItemID int,
		PersonAccessControlListID int,
		IsDefaultHierarchyItem bit
)

INSERT INTO @RHUAToUnAssign 
(ReportingHierarchyUserAccessID,ReportingHierarchyItemID,PersonAccessControlListID,IsDefaultHierarchyItem)

SELECT RHU.ReportingHierarchyUserAccessID,
	   RHU.ReportingHierarchyItemID,
	   RHU.PersonAccessControlListID,
	   RHU.IsDefaultHierarchyItem
 FROM [ACCESS].[ReportingHierarchyUserAccess] RHU
 WHERE EXISTS (SELECT * FROM @TempRHUserAccessTable TRHUA
 WHERE RHU.ReportingHierarchyItemID = TRHUA.ReportingHierarchyItemID
AND RHU.PersonAccessControlListID = TRHUA.PersonAccessControlListID
AND RHU.IsDefaultHierarchyItem = TRHUA.IsDefaultHierarchyItem)
AND IsActive = 1

--testing
--select * from @RHUAToUnAssign

UPDATE [ACCESS].[ReportingHierarchyUserAccess] 
SET IsActive = 0,
UpdatedDT = @TransactionDT
FROM @RHUAToUnAssign RHUA
LEFT JOIN [ACCESS].[ReportingHierarchyUserAccess] RHU
On RHUA.ReportingHierarchyUserAccessID = RHU.ReportingHierarchyUserAccessID
AND RHUA.PersonAccessControlListID = RHU.PersonAccessControlListID
AND RHU.ReportingHierarchyItemID = RHUA.ReportingHierarchyItemID

END

--capture json data (get primary key value to store in audit table)

--TODO: Check audit information required
--SET @JSONData = 
--(SELECT 
--	PCL.[FirstName],
--	PCL.[Surname],
--	RHI.[ItemCode],
--	RHI.[ItemName],
--	RHI.[ReportingHierarchySortOrder],
--	PCL.[Department],
--	RHA.CreatedDT,
--	RHA.UpdatedDT,
--	RHA.IsActive

--FROM [ACCESS].[ReportingHierarchyUserAccess] RHA
--LEFT JOIN [ACCESS].[vw_mat_PersonAccessControlList] PCL
--ON RHA.[PersonAccessControlListID] = PCL.[PersonAccessControlListID]
--LEFT JOIN [MASTER].[ReportingHierarchyItem] RHI
--ON RHI.[ReportingHierarchyItemID] = RHA.[ReportingHierarchyItemID]
--FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )
--		--call sp to store json audit data in table

--EXEC [APP].sp_Audit_Trail_Insert @TransactionPerson = @TransactionPerson,
--@TransactionAction = @TransactionAction,
--@MasterEntity = @MasterEntity,
--@JSONData = @JSONData,
--@TransactionDT = @TransactionDT,
--@PrimaryKeyID = @PrimaryKeyID,
--@TableName = @TableName
END
			--SELECT OCP.PersonEmployeeID, --employee id's selected 
			--OCP.OrgChartPositionID --corresponding position ids ofr employee
			--FROM [GOV].[OrgChartPosition] OCP--links employee id to employee position
			--inner join [ACCESS].[PersonAccessControlList] PAC --gives employee position and returns report position
			--on OCP.OrgChartPositionID = PAC.OrgChartPositionID --matching columns from both tables
			--inner join @TempRHUserAccessTable UAT -- get only the report id's for the selected employees
		 --   on 
			--UAT.PersonEmployeeID = OCP.PersonEmployeeID
			--WHERE
			--UAT.PersonEmployeeID = OCP.PersonEmployeeID

--SELECT * FROM @TempReportUserTable

--		DELETE FROM @TempRHUserAccessTable
--		WHERE PersonEmployeeID = 0 -- split function gives id with 0 which does not exist. removes that id

--		--insert the report position id's found for the corresponding employee id's in to the temp table(merge the 2 tables)
--		UPDATE @TempRHUserAccessTable --main temp table to merge
--			SET TRT.PersonAccessControlListID = TUT.PersonAccessControlListID --set the report user id
--			FROM @TempReportUserTable TUT --2nd temp table to get values from 
--				inner join @TempRHUserAccessTable TRT
--				on TUT.PersonEmployeeID = TRT.PersonEmployeeID

--		--NEW USERS
--		--declare temp table for newly assigned report users
--		DECLARE @TempRHNewUserTable Table
--		(
--			[ReportingHierarchyItemID] int,
--			[PersonAccessControlListID] int,
--			[IsDefaultHierarchyItem] bit,
--			[CreatedDT] datetime2(7),
--			[IsActive] bit
--		)

--		--insert the new users found that do not exist in [ACCESS].[ReportingHierarchyUserAccess] into the temp new user table
--		INSERT INTO @TempRHNewUserTable (ReportingHierarchyItemID, PersonAccessControlListID, IsDefaultHierarchyItem, CreatedDT, IsActive)
--			SELECT rt.ReportingHierarchyItemID, rt.PersonAccessControlListID, rt.IsDefaultHierarchyItem, @TransactionDT, 1
--			FROM @TempRHUserAccessTable rt -- check from all users sent to identiy new ones
--			WHERE not exists (SELECT PersonAccessControlListID FROM [ACCESS].[ReportingHierarchyUserAccess] tt
--								WHERE tt.PersonAccessControlListID = rt.PersonAccessControlListID
--								and tt.ReportingHierarchyItemID = rt.ReportingHierarchyItemID 
--								and tt.IsDefaultHierarchyItem = rt.IsDefaultHierarchyItem)

--		--insert new users found into [ACCESS].[ReportingHierarchyUserAccess]
--		INSERT INTO [ACCESS].[ReportingHierarchyUserAccess] 
--		(ReportingHierarchyItemID, PersonAccessControlListID, IsDefaultHierarchyItem, CreatedDT, IsActive)
--		SELECT ReportingHierarchyItemID, PersonAccessControlListID, IsDefaultHierarchyItem, @TransactionDT, IsActive
--		FROM @TempRHNewUserTable

		
--		--UPDATE USERS
--		--declare temp table for updated users, user already exists in [ACCESS].[ReportingHierarchyUserAccess] but is inactive
--		DECLARE @TempRHUpdateUserTable Table
--		(
--			[ReportingHierarchyUserAccessID] int,
--			[ReportingHierarchyItemID] int,
--			[PersonAccessControlListID] int,
--			[IsDefaultHierarchyItem] bit,
--			[UpdatedDT] datetime2(7),
--			[IsActive] bit
--		)

--		-- insert into update temp table the records in [ACCESS].[ReportingHierarchyUserAccess] where inactive for the node and sent from powerapps
--		INSERT INTO @TempRHUpdateUserTable (ReportingHierarchyUserAccessID, ReportingHierarchyItemID, PersonAccessControlListID, IsDefaultHierarchyItem, UpdatedDT, IsActive)
--			SELECT rt.ReportingHierarchyUserAccessID, rt.ReportingHierarchyItemID, rt.PersonAccessControlListID, rt.IsDefaultHierarchyItem, @TransactionDT, 1
--			FROM [ACCESS].[ReportingHierarchyUserAccess] rt
--			WHERE exists (SELECT PersonAccessControlListID FROM @TempRHUserAccessTable tt
--							WHERE tt.PersonAccessControlListID = rt.PersonAccessControlListID
--							and tt.ReportingHierarchyItemID = rt.ReportingHierarchyItemID 
--							and tt.IsDefaultHierarchyItem = rt.IsDefaultHierarchyItem)
--							and rt.IsActive = 0

--		-- update users in [ACCESS].[ReportingHierarchyUserAccess] set to active
--		UPDATE [ACCESS].[ReportingHierarchyUserAccess]
--			SET IsActive = 1, 
--			UpdatedDT = @TransactionDT
--			FROM @TempRHUpdateUserTable TUA
--				inner join [ACCESS].[ReportingHierarchyUserAccess] rhua
--				on TUA.ReportingHierarchyUserAccessID = rhua.ReportingHierarchyUserAccessID

--END


----UnAssign record
--IF @TransactionAction = 'UnAssign'
--	BEGIN

--	--REPORT USER DETAILS
--	DECLARE @TempRHUserAccessTable1 Table
--	(
--		[ReportingHierarchyItemID] int,
--		[PersonAccessControlListID] int,
--		[IsDefaultHierarchyItem] bit,
--		[CreatedDT] datetime2(7),
--		[UpdatedDT] datetime2(7),
--		[IsActive] bit
--	)


--	--split employee id's and insert into table with other parameters
--	INSERT INTO @TempRHUserAccessTable1 (PersonAccessControlListID, ReportingHierarchyItemID, IsDefaultHierarchyItem)
--		SELECT value, --value is the split up employee id's
--		@ReportingHierarchyItemID, --the node to which to assign to
--		@IsDefaultHierarchyItem --default or aux role
--		FROM  DC.tvf_Split_StringWithDelimiter(@ReportPositionIDsString, ',') -- call split function


--	DELETE FROM @TempRHUserAccessTable1
--	WHERE PersonAccessControlListID = 0 -- split function gives id with 0 which does not exist. removes that id

--	--UPDATE USERS
--	--declare temp table for updated users, user already exists in [ACCESS].[ReportingHierarchyUserAccess] but is inactive
--	DECLARE @TempRHUpdateUserTable1 Table
--	(
--		[ReportingHierarchyUserAccessID] int,
--		[ReportingHierarchyItemID] int,
--		[PersonAccessControlListID] int,
--		[IsDefaultHierarchyItem] bit,
--		[UpdatedDT] datetime2(7),
--		[IsActive] bit
--	)

--	--insert report user details into temp table to set to inactive
--	INSERT INTO @TempRHUpdateUserTable1 (ReportingHierarchyUserAccessID, ReportingHierarchyItemID, PersonAccessControlListID, IsDefaultHierarchyItem, UpdatedDT, IsActive)
--		SELECT rt.ReportingHierarchyUserAccessID, rt.ReportingHierarchyItemID, rt.PersonAccessControlListID, rt.IsDefaultHierarchyItem, @TransactionDT, 0
--		FROM [ACCESS].[ReportingHierarchyUserAccess] rt -- get user details from this table to set inactcive to 0
--		WHERE exists (SELECT PersonAccessControlListID FROM @TempRHUserAccessTable1 tt
--						WHERE tt.PersonAccessControlListID = rt.PersonAccessControlListID
--						and tt.ReportingHierarchyItemID = rt.ReportingHierarchyItemID 
--						and tt.IsDefaultHierarchyItem = rt.IsDefaultHierarchyItem)
--						and rt.IsActive = 1

--	--update [ACCESS].[ReportingHierarchyUserAccess] with unassigned users, set inactive
--	UPDATE [ACCESS].[ReportingHierarchyUserAccess]
--	SET IsActive = 0, 
--	UpdatedDT = @TransactionDT
--	FROM @TempRHUpdateUserTable1 TUA
--		inner join [ACCESS].[ReportingHierarchyUserAccess] rhua
--		on TUA.ReportingHierarchyUserAccessID = rhua.ReportingHierarchyUserAccessID	
	
	
--	END

--END

GO

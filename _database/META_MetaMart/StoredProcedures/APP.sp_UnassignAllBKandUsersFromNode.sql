SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROC [APP].[sp_UnassignAllBKandUsersFromNode](
	@ReportingHierarchyitemID INT,
	@TransactionPerson varchar(80), -- who actioned
	@MasterEntity varchar(50), -- from where actioned
	@TransactionAction nvarchar(20) = null
)
AS 
	BEGIN 
	DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction

	DECLARE @JSONData varchar(max) = null -- to store in audit table

	DECLARE @PrimaryKeyID int = null -- primary key value for the table
    
	DECLARE @IsActive bit  

	DECLARE @Treepath varchar(MAX) = (SELECT Treepath from [MASTER].[vw_BuildTreePathForReportingHierarchyItem] where @ReportingHierarchyItemID = ReportingHierarchyItemID)


	IF @TransactionAction = 'Unassign'

	BEGIN 
	--Declare a temp table to store itemids
	DECLARE @ReportingHierarchyItems TABLE
	(
	ReportingHierarchyitemID int
	)
	
	--insert itemids from treeview
	INSERT INTO @ReportingHierarchyItems(ReportingHierarchyitemID)
	(select reportinghierarchyitemid from [MASTER].[vw_BuildTreePathForReportingHierarchyItem]
	 WHERE Treepath like @Treepath + '%')

	 DECLARE @LinkItems TABLE
	 (
		LinkId INT
	 )
     
	 INSERT INTO @LinkItems(LinkId)
	 (SELECT LinkId FROM [MASTER].[LinkReportingHierarchyItemToBKCombination]
	 WHERE reportinghierarchyitemid in (SELECT * FROM @ReportingHierarchyItems))
	

	 UPDATE [MASTER].[LinkBKCombination]
	 SET 
	 IsActive = 0,
	 UpdatedDT = @TransactionDT
	 WHERE LinkId IN (SELECT LinkId FROM @LinkItems)


	 UPDATE [ACCESS].[ReportingHierarchyUserAccess] 
	 SET 
	 IsActive = 0,
	 UpdatedDT = @TransactionDT
	 WHERE ReportingHierarchyitemID IN (SELECT ReportingHierarchyItemID FROM [MASTER].[vw_BuildTreePathForReportingHierarchyItem] WHERE treepath like @Treepath + '%')

	END
	--test for deployment
END

GO

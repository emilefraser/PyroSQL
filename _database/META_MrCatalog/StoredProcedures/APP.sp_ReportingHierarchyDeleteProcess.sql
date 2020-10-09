SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [APP].[sp_ReportingHierarchyDeleteProcess]
(
@ReportingHierarchyTypeID int
)
AS
BEGIN 
DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction
DECLARE @isActive bit -- indicate soft delete
UPDATE [MASTER].[ReportingHierarchyItem]
SET IsActive = 0, 
UpdatedDT = @TransactionDT
WHERE ReportingHierarchyTypeID = @ReportingHierarchyTypeID
END


GO

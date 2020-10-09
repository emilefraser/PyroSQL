SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author: Wium Swart
-- Create Date: 2019/06/12 
-- Description: This stored proc runs all the stored procs responsible for filling the Role Based Architectures tables in the correct sequence. 
-- =============================================
CREATE PROCEDURE [INTEGRATION].[sp_load_RBA]

AS


EXEC INTEGRATION.sp_load_PersonAndPersonEmployee
EXEC INTEGRATION.sp_load_OrgChartPosition
EXEC INTEGRATION.sp_load_PersonAccessControlList
EXEC INTEGRATION.sp_load_ReportingHierarchyItem
EXEC INTEGRATION.sp_load_ReportingHierarchyUserAccess
EXEC INTEGRATION.sp_load_LinkReportingHierarchyItemToBKCombination
EXEC INTEGRATION.sp_load_LinkBKCombination

GO

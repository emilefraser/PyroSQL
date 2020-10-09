SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [APP].[vw_mat_LinkRoleToModuleAction]
AS
SELECT        LRTMA.LinkRoleToModuleActionID AS [Link Role To Module Action ID], LRTMA.RoleID AS [Role ID], R.RoleCode AS [Role Code], R.RoleDescription AS [Role Description], LRTMA.ModuleActionID AS [Module Action ID], 
                         MA.ActionCode AS [Action Code], MA.ActionDescription AS [Action Description], LRTMA.CreatedDT AS [Created DT], LRTMA.UpdatedDT AS [Updated DT], LRTMA.IsActive AS [Is Active], M.ModuleName AS [Module Name], 
                         M.ModuleDescription AS [Module Description], M.ModuleID AS [Module ID]
FROM            APP.LinkRoleToModuleAction AS LRTMA LEFT OUTER JOIN
                         GOV.Role AS R ON LRTMA.RoleID = R.RoleID LEFT OUTER JOIN
                         APP.ModuleAction AS MA ON LRTMA.ModuleActionID = MA.ModuleActionID LEFT OUTER JOIN
                         APP.Module AS M ON MA.ModuleID = M.ModuleID

GO

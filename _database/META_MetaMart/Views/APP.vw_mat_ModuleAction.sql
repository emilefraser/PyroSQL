SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
Create view  [APP].[vw_mat_ModuleAction] AS Select 
      [ModuleActionID] AS [Module Action ID],
      [ActionCode] AS [Action Code],
      [ActionDescription] AS [Action Description] ,
	  [ModuleID] AS [Module ID],
      [CreatedDT] AS [Created Date],
      [UpdatedDT] AS [Updated Date],
      [IsActive] As [Is Active] 
  FROM [APP].[ModuleAction]

GO

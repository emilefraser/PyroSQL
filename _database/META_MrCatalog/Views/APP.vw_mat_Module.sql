SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
Create view  [APP].[vw_mat_Module] AS Select 
      [ModuleID] AS [Module ID],
      [ModuleName] AS [Module Name],
      [ModuleDescription] AS [Module Description] ,
      [CreatedDT] AS [Created Date],
      [UpdatedDT] AS [Updated Date],
      [IsActive] As [Is Active] 
  FROM [APP].[Module]

GO

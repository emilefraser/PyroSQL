SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
Create view  [GOV].[vw_mat_Role] AS Select 
      [RoleID] AS [Role ID],
      [RoleCode] AS [Role Code],
      [RoleDescription] AS [Role Description] ,
      [CreatedDT] AS [Created Date],
      [UpdatedDT] AS [Updated Date],
      [IsActive] As [Is Active] 
  FROM [GOV].[Role]

GO

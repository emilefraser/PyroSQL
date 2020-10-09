SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [vw_pres_DimBusinessUnit] AS
 SELECT [BusinessUnitKey]
      ,[BusinessUnitName] AS [Business Unit Name]
      ,[Subsidiary]
FROM [DEV_InfoMart].[dbo].[vw_DimBusinessUnit]
GO

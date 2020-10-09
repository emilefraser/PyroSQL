SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [APP].[vw_mat_MenuItem] AS
SELECT mi.[MenuItemID] AS [Menu Item ID]
      ,mi.[MenuItemNavTo] AS [Menu Item Nav To]
      ,mi.[MenuItemParentID] AS [Menu Item Parent ID]
      ,mi.[IsHeaderItem] AS [Is Header Item]
      ,mi.[SortOrder] AS [Sort Order]
      ,mi.[HasChildren] AS [Has Children]
      ,mi.[ModuleID] AS [Module ID]
      ,CASE
	  WHEN mi.[MenuItemName] IS NULL
	  THEN m.ModuleName
	  ELSE mi.[MenuItemName]
	  END AS [Menu Item Name]
      ,mi.[CreatedDT] AS [Created Date]
      ,mi.[UpdatedDT] AS [Updated Date]
      ,mi.[IsActive] AS [Is Active]
	  ,m.ModuleName AS [Module Name]
  FROM APP.MenuItem mi
	   LEFT JOIN APP.Module m ON
			mi.ModuleID = m.ModuleID

GO

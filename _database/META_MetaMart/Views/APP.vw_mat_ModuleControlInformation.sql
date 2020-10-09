SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




CREATE VIEW [APP].[vw_mat_ModuleControlInformation]
AS
Select 
       mci.ModuleControlInformationID AS [Module Control Information ID]
      ,mci.ModuleID AS [Module ID]
	  ,m.ModuleName AS [Module Name]
      ,mci.ControlName As [Control Name]
      ,mci.InformationCode AS [Information Code]
      ,mci.InformationDescription AS [Information Description]
      ,mci.CreatedDT AS [Created Date Time]
      ,mci.UpdatedDT AS [Updated Date Time]
      ,mci.IsActive AS [Is Active]
  FROM [APP].[ModuleControlInformation] mci
  LEFT JOIN APP.Module m
  ON mci.ModuleID = m.ModuleID

GO

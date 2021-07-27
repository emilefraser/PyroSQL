SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [XMLDATA].[vw_Application]
AS
SELECT [Prefix]
      ,[ApplicationName]
      ,[ApplicationVersion]
  FROM 
	[MrIntegration].[XMLDATA].[ApplicationObjectModel]
GO

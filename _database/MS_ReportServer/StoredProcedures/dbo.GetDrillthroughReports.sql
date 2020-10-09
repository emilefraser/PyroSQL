SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetDrillthroughReports]
@ModelID uniqueidentifier,
@ModelItemID nvarchar(425)
AS
 SELECT
 ModelDrill.Type,
 Catalog.Path
 FROM ModelDrill INNER JOIN Catalog ON ModelDrill.ReportID = Catalog.ItemID
 WHERE ModelID = @ModelID
 AND ModelItemID = @ModelItemID
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[GetDrillthroughReport]
@ModelPath nvarchar(425),
@ModelItemID nvarchar(425),
@Type tinyint
AS
 SELECT
 CatRep.Path
 FROM ModelDrill
 INNER JOIN Catalog CatMod ON ModelDrill.ModelID = CatMod.ItemID
 INNER JOIN Catalog CatRep ON ModelDrill.ReportID = CatRep.ItemID
 WHERE CatMod.Path = @ModelPath
 AND ModelItemID = @ModelItemID
 AND ModelDrill.[Type] = @Type
GO

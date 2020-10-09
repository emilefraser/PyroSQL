SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[DeleteModelPerspectives]
@ModelID as uniqueidentifier
AS

DELETE
FROM [ModelPerspective]
WHERE [ModelID] = @ModelID
GO

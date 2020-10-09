SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Republishing generates new ID and stores those in the object model,
-- in order to resolve the data sets we need to rebind the old
-- data set definition to the current ID
CREATE PROCEDURE [dbo].[RebindDataSet]
@ItemId		uniqueidentifier,
@Name		nvarchar(260),
@NewID	uniqueidentifier
AS
UPDATE DataSets
SET ID = @NewID
WHERE ItemID = @ItemId AND [Name] = @Name
GO

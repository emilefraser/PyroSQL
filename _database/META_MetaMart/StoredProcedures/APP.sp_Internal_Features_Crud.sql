SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


  CREATE PROC [APP].[sp_Internal_Features_Crud]
  (
  @FeaturesDescription varchar(225),
  @VersionName varchar(50),
  @TransactionPerson varchar(80),
  @TransactionAction nvarchar(20) = null,
  @VersionID int = null ,
  @ModuleID int = null 
  )

  AS
	BEGIN
	DECLARE @TransactionDT datetime2(7) = getDate() -- date of transaction

	DECLARE @isActive bit -- indicate soft delete

	IF @TransactionAction = 'Feature'

BEGIN 
	IF EXISTS (SELECT 1 FROM [APP].[Addedfeatures] WHERE @FeaturesDescription = FeaturesDescription)
	BEGIN

SELECT 'Already Exist'

END

ELSE

BEGIN
If(@ModuleID = 0)
BEGIN
INSERT INTO [APP].[Addedfeatures]
(FeaturesDescription,CreatedDT,isActive,VersionID)
VALUES
(@FeaturesDescription,@TransactionDT,1,@VersionID)
END
END
END

IF @TransactionAction = 'Version'
BEGIN
	INSERT INTO [APP].[Version]
	(ModuleID,VersionName,CreatedDT,IsActive)
	VALUES
	(@ModuleID,@VersionName,@TransactionDT,1)
	END
END

GO

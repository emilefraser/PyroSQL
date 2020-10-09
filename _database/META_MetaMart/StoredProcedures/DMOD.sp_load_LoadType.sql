SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
Proc for creating new static load type (Keys, HUB, SAT)

EXEC [DMOD].[sp_load_LoadType]
			@LoadTypeCode = 'DataVaultFullLoad_HUB' -- Load Type Code the Static Load Template Built for 
           ,@LoadTypeName  = 'DataVaultFullLoad_HUB' -- Load Type Name the Static Load Template Built for 
           ,@LoadTypeDescription = 'DataVault Full Load of HUB' -- Load Type Description of the Static Load Template
*/

CREATE PROCEDURE [DMOD].[sp_load_LoadType]
	@LoadTypeCode           VARCHAR(50)
  , @LoadTypeName           VARCHAR(50)
  , @LoadTypeDescription    VARCHAR(500)
AS
BEGIN

	DECLARE @CreatedDT DATETIME2(7) =
	(
		SELECT GETDATE()
	)

	DECLARE @IsActive BIT = 1

	INSERT INTO 
	[DMOD].[LoadType]
	(
		   [LoadTypeCode]
		 , [LoadTypeName]
		 , [LoadTypeDescription]
		 , [LoadScriptVersionNo]
		 , [IsStaticTemplateProcessed]
		 , [CreatedDT]
		 , [IsActive]
	)
	VALUES
	(
		   @LoadTypeCode
		 , @LoadTypeName
		 , @LoadTypeDescription
		 , 1
		 , 0
		 , @CreatedDT
		 , @IsActive
	)
END

GO

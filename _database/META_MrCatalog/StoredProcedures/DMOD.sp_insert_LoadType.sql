SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
Proc for creating new static load type (Keys, HUB, SAT)

EXEC [DMOD].[sp_insert_LoadType]
			 @LoadTypeID
		   , @LoadTypeCode = 'DataVaultFullLoad_HUB' -- Load Type Code the Static Load Template Built for 
           , @LoadTypeName  = 'DataVaultFullLoad_HUB' -- Load Type Name the Static Load Template Built for 
           , @LoadTypeDescription = 'DataVault Full Load of HUB' -- Load Type Description of the Static Load Template
		   , @IsActive
*/

--SELECT * FROM DMOD.LoadType

CREATE PROCEDURE [DMOD].[sp_insert_LoadType]
	@LoadTypeID				INT	= NULL
  , @LoadTypeCode           VARCHAR(50) = ''
  , @LoadTypeName           VARCHAR(50) = NULL
  , @LoadTypeDescription    VARCHAR(500) = NULL
  , @IsActive				BIT = 1
AS
BEGIN

	DECLARE @CreatedDT DATETIME2(7)
	DECLARE @ModifiedDT DATETIME2(7)
	

	-- If LoadTypeID IS NOT passed, get the LoadTypeID from the table based on LoadTypeCode
	IF(@LoadTypeID IS NULL)
	BEGIN

		SET @LoadTypeID =
		(
			SELECT 
				lt.LoadTypeID 
			FROM 
				DMOD.LoadType AS lt
			WHERE
				lt.LoadTypeCode = @LoadTypeCode
		)

	END

	
	IF(@LoadTypeID IS NOT NULL) -- If LoadTypeID IS PASSED OR it already EXISTS based on LoadTypeName THEN UPDATE
	BEGIN

		SET @ModifiedDT =
		(
			SELECT GETDATE()
		)

		UPDATE 
			lt
		SET
			lt.LoadTypeCode = COALESCE(@LoadTypeCode, lt.LoadTypeCode)
		,	lt.LoadTypeName = COALESCE(@LoadTypeName, lt.LoadTypeName)
		,	lt.LoadTypeDescription = COALESCE(@LoadTypeDescription, lt.LoadTypeDescription)
		,	lt.ModifiedDT = COALESCE(@ModifiedDT, lt.ModifiedDT)
		,	lt.IsActive = @IsActive
		FROM 
			DMOD.LoadType AS lt
		WHERE
			lt.LoadTypeID = @LoadTypeID

	END
	
	ELSE -- If LoadTypeID IS NOT PASSED AND doesn't EXISTS THEN CREATE
	BEGIN

		SET @CreatedDT =
		(
			SELECT GETDATE()
		)

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

END

GO

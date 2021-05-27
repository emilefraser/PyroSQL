SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TEMPLATE].[TryCatchBlock]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TEMPLATE].[TryCatchBlock] AS' 
END
GO


ALTER   PROCEDURE [TEMPLATE].[TryCatchBlock]
AS 
BEGIN
	SET XACT_ABORT, NOCOUNT ON
	   BEGIN TRY
		  BEGIN TRANSACTION

			DECLARE @a VARCHAR(10) = 'vala'
			DECLARE @b VARCHAR(10) = 'valb'

		  	DROP TABLE IF EXISTS ETL.SampleTable
	
			CREATE TABLE ETL.SampleTable (
				a VARCHAR(10) PRIMARY KEY ,
				b VARCHAR(10)
			)

			INSERT ETL.SampleTable(a,b) VALUES (@a, @b)
			INSERT ETL.SampleTable(a,b) VALUES (@a, @b)

		  COMMIT TRANSACTION
	   END TRY
	   BEGIN CATCH
		  IF @@trancount > 0 ROLLBACK TRANSACTION
		  DECLARE @msg nvarchar(2048) = error_message()  
		  RAISERROR (@msg, 16, 1)
		  RETURN 55555
	   END CATCH


END
GO

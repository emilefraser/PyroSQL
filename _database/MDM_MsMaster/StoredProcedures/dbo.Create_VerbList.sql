SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



/* 
=============================================
? WHO  ? Emile Fraser
=============================================
*/
CREATE     PROCEDURE [UTILITY].[Create_VerbList]
AS
BEGIN

	SET XACT_ABORT, NOCOUNT ON
	   
	BEGIN TRY
		
		BEGIN TRANSACTION

			DROP TABLE IF EXISTS UTILITY.Verb
			DROP TABLE IF EXISTS UTILITY.VerbHistory

			CREATE TABLE UTILITY.Verb (
				VerbID SMALLINT IDENTITY(1,1) NOT NULL,
				VerbCode VARCHAR(30) NOT NULL,
				[StartDT] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
				[EndDT] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
			PRIMARY KEY CLUSTERED 
			(
				VerbID ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
				PERIOD FOR SYSTEM_TIME ([StartDT], [EndDT])
			) ON [PRIMARY] 
			WITH
			(
			SYSTEM_VERSIONING = ON ( HISTORY_TABLE = UTILITY.VerbHistory )
			)


			INSERT INTO UTILITY.Verb (
				VerbCode
			)
			VALUES 
				('Insert')
			,	('Update')
			,	('Delete')
			,	('Truncate')
			,	('Get')
			,	('Calculate')
			,	('Drop')
			,	('Create')
			,	('Modify')
			,	('Alter')
			,	('Purge')
			,	('Schedule')
			,	('Run')
			,	('Upsert')
			,	('Start')
			,	('Encrypt')

		COMMIT TRANSACTION
		
	END TRY
   
	BEGIN CATCH
		
		IF xact_state() > 0 AND @@trancount > 0 
			COMMIT TRANSACTION
		
		ELSE IF xact_state() < 0 AND @@trancount > 0 
			ROLLBACK TRANSACTION
		
		--ELSE
			
		;THROW
		
		DECLARE @ErrorNumber INT = ERROR_NUMBER()
		DECLARE @ErrorLine INT = ERROR_LINE()
		DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
		DECLARE @ErrorState INT = ERROR_STATE()
		DECLARE @sql_clrf NVARCHAR(2) = CHAR(13) + CHAR(10)
 
		DECLARE @sql_message NVARCHAR(MAX) = '###### ERROR ######' + @sql_clrf
		SET @sql_message += 'Actual error number: ' + CAST(@ErrorNumber AS NVARCHAR(10)) + @sql_clrf
		SET @sql_message += 'Actual line number: ' + CAST(@ErrorLine AS NVARCHAR(10)) + @sql_clrf
		 
		RAISERROR(@sql_message, 16, 1) WITH NOWAIT
		
		RETURN 55555
			
	END CATCH

END
GO

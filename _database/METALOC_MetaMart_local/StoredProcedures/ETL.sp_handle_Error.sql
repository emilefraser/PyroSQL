SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [ETL].[sp_handle_Error]
AS
SET NOCOUNT ON;

BEGIN

	DECLARE 
		@ErrorMessage NVARCHAR(2048)
	,	@Severity TINYINT
	,	@State TINYINT
	,	@ErrorNumber INT
	,	@ProcedureName SYSNAME
	,	@LineNumber INT

	SELECT 
		@ErrorMessage = ERROR_MESSAGE()
	,	@Severity = ERROR_SEVERITY()
	,	@State = ERROR_STATE()
	,	@ErrorNumber = ERROR_NUMBER()
	,	@ProcedureName = ERROR_PROCEDURE()
	,	@LineNumber = ERROR_LINE()

	IF @ErrorMessage NOT LIKE '**%'
	BEGIN
		SELECT @ErrorMessage ='*** ' + COALESCE(QUOTENAME(@ProcedureName), '<dynamic SQL>') + CHAR(13) +
								'Line ' + LTRIM(STR(@LineNumber)) + ', Error Number ' + 
								LTRIM(STR(@ErrorNumber)) + ': ' + @ErrorMessage

	END

	RAISERROR('%s', @Severity, @State, @ErrorMessage)

END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[SplitSingleValueIntoRows]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[SplitSingleValueIntoRows] AS' 
END
GO


-- SPLITS a CLOB or single value into rows
-- EXEC [dbo].[SplitSingleValueIntoRows]
ALTER     PROCEDURE [inout].[SplitSingleValueIntoRows]--(
	--  @DatasourceName				NVARCHAR(MAX)
	--, @RelativeFilePath				NVARCHAR(MAX)
	--, @EndOfLineDelimeter			NVARCHAR(2)
	--, @EndOfFieldDelimeter			NVARCHAR(2)
--) 
--RETURNS TABLE
AS
BEGIN
--RETURN

	DECLARE @crlf NVARCHAR(2) = CHAR(13) + CHAR(10)
	declare @RelativeFilePath NVARCHAR(MAX) = 'sample/csv/sample1.csv'
	declare @DatasourceName NVARCHAR(MAX) = 'AcAzDevelopmentSampleDataSource'
	DECLARE @xml XML
	
	SELECT @xml =
		--value 
	--FROM 
		--STRING_SPLIT((
		--		SELECT 
					BulkColumn 
				FROM 
					OPENROWSET (
						BULK '@RelativeFilePath'
					--,	DATA_SOURCE = @DatasourceName
					,	SINGLE_CLOB
					)  AS rowset;
		--	), @crlf)
	--)
	SELECT @xml;

END
GO

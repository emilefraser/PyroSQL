SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROC [APP].[sp_Validate_Dup_Load]
(
	@SourceDataEntityID int,
	@LoadTypeID int
)
AS
BEGIN

DECLARE  @TempTable TABLE
(
SourceDataEntityID int,
LoadTypeID int,
IsActive bit
)

INSERT INTO @TempTable(SourceDataEntityID,LoadTypeID,IsActive)
(SELECT SourceDataEntityID,LoadTypeID,IsActive FROM [DMOD].[LoadConfig])


DECLARE @Response varchar(100)

IF EXISTS (SELECT * FROM @TempTable WHERE SourceDataEntityID = @SourceDataEntityID AND LoadTypeID = @LoadTypeID)
--((SELECT count(*) FROM @TempTable WHERE SourceDataEntityID = @SourceDataEntityID) > 0)
--AND
--((SELECT count(*) FROM @TempTable WHERE LoadTypeID = @LoadTypeID) > 0)

	BEGIN
		--SELECT 'This combination of source and target selections already exist.'
		SET @Response = 'This combination of source and loadtype selections already exist.'
		SELECT @Response
	END
ELSE
	BEGIN
		--SELECT ''
		SET @Response = 'Create Load'
		SELECT @Response
	END
END

GO

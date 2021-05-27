SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[GenerateBcpScript]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[GenerateBcpScript] AS' 
END
GO
/*
{{META>}}
	{Written By}	Emile Fraser
	{CreatedDate}	2021-01-22
	{UpdatedDate}	2021-01-22
	{Description}	Creates BCP Format File

	{Usage>}		
					DECLARE @BcpScriptOutput NVARCHAR(MAX)
					EXEC [inout].[GenerateBcpScript] @BcpScriptOutput = @BcpScriptOutput OUTPUT
	{<Usage}
{{<META}}
*/
ALTER     PROCEDURE [inout].[GenerateBcpScript]
	@BcpScriptOutput NVARCHAR(MAX) OUTPUT
AS
BEGIN


	DECLARE @tableToBCP NVARCHAR(128)   = 'sandbox.dbo.example_table'
		, @Top          VARCHAR(10)     = NULL -- Leave NULL for all rows
		, @Delimiter    VARCHAR(4)      = '|'
		, @UseNULL      BIT             = 1
		, @OverrideChar CHAR(1)         = '~'
		, @MaxDop       CHAR(1)         = '1'
		, @Directory    VARCHAR(256)    = 'D:\dba\mufford\scripts';


	-- Script-defined variables -- 

	DECLARE @columnList TABLE (columnID INT);

	DECLARE @bcpStatement NVARCHAR(MAX) = 'BCP "SELECT '
		, @currentID INT
		, @firstID INT;

	INSERT INTO @columnList
	SELECT column_id 
	FROM sys.columns 
	WHERE object_id = OBJECT_ID(@tableToBCP)
	ORDER BY column_id;

	IF @Top IS NOT NULL
		SET @bcpStatement = @bcpStatement + 'TOP (' + @Top + ') ';

	SELECT @firstID = MIN(columnID) FROM @columnList;

	WHILE EXISTS(SELECT * FROM @columnList)
	BEGIN

		SELECT @currentID = MIN(columnID) FROM @columnList;

		IF @currentID <> @firstID
			SET @bcpStatement = @bcpStatement + ',';

		SELECT @bcpStatement = @bcpStatement + 
								CASE 
									WHEN user_type_id IN (231, 167, 175, 239) 
									THEN 'CASE WHEN ' + name + ' = '''' THEN ' 
										+ CASE 
											WHEN is_nullable = 1 THEN 'NULL' 
											ELSE '''' + REPLICATE(@OverrideChar, max_length) + ''''
										  END
										+ ' WHEN ' + name + ' LIKE ''%' + @Delimiter + '%'''
											+ ' OR ' + name + ' LIKE ''%'' + CHAR(9) + ''%''' -- tab
											+ ' OR ' + name + ' LIKE ''%'' + CHAR(10) + ''%''' -- line feed
											+ ' OR ' + name + ' LIKE ''%'' + CHAR(13) + ''%''' -- carriage return
											+ ' THEN ' 
											+ CASE 
												WHEN is_nullable = 1 THEN 'NULL' 
												ELSE '''' + REPLICATE(@OverrideChar, max_length) + ''''
											  END
										+ ' ELSE ' + name + ' END' 
									ELSE name 
								END 
		FROM sys.columns 
		WHERE object_id = OBJECT_ID(@tableToBCP)
			AND column_id = @currentID;

		DELETE FROM @columnList WHERE columnID = @currentID;


	END;

	SET @bcpStatement = @bcpStatement + ' FROM ' + @tableToBCP 
		+ ' WITH (NOLOCK) OPTION (MAXDOP 1);" queryOut '
		+ @Directory + REPLACE(@tableToBCP, '.', '_') + '.dat -S' + @@SERVERNAME
		+ ' -T -t"' + @Delimiter + '" -c -C;'

	SET @BcpScriptOutput = @bcpStatement;
END
GO

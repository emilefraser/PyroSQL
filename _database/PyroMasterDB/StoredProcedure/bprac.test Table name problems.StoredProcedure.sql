SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bprac].[test Table name problems]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [bprac].[test Table name problems] AS' 
END
GO
ALTER   PROCEDURE [bprac].[test Table name problems]
AS
BEGIN
	-- Written by George Mastros
	-- February 25, 2012
	-- http://sqlcop.lessthandot.com
	-- http://blogs.lessthandot.com/index.php/DataMgmt/DBProgramming/do-not-use-spaces-or-other-invalid-chara
	
	SET NOCOUNT ON
	
	DECLARE @Output VarChar(max)
    DECLARE @AcceptableSymbols VARCHAR(100)

    SET @AcceptableSymbols = '_$'
	SET @Output = ''

	SELECT  @Output = @Output + TABLE_SCHEMA + '.' + TABLE_NAME + Char(13) + Char(10)
    FROM    INFORMATION_SCHEMA.TABLES
    WHERE   TABLE_NAME COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI Like '%[^a-z' + @AcceptableSymbols + ']%'
			AND TABLE_SCHEMA <> 'tSQLt'
	ORDER BY TABLE_SCHEMA,TABLE_NAME

	If @Output > '' 
		Begin
			Set @Output = Char(13) + Char(10) 
						  + 'For more information:  '
						  + 'http://blogs.lessthandot.com/index.php/DataMgmt/DBProgramming/do-not-use-spaces-or-other-invalid-chara' 
						  + Char(13) + Char(10) 
						  + Char(13) + Char(10) 
						  + @Output
			EXEC UNITTEST.tSQLt.Fail @Output
		End
END;
GO

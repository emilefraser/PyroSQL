SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bprac].[test Tables that start with tbl]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [bprac].[test Tables that start with tbl] AS' 
END
GO
ALTER   PROCEDURE [bprac].[test Tables that start with tbl]
AS
BEGIN
	-- Written by George Mastros
	-- February 25, 2012
	-- http://sqlcop.lessthandot.com
	-- http://blogs.lessthandot.com/index.php/DataMgmt/DBProgramming/MSSQLServer/don-t-prefix-your-table-names-with-tbl
	
	SET NOCOUNT ON
	
	DECLARE @Output VarChar(max)
	SET @Output = ''

    SELECT	@Output = @Output + TABLE_SCHEMA + '.' + TABLE_NAME + Char(13) + Char(10)
    From	INFORMATION_SCHEMA.TABLES
    WHERE	TABLE_TYPE = 'BASE TABLE'
			And TABLE_NAME COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI LIKE 'tbl%'
			And TABLE_SCHEMA <> 'tSQLt'
    Order By TABLE_SCHEMA,TABLE_NAME		

	If @Output > '' 
		Begin
			Set @Output = Char(13) + Char(10) 
						  + 'For more information:  '
						  + 'http://blogs.lessthandot.com/index.php/DataMgmt/DBProgramming/MSSQLServer/don-t-prefix-your-table-names-with-tbl' 
						  + Char(13) + Char(10) 
						  + Char(13) + Char(10) 
						  + @Output
			EXEC UNITTEST.tSQLt.Fail @Output
		End  
END;
GO

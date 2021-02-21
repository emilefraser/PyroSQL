SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bprac].[test Procedures Named SP_]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [bprac].[test Procedures Named SP_] AS' 
END
GO
ALTER   PROCEDURE [bprac].[test Procedures Named SP_]
AS
BEGIN
	-- Written by George Mastros
	-- February 25, 2012
	-- http://sqlcop.lessthandot.com
	-- http://blogs.lessthandot.com/index.php/DataMgmt/DBProgramming/MSSQLServer/don-t-start-your-procedures-with-sp_
	
	SET NOCOUNT ON
	
	Declare @Output VarChar(max)
    Set @Output = ''
  
	SELECT	@Output = @Output + SPECIFIC_SCHEMA + '.' + SPECIFIC_NAME + Char(13) + Char(10)
	From	INFORMATION_SCHEMA.ROUTINES
	Where	SPECIFIC_NAME COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI LIKE 'sp[_]%'
			And SPECIFIC_NAME COLLATE SQL_LATIN1_GENERAL_CP1_CI_AI NOT LIKE '%diagram%'
			AND ROUTINE_SCHEMA <> 'tSQLt'
	Order By SPECIFIC_SCHEMA,SPECIFIC_NAME

	If @Output > '' 
		Begin
			Set @Output = Char(13) + Char(10) 
						  + 'For more information:  '
						  + 'http://blogs.lessthandot.com/index.php/DataMgmt/DBProgramming/MSSQLServer/don-t-start-your-procedures-with-sp_'
						  + Char(13) + Char(10) 
						  + Char(13) + Char(10) 
						  + @Output
			EXEC [UNITTEST].tSQLt.Fail @Output
		End 
END;
GO

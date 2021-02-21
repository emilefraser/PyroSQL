SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bprac].[test Tables without a primary key]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [bprac].[test Tables without a primary key] AS' 
END
GO
ALTER   PROCEDURE [bprac].[test Tables without a primary key]
AS
BEGIN
	-- Written by George Mastros
	-- February 25, 2012
	-- http://sqlcop.lessthandot.com
	-- http://blogs.lessthandot.com/index.php/DataMgmt/DBProgramming/best-practice-every-table-should-have-a
	
	SET NOCOUNT ON
	
	DECLARE @Output VarChar(max)
	SET @Output = ''

	SELECT	@Output = @Output + su.name + '.' + AllTables.Name + Char(13) + Char(10)
	FROM	(
			SELECT	Name, id, uid
			From	sysobjects
			WHERE	xtype = 'U'
			) AS AllTables
			INNER JOIN sysusers su
				On AllTables.uid = su.uid
			LEFT JOIN (
				SELECT parent_obj
				From sysobjects
				WHERE  xtype = 'PK'
				) AS PrimaryKeys
				ON AllTables.id = PrimaryKeys.parent_obj
	WHERE	PrimaryKeys.parent_obj Is Null
			AND su.name <> 'tSQLt'
	ORDER BY su.name,AllTables.Name

	If @Output > '' 
		Begin
			Set @Output = Char(13) + Char(10) 
						  + 'For more information:  '
						  + 'http://blogs.lessthandot.com/index.php/DataMgmt/DBProgramming/best-practice-every-table-should-have-a' 
						  + Char(13) + Char(10) 
						  + Char(13) + Char(10) 
						  + @Output
			EXEC [UNITTEST].tSQLt.Fail @Output
		End	
END;
GO

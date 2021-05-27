SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_GetCursorForRunNew]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Private_GetCursorForRunNew] AS' 
END
GO

ALTER PROCEDURE [tSQLt].[Private_GetCursorForRunNew]
  @TestClassCursor CURSOR VARYING OUTPUT
AS
BEGIN
  SET @TestClassCursor = CURSOR LOCAL FAST_FORWARD FOR
   SELECT TC.Name
     FROM tSQLt.TestClasses AS TC
     JOIN tSQLt.Private_NewTestClassList AS PNTCL
       ON PNTCL.ClassName = TC.Name;

  OPEN @TestClassCursor;
END;
GO

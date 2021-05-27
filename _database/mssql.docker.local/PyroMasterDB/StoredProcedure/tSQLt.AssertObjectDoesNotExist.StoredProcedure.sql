SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[AssertObjectDoesNotExist]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[AssertObjectDoesNotExist] AS' 
END
GO

ALTER PROCEDURE [tSQLt].[AssertObjectDoesNotExist]
    @ObjectName NVARCHAR(MAX),
    @Message NVARCHAR(MAX) = ''
AS
BEGIN
     DECLARE @Msg NVARCHAR(MAX);
     IF OBJECT_ID(@ObjectName) IS NOT NULL
     OR(@ObjectName LIKE '#%' AND OBJECT_ID('tempdb..'+@ObjectName) IS NOT NULL)
     BEGIN
         SELECT @Msg = '''' + @ObjectName + ''' does exist!';
         EXEC tSQLt.Fail @Message,@Msg;
     END;
END;


GO

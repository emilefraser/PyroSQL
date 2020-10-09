SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE tSQLt.RunWithNullResults
    @TestName NVARCHAR(MAX) = NULL
AS
BEGIN
  EXEC tSQLt.Run @TestName = @TestName, @TestResultFormatter = 'tSQLt.NullTestResultFormatter';
END;

GO

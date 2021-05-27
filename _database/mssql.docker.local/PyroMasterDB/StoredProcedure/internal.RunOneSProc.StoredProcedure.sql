SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[internal].[RunOneSProc]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [internal].[RunOneSProc] AS' 
END
GO

-- =======================================================================
-- PROCEDURE RunOneSProc
-- This will run the given TST test procedure. Caled by RunOneTestInternal
-- =======================================================================
ALTER   PROCEDURE [internal].[RunOneSProc]
   @TestId           int               -- Identifies the test.
AS
BEGIN
   DECLARE @SqlCommand     nvarchar(1000)
   
   SET @SqlCommand = Internal.SFN_GetFullSprocName(@TestId)
   EXEC @SqlCommand

END
GO

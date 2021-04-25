SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[ResetAllTSTVariables]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tool].[ResetAllTSTVariables] AS' 
END
GO

-- =======================================================================
-- PROCEDURE ResetAllTSTVariables
-- Reset all TST variables.
-- =======================================================================
ALTER   PROCEDURE [tool].[ResetAllTSTVariables]
AS
BEGIN
   DELETE Data.TSTVariables
END
GO

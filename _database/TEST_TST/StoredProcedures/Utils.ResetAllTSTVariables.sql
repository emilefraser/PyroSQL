SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =======================================================================
-- PROCEDURE ResetAllTSTVariables
-- Reset all TST variables.
-- =======================================================================
CREATE PROCEDURE Utils.ResetAllTSTVariables
AS
BEGIN
   DELETE Data.TSTVariables
END

GO

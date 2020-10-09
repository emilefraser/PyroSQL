SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_syscollector_highest_incompatible_mdw_version]()
RETURNS nvarchar(50)
BEGIN
    RETURN '10.00.1300.13'  -- CTP6
END

GO

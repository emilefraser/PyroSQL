SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION fn_autoadmin_schema_version() 
RETURNS INT 
AS 
BEGIN 
    -- schema version 2 is latest supported version
    RETURN 2    
END 

GO

﻿CREATE FUNCTION [DSQLT].[CRLF]
( )
RETURNS CHAR (2)
AS
BEGIN
	RETURN CHAR(13)+CHAR(10)
END

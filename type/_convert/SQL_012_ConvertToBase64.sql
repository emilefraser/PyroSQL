use master;
GO
IF OBJECT_ID('[dbo].[ConvertToBase64]') IS NOT NULL 
DROP  FUNCTION  [dbo].[ConvertToBase64] 
GO
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: pair of prototype procs to convert to base64 and back
--#################################################################################################
--usage: select [dbo].[ConvertToBase64]('Lowell Izaguirre') -- TG93ZWxsIEl6YWd1aXJyZQ==
CREATE FUNCTION [dbo].[ConvertToBase64]
(
    @STRING VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
WITH SCHEMABINDING
AS
BEGIN
    RETURN (
        SELECT
            CAST(N'' AS XML).value(
                  'xs:base64Binary(xs:hexBinary(sql:column("bin")))'
                , 'VARCHAR(MAX)'
            )   Base64Encoding
        FROM (
            SELECT CAST(@STRING AS VARBINARY(MAX)) AS bin
        ) AS bin_sql_server_temp
    )
END
GO
use master;
GO
IF OBJECT_ID('[dbo].[sp_base64_encode]') IS NOT NULL 
DROP  FUNCTION  [dbo].[sp_base64_encode] 
GO
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: encode a varchar to a base64 string to obfuscate
--#################################################################################################
--SELECT dbo.[sp_base64_encode]('bananas')
-- To Base64 string
CREATE FUNCTION [dbo].[sp_base64_encode]
(
    @STRING VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
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

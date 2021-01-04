use master;
GO
IF OBJECT_ID('[dbo].[sp_base64_decode]') IS NOT NULL 
DROP  FUNCTION  [dbo].[sp_base64_decode] 
GO
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose:decode a string in base64 to varchar to de-obfuscate
--#################################################################################################
-- From Base64 string
--SELECT dbo.[sp_base64_decode]('YmFuYW5hcw==')
CREATE FUNCTION [dbo].[sp_base64_decode]
(
    @BASE64_STRING VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    RETURN (
        SELECT 
            CAST(
                CAST(N'' AS XML).value('xs:base64Binary(sql:variable("@BASE64_STRING"))', 'VARBINARY(MAX)') 
            AS VARCHAR(MAX)
            )   UTF8Encoding
    )
END
GO

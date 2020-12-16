use master;
GO
IF OBJECT_ID('[dbo].[ConvertFromBase64]') IS NOT NULL 
DROP  FUNCTION  [dbo].[ConvertFromBase64] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
-- From Base64 string
--usage: select [dbo].[ConvertFromBase64]('TG93ZWxsIEl6YWd1aXJyZQ==') -- Lowell Izaguirre
CREATE FUNCTION [dbo].[ConvertFromBase64]
(
    @BASE64_STRING VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
WITH SCHEMABINDING
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

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:     Emile FRaser
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE FUNCTION [DC].[udf_generate_DDL_AZSQL_MasterKeyEncryption_Create]()

RETURNS VARCHAR(MAX) 
AS
BEGIN
    -- Declare the return variable here
    DECLARE @MasterKeyEncryptionByPassword AS VARCHAR(MAX) = ''

	SELECT @MasterKeyEncryptionByPassword =  @MasterKeyEncryptionByPassword +
		'CREATE MASTER KEY ENCRYPTION BY PASSWORD=''P@ssw0rd'';' + CHAR(10) + CHAR(13)

    -- Return the result of the function
    RETURN @MasterKeyEncryptionByPassword
END

GO

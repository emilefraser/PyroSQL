SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:     Emile FRaser
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE FUNCTION [DC].[udf_generate_DDL_AZSQL_MasterKeyEncryption]()

RETURNS VARCHAR(MAX) 
AS
BEGIN
    -- Declare the return variable here
    DECLARE @MasterKeyEncryptionByPassword AS VARCHAR(MAX) = ''

	SELECT @MasterKeyEncryptionByPassword = 
	'IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
	BEGIN
		DROP MASTER KEY;
	END' + CHAR(10) + CHAR(13)

	SELECT @MasterKeyEncryptionByPassword =  @MasterKeyEncryptionByPassword +
		'CREATE MASTER KEY ENCRYPTION BY PASSWORD=''P@ssw0rd'';' + CHAR(10) + CHAR(13)

    -- Return the result of the function
    RETURN @MasterKeyEncryptionByPassword
END

GO

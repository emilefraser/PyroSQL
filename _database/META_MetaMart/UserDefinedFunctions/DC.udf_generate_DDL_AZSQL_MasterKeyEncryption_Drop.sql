SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:     Emile FRaser
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE FUNCTION [DC].[udf_generate_DDL_AZSQL_MasterKeyEncryption_Drop]()

RETURNS VARCHAR(MAX) 
AS
BEGIN
    -- Declare the return variable here
    DECLARE @MasterKeyEncryptionByPassword AS VARCHAR(MAX) = ''

	SELECT @MasterKeyEncryptionByPassword = @MasterKeyEncryptionByPassword +
	'IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
	BEGIN
		DROP MASTER KEY;
	END' + CHAR(10) + CHAR(13)

    -- Return the result of the function
    RETURN @MasterKeyEncryptionByPassword
END

GO

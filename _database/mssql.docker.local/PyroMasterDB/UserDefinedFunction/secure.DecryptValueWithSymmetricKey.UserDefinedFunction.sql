SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[secure].[DecryptValueWithSymmetricKey]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	SELECT secure.DecryptValueWithSymmetricKey(''Emile Fraser'', ''TestSymmetric'')
*/
CREATE   FUNCTION [secure].[DecryptValueWithSymmetricKey] (
							@EncryptedValue			VARBINARY(256)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	RETURN
		 CONVERT(VARCHAR(MAX), DECRYPTBYKEY(@EncryptedValue))
END' 
END
GO

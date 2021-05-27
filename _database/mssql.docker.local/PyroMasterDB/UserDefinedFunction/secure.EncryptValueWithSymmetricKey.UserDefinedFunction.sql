SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[secure].[EncryptValueWithSymmetricKey]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	SELECT secure.EncryptValueWithSymmetricKey(''Emile Fraser'', ''TestSymmetric'')
*/
CREATE   FUNCTION [secure].[EncryptValueWithSymmetricKey] (
							@ValueToEncrypt			VARCHAR(MAX)
						,	@SymmetricKeyName		SYSNAME = NULL
)
RETURNS VARBINARY(256)
AS
BEGIN
	RETURN
		 EncryptByKey(Key_GUID(@SymmetricKeyName), @ValueToEncrypt)
END' 
END
GO

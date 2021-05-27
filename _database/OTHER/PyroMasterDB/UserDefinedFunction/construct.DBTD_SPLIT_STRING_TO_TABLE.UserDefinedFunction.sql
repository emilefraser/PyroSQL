SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DBTD_SPLIT_STRING_TO_TABLE]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
--************************************************************************************************
CREATE FUNCTION [construct].[DBTD_SPLIT_STRING_TO_TABLE] 
(
	@v_String NVARCHAR(MAX), 
	@v_Delimeter VARCHAR(250) = '',''
)
RETURNS @v_Strings TABLE ( [String] NVARCHAR(MAX) )
  AS
BEGIN
	DECLARE @v_Index INT = -1 
 
	WHILE (LEN(@v_String) > 0) 
	BEGIN  
		SET @v_Index = CHARINDEX(@v_Delimeter , @v_String)  

		IF (@v_Index = 0) AND (LEN(@v_String) >= 0)  
		BEGIN   
			INSERT INTO @v_Strings ([String]) VALUES (@v_String)
			BREAK;  
		END  

		IF (@v_Index > 1)  
		BEGIN   
			INSERT INTO @v_Strings ([String]) VALUES (LEFT(@v_String, @v_Index - 1))   
		END  

		SET @v_String = RIGHT(@v_String, (LEN(@v_String) - @v_Index)) 
	END
	RETURN;
END

' 
END
GO

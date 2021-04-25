SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_dbo__ErrorLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_dbo__ErrorLog] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_dbo__ErrorLog]
 AS
INSERT INTO [AdventureWorks].[dbo__ErrorLog] (

)
SELECT 
[ErrorLogID],
[ErrorTime],
[UserName],
[ErrorNumber],
[ErrorSeverity],
[ErrorState],
[ErrorProcedure],
[ErrorLine],
[ErrorMessage]
FROM [AdventureWorks].[dbo].[ErrorLog];

GO

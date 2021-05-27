SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetServerCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetServerCount] AS' 
END
GO
ALTER PROCEDURE [dss].[GetServerCount]
AS
BEGIN
    SELECT COUNT(id) FROM [dss].[subscription]
END
GO

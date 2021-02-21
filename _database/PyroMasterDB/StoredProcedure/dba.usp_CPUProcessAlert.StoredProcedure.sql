SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[usp_CPUProcessAlert]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[usp_CPUProcessAlert] AS' 
END
GO
ALTER PROC [dba].[usp_CPUProcessAlert] AS SELECT 1
GO

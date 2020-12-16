USE master;
GO
IF OBJECT_ID('[dbo].[sp_fix_indexes]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_fix_indexes] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_fix_indexes]
AS
DECLARE @myDatabase varchar(MAX) = CONVERT(varchar(MAX),DB_NAME())

EXECUTE [master].[dbo].[IndexOptimize] @Databases = @myDatabase, @LogToTable = 'Y'
GO

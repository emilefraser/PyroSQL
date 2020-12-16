--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
-- Basic Best Practice: Tally Tables
-- A Numbers or Tally Table is a powerful tool
-- Numbers starts at zero, Tally starts at 1
--#################################################################################################
USE master;


IF OBJECT_ID('[dbo].[Tally]') IS NOT NULL 
DROP TABLE [dbo].[Tally] 
GO
SELECT TOP 11000 
  IDENTITY(INT,1,1) AS N   
INTO dbo.Tally   
FROM Master.dbo.SysColumns sc1
CROSS JOIN Master.dbo.SysColumns sc2

ALTER TABLE dbo.Tally ADD CONSTRAINT PK_Tally_N PRIMARY KEY CLUSTERED (N) WITH FILLFACTOR = 100

GRANT SELECT ON dbo.Tally TO PUBLIC


IF OBJECT_ID('[dbo].[Numbers]') IS NOT NULL 
DROP TABLE [dbo].[Numbers] 
GO
SELECT TOP 11001 
  IDENTITY(INT,0,1) AS N   
INTO dbo.[Numbers]   
FROM Master.dbo.SysColumns sc1
CROSS JOIN Master.dbo.SysColumns sc2

ALTER TABLE dbo.[Numbers] ADD CONSTRAINT PK_Numbers_N PRIMARY KEY CLUSTERED (N) WITH FILLFACTOR = 100

GRANT SELECT ON dbo.[Numbers] TO PUBLIC

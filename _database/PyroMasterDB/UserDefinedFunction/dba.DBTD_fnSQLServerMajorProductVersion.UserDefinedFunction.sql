SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[DBTD_fnSQLServerMajorProductVersion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
--************************************************************************************************
--Release							Product Version
--SQL Server 2014 RTM				12.0.2000.80
--
--SQL Server 2012 Service Pack 2	11.0.5058.0
--SQL Server 2012 Service Pack 1	11.00.3000.00
--SQL Server 2012 RTM				11.00.2100.60
--
--SQL Server 2008 R2 Service Pack 3	10.50.6000.34
--SQL Server 2008 R2 Service Pack 2	10.50.4000.0
--SQL Server 2008 R2 Service Pack 1	10.50.2500.0
--SQL Server 2008 R2 RTM			10.50.1600.1
--
--SQL Server 2008 Service Pack 4	10.00.6000.29
--SQL Server 2008 Service Pack 3	10.00.5500.00
--SQL Server 2008 Service Pack 2	10.00.4000.00
--SQL Server 2008 Service Pack 1	10.00.2531.00
--SQL Server 2008 RTM				10.00.1600.22
CREATE FUNCTION [dba].[DBTD_fnSQLServerMajorProductVersion]()
RETURNS SMALLINT
  AS
BEGIN
	DECLARE @v_SQLServerVersion SMALLINT = CAST( LEFT( CAST( SERVERPROPERTY(''ProductVersion'') AS VARCHAR(50)), 2) AS SMALLINT)
	RETURN @v_SQLServerVersion;
END

' 
END
GO

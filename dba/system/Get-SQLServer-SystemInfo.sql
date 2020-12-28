/******************************************************************************************************
** Project: Operations
** Issue: Gather SQL Server System Information
** ShortDesc: Gather SQL Server System Information. These commands usually gets executed by SQL Server during startup
** Auth: Raju Venkataraman
** Date: 2016-07-25 Created
** Description: Gather SQL Server System Information. These commands usually gets executed by SQL Server during startup
**************************
** Change History
**************************
** CR Date Author Description
** ----- ----------– ----------- ------------------------------------------------------------
** 1  2016-07-25 Raju Venkataraman Gather SQL Server System Information. These commands usually gets executed by SQL Server during startup
********************************************************************************************************/
SET NOCOUNT ON
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
SET XACT_ABORT  ON 

-----------BEGIN SQL SCRIPT HEADER-------------------
DECLARE @DB_NAME VARCHAR(128)
SET @DB_NAME = ( SELECT DB_NAME(dbid)
                 FROM   master..sysprocesses
                 WHERE  spid = @@SPID
               )
PRINT '-----------------------------------------------------------------------'
PRINT '-----START RAPID DEVELOPEMENT SQL SCRIPT--------'
PRINT '-----SCRIPT RAN ON DB: ' + @DB_NAME
PRINT '-----SCRIPT START TIME: '
    + CONVERT(VARCHAR, CONVERT(DATETIME, GETDATE()), 121)
PRINT '-----MachineName : ' + CAST(SERVERPROPERTY('MachineName') AS VARCHAR)
PRINT '-----SQL Instance : ' + CAST(@@SERVERNAME AS VARCHAR)
PRINT '-----DB User : ' + CURRENT_USER
PRINT '-----System User : ' + SYSTEM_USER
PRINT '-----Host : ' + HOST_NAME()
PRINT '-----Application : ' + APP_NAME()
PRINT '-----TranCount : ' + CAST (@@trancount AS VARCHAR)
PRINT '-----------------------------------------------------------------------'
----------------END SQL SCRIPT HEADER---------------------
-- Script Specific Variables Declarations

DECLARE @StartTime DATETIME2 , @EndTime DATETIME2
SELECT @StartTime = GETDATE() 


DECLARE @HkeyLocal NVARCHAR(18);
DECLARE @ServicesRegPath NVARCHAR(34);
DECLARE @SqlServiceRegPath sysname;
DECLARE @BrowserServiceRegPath sysname;
DECLARE @MSSqlServerRegPath NVARCHAR(31);
DECLARE @InstanceNamesRegPath NVARCHAR(59);
DECLARE @InstanceRegPath sysname;
DECLARE @SetupRegPath sysname;
DECLARE @NpRegPath sysname;
DECLARE @TcpRegPath sysname;
DECLARE @RegPathParams sysname;
DECLARE @FilestreamRegPath sysname;

SELECT  @HkeyLocal = N'HKEY_LOCAL_MACHINE';

-- Instance-based paths
SELECT  @MSSqlServerRegPath = N'SOFTWARE\Microsoft\MSSQLServer';
SELECT  @InstanceRegPath = @MSSqlServerRegPath + N'\MSSQLServer';
SELECT  @FilestreamRegPath = @InstanceRegPath + N'\Filestream';
SELECT  @SetupRegPath = @MSSqlServerRegPath + N'\Setup';
SELECT  @RegPathParams = @InstanceRegPath + '\Parameters';

-- Services
SELECT  @ServicesRegPath = N'SYSTEM\CurrentControlSet\Services';
SELECT  @SqlServiceRegPath = @ServicesRegPath + N'\MSSQLSERVER';
SELECT  @BrowserServiceRegPath = @ServicesRegPath + N'\SQLBrowser';

-- InstanceId setting
SELECT  @InstanceNamesRegPath = N'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL';

-- Network settings
SELECT  @NpRegPath = @InstanceRegPath + N'\SuperSocketNetLib\Np';
SELECT  @TcpRegPath = @InstanceRegPath + N'\SuperSocketNetLib\Tcp';

DECLARE @SmoAuditLevel INT;
EXEC master.dbo.xp_instance_regread @HkeyLocal, @InstanceRegPath,
    N'AuditLevel', @SmoAuditLevel OUTPUT;

DECLARE @NumErrorLogs INT;
EXEC master.dbo.xp_instance_regread @HkeyLocal, @InstanceRegPath,
    N'NumErrorLogs', @NumErrorLogs OUTPUT;

DECLARE @SmoLoginMode INT;
EXEC master.dbo.xp_instance_regread @HkeyLocal, @InstanceRegPath, N'LoginMode',
    @SmoLoginMode OUTPUT;

DECLARE @SmoMailProfile NVARCHAR(512);
EXEC master.dbo.xp_instance_regread @HkeyLocal, @InstanceRegPath,
    N'MailAccountName', @SmoMailProfile OUTPUT;

DECLARE @BackupDirectory NVARCHAR(512);
IF 1 = ISNULL(CAST(SERVERPROPERTY('IsLocalDB') AS BIT), 0)
    SELECT  @BackupDirectory = CAST(SERVERPROPERTY('instancedefaultdatapath') AS NVARCHAR(512));
ELSE
    EXEC master.dbo.xp_instance_regread @HkeyLocal, @InstanceRegPath,
        N'BackupDirectory', @BackupDirectory OUTPUT;

DECLARE @SmoPerfMonMode INT;
EXEC master.dbo.xp_instance_regread @HkeyLocal, @InstanceRegPath,
    N'Performance', @SmoPerfMonMode OUTPUT;

IF @SmoPerfMonMode IS NULL
    BEGIN
        SET @SmoPerfMonMode = 1000;
    END;

DECLARE @InstallSqlDataDir NVARCHAR(512);
EXEC master.dbo.xp_instance_regread @HkeyLocal, @SetupRegPath, N'SQLDataRoot',
    @InstallSqlDataDir OUTPUT;

DECLARE @MasterPath NVARCHAR(512);
DECLARE @LogPath NVARCHAR(512);
DECLARE @ErrorLog NVARCHAR(512);
DECLARE @ErrorLogPath NVARCHAR(512);

SELECT  @MasterPath = SUBSTRING(physical_name, 1,
                                LEN(physical_name) - CHARINDEX('\',
                                                              REVERSE(physical_name)))
FROM    master.sys.database_files
WHERE   name = N'master';
SELECT  @LogPath = SUBSTRING(physical_name, 1,
                             LEN(physical_name) - CHARINDEX('\',
                                                            REVERSE(physical_name)))
FROM    master.sys.database_files
WHERE   name = N'mastlog';
SELECT  @ErrorLog = CAST(SERVERPROPERTY(N'errorlogfilename') AS NVARCHAR(512));
SELECT  @ErrorLogPath = SUBSTRING(@ErrorLog, 1,
                                  LEN(@ErrorLog) - CHARINDEX('\',
                                                             REVERSE(@ErrorLog)));

DECLARE @SmoRoot NVARCHAR(512);
EXEC master.dbo.xp_instance_regread @HkeyLocal, @SetupRegPath, N'SQLPath',
    @SmoRoot OUTPUT;

DECLARE @ServiceStartMode INT;
EXEC master.sys.xp_instance_regread @HkeyLocal, @SqlServiceRegPath, N'Start',
    @ServiceStartMode OUTPUT;

DECLARE @ServiceAccount NVARCHAR(512);
EXEC master.sys.xp_instance_regread @HkeyLocal, @SqlServiceRegPath,
    N'ObjectName', @ServiceAccount OUTPUT;

DECLARE @NamedPipesEnabled INT;
EXEC master.dbo.xp_instance_regread @HkeyLocal, @NpRegPath, N'Enabled',
    @NamedPipesEnabled OUTPUT;

DECLARE @TcpEnabled INT;
EXEC master.sys.xp_instance_regread @HkeyLocal, @TcpRegPath, N'Enabled',
    @TcpEnabled OUTPUT;

DECLARE @InstallSharedDirectory NVARCHAR(512);
EXEC master.sys.xp_instance_regread @HkeyLocal, @SetupRegPath, N'SQLPath',
    @InstallSharedDirectory OUTPUT;

DECLARE @SqlGroup NVARCHAR(512);
EXEC master.dbo.xp_instance_regread @HkeyLocal, @SetupRegPath, N'SQLGroup',
    @SqlGroup OUTPUT;

DECLARE @FilestreamLevel INT;
EXEC master.dbo.xp_instance_regread @HkeyLocal, @FilestreamRegPath,
    N'EnableLevel', @FilestreamLevel OUTPUT;

DECLARE @FilestreamShareName NVARCHAR(512);
EXEC master.dbo.xp_instance_regread @HkeyLocal, @FilestreamRegPath,
    N'ShareName', @FilestreamShareName OUTPUT;

DECLARE @cluster_name NVARCHAR(128);
DECLARE @quorum_type TINYINT;
DECLARE @quorum_state TINYINT;
BEGIN TRY
    SELECT  @cluster_name = cluster_name ,
            @quorum_type = quorum_type ,
            @quorum_state = quorum_state
    FROM    sys.dm_hadr_cluster;
END TRY
BEGIN CATCH
    IF ( ERROR_NUMBER() NOT IN ( 297, 300 ) )
        BEGIN
            THROW;
        END;
END CATCH;

SELECT  @SmoAuditLevel AS [AuditLevel] ,
        ISNULL(@NumErrorLogs, -1) AS [NumberOfLogFiles] ,
        ( CASE WHEN @SmoLoginMode < 3 THEN @SmoLoginMode
               ELSE 9
          END ) AS [LoginMode] ,
        ISNULL(@SmoMailProfile, N'') AS [MailProfile] ,
        @BackupDirectory AS [BackupDirectory] ,
        @SmoPerfMonMode AS [PerfMonMode] ,
        ISNULL(@InstallSqlDataDir, N'') AS [InstallDataDirectory] ,
        CAST(@@SERVICENAME AS sysname) AS [ServiceName] ,
        @ErrorLogPath AS [ErrorLogPath] ,
        @SmoRoot AS [RootDirectory] ,
        CAST(CASE WHEN 'a' <> 'A' THEN 1
                  ELSE 0
             END AS BIT) AS [IsCaseSensitive] ,
        @@MAX_PRECISION AS [MaxPrecision] ,
        CAST(FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') AS BIT) AS [IsFullTextInstalled] ,
        SERVERPROPERTY(N'ProductVersion') AS [VersionString] ,
        CAST(SERVERPROPERTY(N'Edition') AS sysname) AS [Edition] ,
        CAST(SERVERPROPERTY(N'ProductLevel') AS sysname) AS [ProductLevel] ,
        CAST(SERVERPROPERTY('IsSingleUser') AS BIT) AS [IsSingleUser] ,
        CAST(SERVERPROPERTY('EngineEdition') AS INT) AS [EngineEdition] ,
        CONVERT(sysname, SERVERPROPERTY(N'collation')) AS [Collation] ,
        CAST(SERVERPROPERTY('IsClustered') AS BIT) AS [IsClustered] ,
        CAST(SERVERPROPERTY(N'MachineName') AS sysname) AS [NetName] ,
        @LogPath AS [MasterDBLogPath] ,
        @MasterPath AS [MasterDBPath] ,
        SERVERPROPERTY('instancedefaultdatapath') AS [DefaultFile] ,
        SERVERPROPERTY('instancedefaultlogpath') AS [DefaultLog] ,
        SERVERPROPERTY(N'ResourceVersion') AS [ResourceVersionString] ,
        SERVERPROPERTY(N'ResourceLastUpdateDateTime') AS [ResourceLastUpdateDateTime] ,
        SERVERPROPERTY(N'CollationID') AS [CollationID] ,
        SERVERPROPERTY(N'ComparisonStyle') AS [ComparisonStyle] ,
        SERVERPROPERTY(N'SqlCharSet') AS [SqlCharSet] ,
        SERVERPROPERTY(N'SqlCharSetName') AS [SqlCharSetName] ,
        SERVERPROPERTY(N'SqlSortOrder') AS [SqlSortOrder] ,
        SERVERPROPERTY(N'SqlSortOrderName') AS [SqlSortOrderName] ,
        SERVERPROPERTY(N'ComputerNamePhysicalNetBIOS') AS [ComputerNamePhysicalNetBIOS] ,
        SERVERPROPERTY(N'BuildClrVersion') AS [BuildClrVersionString] ,
        @ServiceStartMode AS [ServiceStartMode] ,
        ISNULL(@ServiceAccount, N'') AS [ServiceAccount] ,
        CAST(@NamedPipesEnabled AS BIT) AS [NamedPipesEnabled] ,
        CAST(@TcpEnabled AS BIT) AS [TcpEnabled] ,
        ISNULL(@InstallSharedDirectory, N'') AS [InstallSharedDirectory] ,
        ISNULL(SUSER_SNAME(sid_binary(ISNULL(@SqlGroup, N''))), N'') AS [SqlDomainGroup] ,
        CASE WHEN 1 = msdb.dbo.fn_syspolicy_is_automation_enabled()
                  AND EXISTS ( SELECT   *
                               FROM     msdb.dbo.syspolicy_system_health_state
                               WHERE    target_query_expression_with_id LIKE 'Server%' )
             THEN 1
             ELSE 0
        END AS [PolicyHealthState] ,
        @FilestreamLevel AS [FilestreamLevel] ,
        ISNULL(@FilestreamShareName, N'') AS [FilestreamShareName] ,
        -1 AS [TapeLoadWaitTime] ,
        CAST(SERVERPROPERTY(N'IsHadrEnabled') AS BIT) AS [IsHadrEnabled] ,
        SERVERPROPERTY(N'HADRManagerStatus') AS [HadrManagerStatus] ,
        ISNULL(@cluster_name, '') AS [ClusterName] ,
        ISNULL(@quorum_type, 4) AS [ClusterQuorumType] ,
        ISNULL(@quorum_state, 3) AS [ClusterQuorumState] ,
        SUSER_SID(@ServiceAccount, 0) AS [ServiceAccountSid] ,
        CAST(SERVERPROPERTY(N'Servername') AS sysname) AS [Name] ,
        CAST(ISNULL(SERVERPROPERTY(N'instancename'), N'') AS sysname) AS [InstanceName] ,
        CAST(0x0001 AS INT) AS [Status] ,
        0 AS [IsContainedAuthentication] ,
        CAST(NULL AS INT) AS [ServerType];


-- Script Block End

SELECT @EndTime  = GETDATE()

-----------BEGIN SQL SCRIPT FOOTER--------------------------------------
PRINT '----------------------------------------------------------------'
PRINT '---FINISHED SQL SCRIPT--'
PRINT '---COMPLETED TIME:' + CONVERT(VARCHAR, CONVERT(DATETIME, GETDATE()), 121)
PRINT '---TranCount : ' + CAST (@@trancount AS VARCHAR)
PRINT 'Execution Time : '+ CONVERT(VARCHAR(255),( DATEDIFF(MILLISECOND,@StartTime , @EndTime))) + ' MilliSeconds'
PRINT '-------------------------------------------------------------------'

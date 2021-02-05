DECLARE @sql AS NVARCHAR(4000)
SELECT @sql = dbo.fn_Table_Structure('
SELECT  @@SERVERNAME [Server] ,
        DB_NAME() [Database] ,
        MF.name [File Name] ,
        MF.type_desc [Type] ,
        MF.physical_name [Path] ,
        CAST(CAST(MF.size / 128.0 AS DECIMAL(15, 2)) AS VARCHAR(50)) + '' MB'' [File Size] ,
        CAST(CONVERT(DECIMAL(10, 2), MF.size / 128.0 - ( ( size / 128.0 ) - CAST(FILEPROPERTY(MF.name, ''SPACEUSED'') AS INT) / 128.0 )) AS VARCHAR(50)) + '' MB'' [File Used Space] ,
        CAST(CONVERT(DECIMAL(10, 2), MF.size / 128.0 - CAST(FILEPROPERTY(MF.name, ''SPACEUSED'') AS INT) / 128.0) AS VARCHAR(50)) + '' MB'' [File Free Space] ,
        CAST(CONVERT(DECIMAL(10, 2), ( ( MF.size / 128.0 - CAST(FILEPROPERTY(MF.name, ''SPACEUSED'') AS INT) / 128.0 ) / ( MF.size / 128.0 ) ) * 100) AS VARCHAR(50)) + ''%'' [% Free File Space] ,
        IIF(MF.growth = 0, ''N/A'', 
           CASE WHEN MF.is_percent_growth = 1 THEN CAST(MF.growth AS VARCHAR(50)) + ''%'' 
           ELSE CAST(MF.growth / 128 AS VARCHAR(50)) + '' MB''
           END) [Autogrowth] ,
        VS.volume_mount_point ,
        CAST(CAST(VS.total_bytes / 1024. / 1024 / 1024 AS DECIMAL(20, 2)) AS VARCHAR(50)) + '' GB'' [Total Volume Size] ,
        CAST(CAST(VS.available_bytes / 1024. / 1024 / 1024 AS DECIMAL(20, 2)) AS VARCHAR(50)) + '' GB'' [Free Space] ,
        CAST(CAST(VS.available_bytes / CAST(VS.total_bytes AS DECIMAL(20, 2)) * 100 AS DECIMAL(20, 2)) AS VARCHAR(50)) + ''%'' [% Free]
FROM    sys.database_files MF
        CROSS APPLY sys.dm_os_volume_stats(DB_ID(), MF.file_id) VS
', 'Test' )
PRINT @sql
EXEC (@sql)
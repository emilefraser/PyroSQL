USE master;
GO
IF OBJECT_ID('dbo.sqlg_ParseDiskskpXml') IS NULL EXECUTE sp_executesql N'CREATE PROCEDURE dbo.sqlg_ParseDiskskpXml AS RETURN';
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:      Raul Gonzalez @SQLDoubleG
-- Create date: 26/02/2017
-- Description: Process XML output file of diskspd.exe
--
-- Parameters:
--              - @filePath     -> Full path of the file that contains the XML output of diskspd.exe
--              - @simplified   -> will return just one row with general info and IO totals, including IOps, throughput and latency for Reads and Writes.
--
-- Log:
--              26/02/2017  RAG - Created
--
-- Copyright:   (C) 2017 Raul Gonzalez (@SQLDoubleG http://www.sqldoubleg.com)
--
--              THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
--              ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
--              TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
--              PARTICULAR PURPOSE.
--
--              THE AUTHOR SHALL NOT BE LIABLE TO YOU OR ANY THIRD PARTY FOR ANY INDIRECT, 
--              SPECIAL, INCIDENTAL, PUNITIVE, COVER, OR CONSEQUENTIAL DAMAGES OF ANY KIND
--
--              YOU MAY ALTER THIS CODE FOR YOUR OWN *NON-COMMERCIAL* PURPOSES. YOU MAY
--              REPUBLISH ALTERED CODE AS LONG AS YOU INCLUDE THIS COPYRIGHT AND GIVE DUE CREDIT. 
--
-- =============================================
ALTER PROCEDURE dbo.sqlg_ParseDiskskpXml
    @filePath       NVARCHAR(512)
    , @simplified   BIT = 1
 
AS
BEGIN
 
SET NOCOUNT ON;
 
DECLARE @xml XML;
DECLARE @sql NVARCHAR(1000) = N'SET @xml = (SELECT CONVERT(XML, BulkColumn) FROM OPENROWSET(BULK ''' + @filePath + ''', SINGLE_BLOB) AS x);';
 
EXECUTE sys.sp_executesql @sql, N'@xml XML OUTPUT', @xml = @xml OUTPUT;
 
IF OBJECT_ID('tempdb..#SystemInfo')         IS NOT NULL DROP TABLE #SystemInfo;
IF OBJECT_ID('tempdb..#RunningParameters')  IS NOT NULL DROP TABLE #RunningParameters;
IF OBJECT_ID('tempdb..#RunningValues')      IS NOT NULL DROP TABLE #RunningValues;
IF OBJECT_ID('tempdb..#TimeSpan')           IS NOT NULL DROP TABLE #TimeSpan;
IF OBJECT_ID('tempdb..#ProcessorUsage')     IS NOT NULL DROP TABLE #ProcessorUsage;
--IF OBJECT_ID('tempdb..#AverageLatency')       IS NOT NULL DROP TABLE #AverageLatency
IF OBJECT_ID('tempdb..#LatencyPercentiles') IS NOT NULL DROP TABLE #LatencyPercentiles;
IF OBJECT_ID('tempdb..#ResultsPerThread')   IS NOT NULL DROP TABLE #ResultsPerThread;
 
--===========================================================================================
-- Info contained in <Results><System>
--===========================================================================================
SELECT @xml.value('(/Results/System/ComputerName)[1]', 'VARCHAR(128)') AS computerName
        , @xml.value('(/Results/System/RunTime)[1]', 'VARCHAR(30)') AS RunTime
        , @xml.value('(/Results/System/ProcessorTopology/Group/@ActiveProcessors)[1]', 'TINYINT') AS ActiveProcessors
INTO #SystemInfo;
--===========================================================================================
-- Info contained in <Results><Profile><TimeSpans><TimeSpan>
--===========================================================================================
SELECT t.c.value('(./TimeSpan/CompletionRoutines)[1]', 'VARCHAR(5)') AS CompletionRoutines
        , t.c.value('(./TimeSpan/MeasureLatency)[1]', 'VARCHAR(5)') AS MeasureLatency
        , t.c.value('(./TimeSpan/CalculateIopsStdDev)[1]', 'VARCHAR(5)') AS CalculateIopsStdDev
        , t.c.value('(./TimeSpan/DisableAffinity)[1]', 'VARCHAR(5)') AS DisableAffinity
        , t.c.value('(./TimeSpan/Duration)[1]', 'INT') AS Duration
        , t.c.value('(./TimeSpan/Warmup)[1]', 'INT') AS Warmup
        , t.c.value('(./TimeSpan/Cooldown)[1]', 'INT') AS Cooldown
        , t.c.value('(./TimeSpan/ThreadCount)[1]', 'TINYINT') AS ThreadCount
        , t.c.value('(./TimeSpan/IoBucketDuration)[1]', 'INT') AS IoBucketDuration
        , t.c.value('(./TimeSpan/RandSeed)[1]', 'INT') AS RandSeed
        --,  t.c.query('.') AS CompletionRoutines
INTO #RunningParameters
FROM @xml.nodes('/Results/Profile/TimeSpans') AS t(c);
--===========================================================================================
-- Info contained for each <Target> in <Results><Profile><TimeSpans><TimeSpan><Targets>
--===========================================================================================
SELECT t2.d.value('(./Path)[1]', 'VARCHAR(512)') AS Path
        , t2.d.value('(./BlockSize)[1]', 'VARCHAR(512)') AS BlockSize
        , t2.d.value('(./BaseFileOffset)[1]', 'VARCHAR(512)') AS BaseFileOffset
        , t2.d.value('(./SequentialScan)[1]', 'VARCHAR(512)') AS SequentialScan
        , t2.d.value('(./RandomAccess)[1]', 'VARCHAR(512)') AS RandomAccess
        , t2.d.value('(./TemporaryFile)[1]', 'VARCHAR(512)') AS TemporaryFile
        , t2.d.value('(./UseLargePages)[1]', 'VARCHAR(512)') AS UseLargePages
        , t2.d.value('(./DisableOSCache)[1]', 'VARCHAR(512)') AS DisableOSCache
        , t2.d.value('(./WriteThrough)[1]', 'VARCHAR(512)') AS WriteThrough
        --, d.value('(./WriteBufferContent>'
        --, d.value('(./Pattern>sequential</Pattern>'
        --, d.value('(.//WriteBufferContent>'
        , t2.d.value('(./ParallelAsyncIO)[1]', 'VARCHAR(512)') AS ParallelAsyncIO
        , t2.d.value('(./StrideSize)[1]', 'VARCHAR(512)') AS StrideSize
        , t2.d.value('(./InterlockedSequential)[1]', 'VARCHAR(512)') AS InterlockedSequential
        , t2.d.value('(./ThreadStride)[1]', 'VARCHAR(512)') AS ThreadStride
        , t2.d.value('(./MaxFileSize)[1]', 'VARCHAR(512)') AS MaxFileSize
        , t2.d.value('(./RequestCount)[1]', 'VARCHAR(512)') AS RequestCount
        , t2.d.value('(./WriteRatio)[1]', 'VARCHAR(512)') AS WriteRatio
        , t2.d.value('(./Throughput)[1]', 'VARCHAR(512)') AS Throughput
        , t2.d.value('(./ThreadsPerFile)[1]', 'VARCHAR(512)') AS ThreadsPerFile
        , t2.d.value('(./IOPriority)[1]', 'VARCHAR(512)') AS IOPriority
INTO #RunningValues
FROM @xml.nodes('/Results/Profile/TimeSpans/TimeSpan/Targets/Target') AS t2(d);
--===========================================================================================
-- Info contained in <Results><TimeSpan>
--===========================================================================================
SELECT t.c.value('(./TestTimeSeconds)[1]', 'DECIMAL(10,2)') AS TestTimeSeconds
        , t.c.value('(./ThreadCount)[1]', 'SMALLINT') AS ThreadCount
        , t.c.value('(./ProcCount)[1]', 'SMALLINT') AS ProcCount
INTO #TimeSpan
FROM @xml.nodes('/Results/TimeSpan') AS t(c);
--===========================================================================================
-- Info contained for each <CPU> in <Results><TimeSpan><CpuUtilization>
--===========================================================================================
SELECT t.c.value('(./Id)[1]', 'TINYINT') AS Id
        , t.c.value('(./UsagePercent)[1]', 'DECIMAL(5,2)') AS UsagePercent
        , t.c.value('(./UserPercent)[1]', 'DECIMAL(5,2)') AS UserPercent
        , t.c.value('(./KernelPercent)[1]', 'DECIMAL(5,2)') AS KernelPercent
        , t.c.value('(./IdlePercent)[1]', 'DECIMAL(5,2)') AS IdlePercent
INTO #ProcessorUsage
FROM @xml.nodes('/Results/TimeSpan/CpuUtilization/CPU') AS t(c);
--===========================================================================================
-- Info contained in <Results><TimeSpan><Latency>, this can be calculated from the details too, so skip it
--===========================================================================================
--SELECT t.c.value('(./AverageReadMilliseconds)[1]', 'DECIMAL(10,2)') AS AverageReadMilliseconds
--      , t.c.value('(./ReadLatencyStdev)[1]', 'DECIMAL(10,2)') AS ReadLatencyStdev
--      , t.c.value('(./AverageWriteMilliseconds)[1]', 'DECIMAL(10,2)') AS AverageWriteMilliseconds
--      , t.c.value('(./WriteLatencyStdev)[1]', 'DECIMAL(10,2)') AS WriteLatencyStdev
--      , t.c.value('(./AverageTotalMilliseconds)[1]', 'DECIMAL(10,2)') AS AverageTotalMilliseconds
--      , t.c.value('(./LatencyStdev)[1]', 'DECIMAL(10,2)') AS LatencyStdev
--INTO #AverageLatency
--FROM @xml.nodes('/Results/TimeSpan/Latency') AS t(c)
--===========================================================================================
-- Info contained for each <Bucket> in <Results><TimeSpan><Latency>
--===========================================================================================
SELECT t.c.value('(./Percentile)[1]', 'DECIMAL(15,7)') AS Percentile
        , t.c.value('(./ReadMilliseconds)[1]', 'DECIMAL(10,4)') AS ReadMilliseconds
        , t.c.value('(./WriteMilliseconds)[1]', 'DECIMAL(10,4)') AS WriteMilliseconds
        , t.c.value('(./TotalMilliseconds)[1]', 'DECIMAL(10,4)') AS TotalMilliseconds
INTO #LatencyPercentiles
FROM @xml.nodes('/Results/TimeSpan/Latency/Bucket') AS t(c);
--===========================================================================================
-- Info contained for each <Thread> in <Results><TimeSpan><Latency>
--===========================================================================================
SELECT t.c.value('(./Id)[1]', 'INT') AS ThreadId
        , t.c.value('(./Target/Path)[1]', 'VARCHAR(512)') AS Path
        , t.c.value('(./Target/BytesCount)[1]', 'BIGINT') AS BytesCount
        , t.c.value('(./Target/FileSize)[1]', 'BIGINT') AS FileSize
        , t.c.value('(./Target/IOCount)[1]', 'BIGINT') AS IOCount
        , t.c.value('(./Target/ReadBytes)[1]', 'BIGINT') AS ReadBytes
        , t.c.value('(./Target/ReadCount)[1]', 'BIGINT') AS ReadCount
        , t.c.value('(./Target/WriteBytes)[1]', 'BIGINT') AS WriteBytes
        , t.c.value('(./Target/WriteCount)[1]', 'BIGINT') AS WriteCount     
        , t.c.value('(./Target/AverageReadLatencyMilliseconds)[1]', 'DECIMAL(10,3)') AS AverageReadLatencyMilliseconds
        , t.c.value('(./Target/ReadLatencyStdev)[1]', 'DECIMAL(10,3)') AS ReadLatencyStdev
        , t.c.value('(./Target/AverageWriteLatencyMilliseconds)[1]', 'DECIMAL(10,3)') AS AverageWriteLatencyMilliseconds
        , t.c.value('(./Target/WriteLatencyStdev)[1]', 'DECIMAL(10,3)') AS WriteLatencyStdev
        , t.c.value('(./Target/AverageLatencyMilliseconds)[1]', 'DECIMAL(10,3)') AS AverageLatencyMilliseconds
        , t.c.value('(./Target/LatencyStdev)[1]', 'DECIMAL(10,3)') AS LatencyStdev
INTO #ResultsPerThread
FROM @xml.nodes('/Results/TimeSpan/Thread') AS t(c);
 
 
--===========================================================================================
-- Return useful Information
--===========================================================================================
IF @simplified = 1 BEGIN
 
    SELECT  si.computerName
            , si.RunTime
            , ts.TestTimeSeconds
            , ts.ThreadCount
            , COUNT(DISTINCT th.Path) AS FileCount
            , STUFF(tf.path, 1, 2, '') AS TargetFiles
            , rv.ThreadsPerFile
            , rv.BlockSize
            --th.FileSize / 1024 / 1024 AS [FileSize MB],
            , CONVERT(VARCHAR(3), ( 100 - rv.WriteRatio )) + '/' + CONVERT(VARCHAR(3), rv.WriteRatio) AS [Read/Write Ratio]
            -- Total Read + Writes
            , SUM(th.BytesCount) AS [Total bytes]
            , SUM(th.IOCount) AS [Total I/Os]
            , CEILING(SUM(th.IOCount) / ts.TestTimeSeconds) AS [Total IOps]
            , CONVERT(DECIMAL(15, 2), ROUND(SUM(th.BytesCount) / 1024. / 1024 / ts.TestTimeSeconds, 2)) AS [Total MB/s]
            -- Reads
            , SUM(th.ReadBytes) AS [Read bytes]
            , SUM(th.ReadCount) AS [Read I/Os]
            , CEILING(SUM(th.ReadCount) / ts.TestTimeSeconds) AS [Read IOps]
            , CONVERT(DECIMAL(15, 2), ROUND(SUM(th.ReadBytes) / 1024. / 1024 / ts.TestTimeSeconds, 2)) AS [Read MB/s]
            -- Writes
            , SUM(th.WriteBytes) AS [Write bytes]
            , SUM(th.WriteCount) AS [Write I/Os]
            , CEILING(SUM(th.WriteCount) / ts.TestTimeSeconds) AS [Write IOps]
            , CONVERT(DECIMAL(15, 2), ROUND(SUM(th.WriteBytes) / 1024. / 1024 / ts.TestTimeSeconds, 2)) AS [Write MB/s]
            -- Latency Total
            , CONVERT(DECIMAL(15, 2), ROUND(AVG(ISNULL(th.AverageLatencyMilliseconds, 0)), 2)) AS [AverageLatencyMilliseconds]
            , CONVERT(DECIMAL(15, 2), ROUND(AVG(ISNULL(th.LatencyStdev, 0)), 2)) AS [LatencyStdev]
            -- Latency Read
            , CONVERT(DECIMAL(15, 2), ROUND(AVG(ISNULL(th.AverageReadLatencyMilliseconds, 0)), 2)) AS [AverageReadLatencyMilliseconds]
            , CONVERT(DECIMAL(15, 2), ROUND(AVG(ISNULL(th.ReadLatencyStdev, 0)), 2)) AS [ReadLatencyStdev]
            -- Latency Write
            , CONVERT(DECIMAL(15, 2), ROUND(AVG(ISNULL(th.AverageWriteLatencyMilliseconds, 0)), 2)) AS [AverageWriteLatencyMilliseconds]
            , CONVERT(DECIMAL(15, 2), ROUND(AVG(ISNULL(th.WriteLatencyStdev, 0)), 2)) AS [WriteLatencyStdev]
        FROM #ResultsPerThread AS th
            CROSS JOIN #TimeSpan AS ts
            CROSS JOIN ( SELECT TOP 1 * FROM   #RunningValues) AS rv
            CROSS JOIN #SystemInfo AS si
            CROSS JOIN ( SELECT DISTINCT ', ' + Path + ' (' + CONVERT(VARCHAR(10), FileSize / 1024/ 1024) + 'MB)' AS [text()]
                            FROM #ResultsPerThread FOR XML PATH('')) AS tf ( [path] )
        GROUP BY si.computerName
            , si.RunTime
            , ts.TestTimeSeconds
            , ts.ThreadCount
            , rv.ThreadsPerFile
            , rv.BlockSize
            , rv.WriteRatio
            , th.FileSize
            , tf.[path];
END; ELSE BEGIN
    --===========================================================================================
    -- Input parameters
    --===========================================================================================   
    SELECT  si.computerName AS [computer name]
            , si.RunTime AS [run time]
            , p.Duration AS [duration]
            , p.Warmup AS [warm up time]
            , p.Cooldown AS [cood down time]
            , p.RandSeed AS [random seed]
            , si.ActiveProcessors
        FROM #RunningParameters AS p
            CROSS JOIN #SystemInfo AS si;
     
    --===========================================================================================
    -- Time span
    --===========================================================================================
    SELECT  rv.Path
            , rv.BlockSize
            --rv.WriteRatio ,
            , CONVERT(VARCHAR(3), ( 100 - rv.WriteRatio )) + '/' + CONVERT(VARCHAR(3), rv.WriteRatio) AS [Read/Write Ratio]
            , rv.ThreadsPerFile
            , rv.IOPriority
            , rv.BaseFileOffset
            , rv.SequentialScan
            , rv.RandomAccess
            , rv.TemporaryFile
            , rv.UseLargePages
            , rv.DisableOSCache
            , rv.WriteThrough
            , rv.ParallelAsyncIO
            , rv.StrideSize
            , rv.InterlockedSequential
            , rv.ThreadStride
            , rv.MaxFileSize
            , rv.RequestCount
            , rv.Throughput 
        FROM #RunningValues AS rv;
    --===========================================================================================
    -- Processor
    --===========================================================================================
    SELECT  Id AS CPU
            , UsagePercent
            , UserPercent
            , KernelPercent
            , IdlePercent
        FROM #ProcessorUsage
    --===========================================================================================
    -- Latency
    --===========================================================================================
    ;WITH cte AS(
    SELECT  ISNULL(CONVERT(VARCHAR(5), th.ThreadId), 'Total') AS ThreadId
            , th.Path + ' (' + CONVERT(VARCHAR(10), th.FileSize / 1024 / 1024)
            + 'MB)' AS [file]
            -- Total Read + Writes
            , ( th.BytesCount ) AS [Total bytes]
            , ( th.IOCount ) AS [Total I/Os]
            , CEILING(( th.IOCount ) / ts.TestTimeSeconds) AS [Total IOps]
            , CONVERT(DECIMAL(15, 2), ROUND(( th.BytesCount ) / 1024. / 1024 / ts.TestTimeSeconds, 2)) AS [Total MB/s]
            -- Reads
            , ( th.ReadBytes ) AS [Read bytes]
            , ( th.ReadCount ) AS [Read I/Os]
            , CEILING(( th.ReadCount ) / ts.TestTimeSeconds) AS [Read IOps]
            , CONVERT(DECIMAL(15, 2), ROUND(( th.ReadBytes ) / 1024. / 1024 / ts.TestTimeSeconds, 2)) AS [Read MB/s]
            -- Writes
            , ( th.WriteBytes ) AS [Write bytes]
            , ( th.WriteCount ) AS [Write I/Os]
            , CEILING(( th.WriteCount ) / ts.TestTimeSeconds) AS [Write IOps]
            , CONVERT(DECIMAL(15, 2), ROUND(( th.WriteBytes ) / 1024. / 1024 / ts.TestTimeSeconds, 2)) AS [Write MB/s]
            -- Latency Total
            , CONVERT(DECIMAL(15, 2), ROUND(( ISNULL(th.AverageLatencyMilliseconds, 0) ), 2)) AS [AverageLatencyMilliseconds]
            , CONVERT(DECIMAL(15, 2), ROUND(( ISNULL(th.LatencyStdev, 0) ), 2)) AS [LatencyStdev]
            -- Latency Read
            , CONVERT(DECIMAL(15, 2), ROUND(( ISNULL(th.AverageReadLatencyMilliseconds, 0) ), 2)) AS [AverageReadLatencyMilliseconds]
            , CONVERT(DECIMAL(15, 2), ROUND(( ISNULL(th.ReadLatencyStdev, 0) ), 2)) AS [ReadLatencyStdev]
            -- Latency Write
            , CONVERT(DECIMAL(15, 2), ROUND(( ISNULL(th.AverageWriteLatencyMilliseconds, 0) ), 2)) AS [AverageWriteLatencyMilliseconds]
            , CONVERT(DECIMAL(15, 2), ROUND(( ISNULL(th.WriteLatencyStdev, 0) ), 2)) AS [WriteLatencyStdev]
        FROM #ResultsPerThread AS th
            CROSS JOIN #TimeSpan AS ts
            CROSS JOIN (SELECT TOP 1 * FROM #RunningValues) AS rv
            CROSS JOIN #SystemInfo AS si
    UNION  
    SELECT
            'Total'
            , '-'
            -- Total Read + Writes
            , SUM(th.BytesCount) AS [Total bytes]
            , SUM(th.IOCount) AS [Total I/Os]
            , CEILING(SUM(th.IOCount) / ts.TestTimeSeconds) AS [Total IOps]
            , CONVERT(DECIMAL(15, 2), ROUND(SUM(th.BytesCount) / 1024. / 1024 / ts.TestTimeSeconds, 2)) AS [Total MB/s]
            -- Reads
            , SUM(th.ReadBytes) AS [Read bytes]
            , SUM(th.ReadCount) AS [Read I/Os]
            , CEILING(SUM(th.ReadCount) / ts.TestTimeSeconds) AS [Read IOps]
            , CONVERT(DECIMAL(15, 2), ROUND(SUM(th.ReadBytes) / 1024. / 1024 / ts.TestTimeSeconds, 2)) AS [Read MB/s]
            -- Writes
            , SUM(th.WriteBytes) AS [Write bytes]
            , SUM(th.WriteCount) AS [Write I/Os]
            , CEILING(SUM(th.WriteCount) / ts.TestTimeSeconds) AS [Write IOps]
            , CONVERT(DECIMAL(15, 2), ROUND(SUM(th.WriteBytes) / 1024. / 1024 / ts.TestTimeSeconds, 2)) AS [Write MB/s]
            -- Latency Total
            , CONVERT(DECIMAL(15, 2), ROUND(AVG(ISNULL(th.AverageLatencyMilliseconds, 0)), 2)) AS [AverageLatencyMilliseconds]
            , CONVERT(DECIMAL(15, 2), ROUND(AVG(ISNULL(th.LatencyStdev, 0)), 2)) AS [LatencyStdev]
            -- Latency Read
            , CONVERT(DECIMAL(15, 2), ROUND(AVG(ISNULL(th.AverageReadLatencyMilliseconds, 0)), 2)) AS [AverageReadLatencyMilliseconds]
            , CONVERT(DECIMAL(15, 2), ROUND(AVG(ISNULL(th.ReadLatencyStdev, 0)), 2)) AS [ReadLatencyStdev]
            -- Latency Write
            , CONVERT(DECIMAL(15, 2), ROUND(AVG(ISNULL(th.AverageWriteLatencyMilliseconds, 0)), 2)) AS [AverageWriteLatencyMilliseconds]
            , CONVERT(DECIMAL(15, 2), ROUND(AVG(ISNULL(th.WriteLatencyStdev, 0)), 2)) AS [WriteLatencyStdev]
        FROM #ResultsPerThread AS th
            CROSS JOIN #TimeSpan AS ts
            CROSS JOIN (SELECT TOP 1 * FROM #RunningValues) AS rv
            CROSS JOIN #SystemInfo AS si
        GROUP BY ts.TestTimeSeconds
    )
 
    SELECT * FROM cte
        ORDER BY CASE WHEN ISNUMERIC(ThreadId) = 0 THEN 999 ELSE CONVERT(INT, ThreadId) END ASC;
    --===========================================================================================
    -- Percentiles
    --===========================================================================================
    SELECT CASE WHEN Percentile = 0             THEN 'min'
                WHEN Percentile = 100           THEN 'max'
                WHEN Percentile = 100           THEN 'max'
                WHEN Percentile % 1 = .9        THEN '3-nines'
                WHEN Percentile % 1 = .99       THEN '4-nines'
                WHEN Percentile % 1 = .999      THEN '5-nines'
                WHEN Percentile % 1 = .9999     THEN '6-nines'
                WHEN Percentile % 1 = .99999    THEN '7-nines'
                WHEN Percentile % 1 = .999999   THEN '8-nines'
                WHEN Percentile % 1 = .9999999  THEN '9-nines'
                ELSE CONVERT(VARCHAR(10), CONVERT(INT, Percentile)) + 'th'
            END AS [%-ile]
            , ISNULL(CONVERT(VARCHAR(10), ReadMilliseconds), 'N/A') AS [Read (ms)]
            , ISNULL(CONVERT(VARCHAR(10), WriteMilliseconds), 'N/A') AS [Write (ms)]
            , TotalMilliseconds AS [Total (ms)]
        FROM #LatencyPercentiles
        WHERE Percentile IN (0, 25, 50, 75, 90, 95)
            OR Percentile >= 99;
END;
 
END;
 
GO
/****** Object:  StoredProcedure [dbo].[IntegerListfromRanges]    Script Date: 01/12/2016 10:45:21 ******/
 
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES
	WHERE ROUTINES.ROUTINE_TYPE='procedure' 
	AND ROUTINES.ROUTINE_SCHEMA='dbo'
	AND	ROUTINES.ROUTINE_NAME = 'IntegerListfromRanges')
	DROP PROCEDURE IntegerListfromRanges
go
CREATE procedure [dbo].[IntegerListfromRanges]
/**
summary:   >
 This Procedure takes a list of integers with ranges in them and turns it into
 a list of integers. Effectively, it removes the ranges by turning them into all
 the integers in the range. This is a demonstration of a working method because
 I create a number table on the fly with negative integers (these make things harder)
 and normally you'd just want to have the table of numbers that you would then
 use for whatever relational task you were engaged with
Author: Phil Factor
Revision: 1.0
date: 19 Nov 2016
example: >
    DECLARE @list VARCHAR(MAX)
    EXECUTE dbo.IntegerListFromRanges '-12--3,4,6,7',@list OUTPUT
    SELECT @list
returns:  >
  The list as an ascll string representing a list of integers.
**/  
@Rangelist VARCHAR(MAX), --eg. 1-4,6,8-11,13,21-23,25,27-28,30
	--which would become 1,2,3,4,6,8,9,10,11,13,21,22,23,25,27,28,30
@list VARCHAR(MAX) output
AS
 
BEGIN 
--declare some variables
DECLARE  @inClause VARCHAR(MAX), @BetweenClause VARCHAR(MAX),
         @XMLVersionOfList XML,@NumberTableSQL NVARCHAR(MAX)
DECLARE @MyNumbers TABLE
  (
    MyRange VARCHAR(10)
);
--here we create the numbers table with a precautionary test
IF NOT EXISTS(
  SELECT TABLES.TABLE_NAME FROM tempdb.INFORMATION_SCHEMA.TABLES 
  WHERE TABLES.TABLE_NAME LIKE '#NumbersForRanges%')
	BEGIN
    SELECT TOP 10000 IDENTITY(int,-5000,1) AS Number
      INTO #NumbersForRanges
      FROM sys.objects s1      
        CROSS JOIN sys.objects s2; 
    ALTER TABLE #NumbersForRanges ADD CONSTRAINT 
		PK_NumbersForRanges PRIMARY KEY CLUSTERED (Number);
	end
--we convert the list into XML
SELECT @XMLVersionOfList =
  '<list><i>' + REPLACE(@rangelist, ',', '</i><i>') + '</i></list>';
--we now take each component and insert it into a row of a table variable
INSERT INTO @MyNumbers(MyRange)
  SELECT x.y.value('.', 'varchar(10)') AS IDs
  FROM @XMLVersionOfList.nodes('/list/i/text()') AS x(y);
-- end of section converting list to a table we can work with
SELECT @inClause='', @BetweenClause=''
--we want to make a SELECT statement against a number table
SELECT 
 @inClause=@inClause +CASE WHEN MyRange like '%[0-9]-%' THEN '' ELSE ',' + MyRange END,
 @BetweenClause=@BetweenClause 
  +CASE WHEN MyRange like '%[0-9]-%' 
   THEN 'or (number between '+STUFF(MyRange,PATINDEX('%[0-9]-%',[@MyNumbers].MyRange)+1,1,' and ')+') ' 
   ELSE'' END
 FROM @MyNumbers
 SELECT @list=''
IF @@RowCount>0 
  BEGIN
  SELECT @NumberTableSQL='SELECT @OutputList='''';
  SELECT @OutputList=@OutputList+ '',''+ convert(varchar(5),number)  from #NumbersForRanges where ' +
    CASE WHEN LEN(@inClause)>0 THEN 'number in ('+ STUFF(@inClause,1,1,0)+') 'ELSE '' END+
    CASE WHEN LEN(@BetweenClause)>0 THEN CASE WHEN LEN(@inClause)>0 THEN 'or' ELSE '' END+
	' ('+ STUFF(@BetweenClause,1,3,'')+')'ELSE '' END;
---now we execute the code against the number table
  EXEC sp_ExecuteSQL @NumberTableSQL, N'@OutputList Varchar(max) OUTPUT',@OutputList=@List OUTPUT
  SELECT  @list=STUFF(@list,1,1,'')
  END
end
go
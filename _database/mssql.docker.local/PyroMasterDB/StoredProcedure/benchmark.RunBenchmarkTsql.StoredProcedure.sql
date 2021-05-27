SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[RunBenchmarkTsql]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [benchmark].[RunBenchmarkTsql] AS' 
END
GO
/*

	-- Run SQL statement specified times, show results, insert execution details into log table benchmark.BenchmarkTSQL.

   EXEC [benchmark].[RunBenchmarkTsql]
         @tsqlStatement = 'SELECT * FROM , sys.databases;'
       , @SkipTsqlValidityCheck = 0;

    EXEC [benchmark].[RunBenchmarkTsql]
         @tsqlStatement = 'SELECT * FROM sys.databases;'
       , @SkipTsqlValidityCheck = 0
	   , @saveResults = 1

    EXEC [benchmark].[RunBenchmarkTsql]
         @tsqlStatement = 'SELECT TOP(100000) * FROM sys.objects AS o1 CROSS JOIN sys.objects AS o2 CROSS JOIN sys.objects AS o3;'
	   , @tsqlStatementBefore = 'WAITFOR DELAY ''00:00:01'';'
	   , @tsqlStatementAfter  = 'WAITFOR DELAY ''00:00:02'';'
       , @numberOfExecution = 5
       , @saveResults       = 1
       , @calcMedian        = 1
       , @clearCache        = 1
       , @printStepInfo     = 1
       , @durationAccuracy  = 'ms'
	   , @additionalInfo      = 1;


    Version: 5.7
    Created: 2017-12-14 by Konstantin Taranov
    Modified: 2019-04-18 by Konstantin Taranov
    Main contributors: Konstantin Taranov, Aleksei Nagorskii
    Source: https://rebrand.ly/[benchmark].[RunBenchmarkTsql]
*/
ALTER PROCEDURE [benchmark].[RunBenchmarkTsql](
      @tsqlStatementBefore			nvarchar(max) = NULL
    , @tsqlStatement				nvarchar(max)
    , @tsqlStatementAfter			nvarchar(max) = NULL
    , @numberOfExecution			int           = 10
    , @saveResults					bit           = 0
    , @SkipTsqlValidityCheck        bit           = 1
    , @clearCache					bit           = 0					-- Clear cached plan for TSQL statement before each run using DBCC FREEPROCCACHE(@planHandle)
    , @calcMedian					bit           = 0					--  Calculate pseudo median of all execution times
    , @printStepInfo				bit           = 0					-- PRINT detailed step information: step count, start time, end time, duration.
    , @durationAccuracy				varchar(5)    = 'ss'
    , @dateTimeFunction				varchar(16)   = 'SYSDATETIME'		-- Define using datetime function, possible values of functions: SYSDATETIME, SYSUTCDATETIME
    , @additionalInfo				bit           = 0					-- Save additional session parameteres (ANSI_WARNINGS, XACT_ABORT and etc) to XML column AdditionalInfo in log table master.dbo.BenchmarkTSQL.
)
   
   
AS
BEGIN TRY

    SET NOCOUNT ON;

    DECLARE @startBenchmark datetime2(7) = CASE WHEN @dateTimeFunction = 'SYSDATETIME'    THEN SYSDATETIME()
                                           WHEN @dateTimeFunction = 'SYSUTCDATETIME' THEN SYSUTCDATETIME()
                                      END;

    DECLARE @originalLogin sysname = QUOTENAME(ORIGINAL_LOGIN()); /* https://sqlstudies.com/2015/06/24/which-user-function-do-i-use/ */
    DECLARE @err_msg       nvarchar(max);
    DECLARE @raiseError    nvarchar(2000);

    /* Using RAISEEROR for interactive step printing http://sqlity.net/en/984/print-vs-raiserror/ */
    SET @raiseError = 'Benchmark started at ' +  CONVERT(varchar(27), @startBenchmark, 121) + ' by ' + @originalLogin;
    RAISERROR(@raiseError, 0, 1) WITH NOWAIT;

    DECLARE @productMajorVersion sql_variant = SERVERPROPERTY('ProductMajorVersion');
    IF CAST(@productMajorVersion AS int) < 10
    BEGIN
        DECLARE @MsgError varchar(2000) = 'Stored procedure [benchmark].[RunBenchmarkTsql] works only for SQL Server 2008 and higher. Yor ProductMajorVersion is ' +
                                           CAST(@productMajorVersion AS varchar(30)) +
                                           '. You can try to replace datetime2 data type on datetime, perhaps it will be enough.';
        THROW 55001, @MsgError, 1;
    END;

    IF @tsqlStatement IS NULL
        THROW 55002, '@tsqlStatement is NULL, please specify TSQL statement.', 1;
    IF @tsqlStatement = N''
        THROW 55003, '@tsqlStatement is empty, please specify TSQL statement.', 1;

    IF @durationAccuracy NOT IN (
          'ns'  /* nanosecond  */
        , 'mcs' /* microsecond */
        , 'ms'  /* millisecond */
        , 'ss'  /* second      */
        , 'mi'  /* minute      */
        , 'hh'  /* hour        */
        , 'dd'  /* day         */
        , 'wk'  /* week        */
    )
    THROW 55004, '@durationAccuracy accept only this values: ns, mcs, ms, ss, mi, hh, wk, dd. Default value is ss. See DATEDIFF https://docs.microsoft.com/en-us/sql/t-sql/functions/datediff-transact-sql' , 1;

    IF @dateTimeFunction NOT IN ('SYSDATETIME', 'SYSUTCDATETIME')
    THROW 55005, '@dateTimeFunction accept only SYSDATETIME and SYSUTCDATETIME. Default value is SYSDATETIME. See https://docs.microsoft.com/en-us/sql/t-sql/functions/date-and-time-data-types-and-functions-transact-sql', 1;

    IF @numberOfExecution <= 0 OR @numberOfExecution >= 32000
        THROW 55006, '@numberOfExecution must be > 0 and < 32000. If you want more execution then comment 183 and 184 lines.', 1;

    IF @SkipTsqlValidityCheck = 0
    BEGIN
        IF @tsqlStatementBefore IS NOT NULL AND @tsqlStatementBefore <> '' AND EXISTS (
            SELECT 1
            FROM sys.dm_exec_describe_first_result_set(@tsqlStatementBefore, NULL, 0)
            WHERE error_message   IS NOT NULL
              AND error_number    IS NOT NULL
              AND error_severity  IS NOT NULL
              AND error_state     IS NOT NULL
              AND error_type      IS NOT NULL
              AND error_type_desc IS NOT NULL
              )
        BEGIN
            SELECT @err_msg = [error_message]
            FROM sys.dm_exec_describe_first_result_set(@tsqlStatementBefore, NULL, 0)
            WHERE column_ordinal = 0;

            THROW 55007, @err_msg, 1;
        END;

        IF @tsqlStatement IS NOT NULL AND @tsqlStatement <> N'' AND EXISTS (
            SELECT 1
            FROM sys.dm_exec_describe_first_result_set(@tsqlStatement, NULL, 0)
            WHERE error_message IS NOT NULL
              AND error_number IS NOT NULL
              AND error_severity IS NOT NULL
              AND error_state IS NOT NULL
              AND error_type IS NOT NULL
              AND error_type_desc IS NOT NULL
              )
        BEGIN
            SELECT @err_msg = [error_message]
            FROM sys.dm_exec_describe_first_result_set(@tsqlStatement, NULL, 0)
            WHERE column_ordinal = 0;

            THROW 55008, @err_msg, 1;
        END;

        IF @tsqlStatementAfter IS NOT NULL AND @tsqlStatementAfter <> N'' AND EXISTS (
            SELECT 1
            FROM sys.dm_exec_describe_first_result_set(@tsqlStatementAfter, NULL, 0)
            WHERE error_message IS NOT NULL
              AND error_number IS NOT NULL
              AND error_severity IS NOT NULL
              AND error_state IS NOT NULL
              AND error_type IS NOT NULL
              AND error_type_desc IS NOT NULL
              )
        BEGIN
            SELECT @err_msg = [error_message]
            FROM sys.dm_exec_describe_first_result_set(@tsqlStatementAfter, NULL, 0)
            WHERE column_ordinal = 0;
    
            THROW 55009, @err_msg, 1;
        END;
    END;

    IF @saveResults = 1 AND OBJECT_ID(N'benchmark.BenchmarkTSQL', 'U') IS NULL
    THROW 55010, 'Please create benchmark.BenchmarkTSQL log table before run procedure with @saveResults = 1.
    CREATE TABLE benchmark.BenchmarkTSQL(
          BenchmarkTSQLID     int IDENTITY  NOT NULL
        , TSQLStatementGUID   varchar(36)   NOT NULL
        , StepRowNumber       int           NOT NULL
        , StartBenchmark      datetime2(7)  NOT NULL
        , EndBenchmark        datetime2(7)  NOT NULL
        , StartStep           datetime2(7)  NOT NULL
        , EndStep             datetime2(7)  NOT NULL
        , StepDuration        bigint        NOT NULL
        , DurationAccuracy    varchar(10)   NOT NULL
        , TsqlStatementBefore nvarchar(max) NULL
        , TsqlStatement       nvarchar(max) NOT NULL
        , TsqlStatementAfter  nvarchar(max) NULL
        , ClearCache          bit           NOT NULL
        , PrintStepInfo       bit           NOT NULL
        , OriginalLogin       sysname       NOT NULL
        , AdditionalInfo      xml           NULL
    );', 1;

    DECLARE @crlf          nvarchar(10) = CHAR(10);
    DECLARE @stepNumber    int          = 0;
    DECLARE @min           bigint;
    DECLARE @avg           bigint;
    DECLARE @max           bigint;
    DECLARE @median        real;
    DECLARE @planHandle    varbinary(64);
    DECLARE @startStep     datetime2(7);
    DECLARE @endStep       datetime2(7);
    DECLARE @stepDuration  int;
    DECLARE @additionalXML xml;

    DECLARE @BenchmarkTSQL TABLE(
        StepNumber          int          NOT NULL
      , StartBenchmark      datetime2(7) NOT NULL
      , EndBenchmark        datetime2(7) NOT NULL
      , StartStep           datetime2(7) NOT NULL
      , EndStep             datetime2(7) NOT NULL
      , StepDuration        bigint       NOT NULL
      , ClearCache          bit          NOT NULL
      , PrintStepInfo       bit          NOT NULL
      , DurationAccuracy    varchar(10)  NOT NULL
      , AdditionalInfo      xml          NULL
      );

    IF @additionalInfo = 1
    SET @tsqlStatement = @tsqlStatement + @crlf + N'
        SET @additionalXMLOUT = (
        SELECT [Option], [Enabled]
        FROM (
               SELECT ''DISABLE_DEF_CNST_CHK'' AS "Option", CASE @@options & 1     WHEN 0 THEN 0 ELSE 1 END AS "Enabled" UNION ALL
               SELECT ''IMPLICIT_TRANSACTIONS''           , CASE @@options & 2     WHEN 0 THEN 0 ELSE 1 END UNION ALL
               SELECT ''CURSOR_CLOSE_ON_COMMIT''          , CASE @@options & 4     WHEN 0 THEN 0 ELSE 1 END UNION ALL
               SELECT ''ANSI_WARNINGS''                   , CASE @@options & 8     WHEN 0 THEN 0 ELSE 1 END UNION ALL
               SELECT ''ANSI_PADDING''                    , CASE @@options & 16    WHEN 0 THEN 0 ELSE 1 END UNION ALL
               SELECT ''ANSI_NULLS''                      , CASE @@options & 32    WHEN 0 THEN 0 ELSE 1 END UNION ALL
               SELECT ''ARITHABORT''                      , CASE @@options & 64    WHEN 0 THEN 0 ELSE 1 END UNION ALL
               SELECT ''ARITHIGNORE''                     , CASE @@options & 128   WHEN 0 THEN 0 ELSE 1 END UNION ALL
               SELECT ''QUOTED_IDENTIFIER''               , CASE @@options & 256   WHEN 0 THEN 0 ELSE 1 END UNION ALL
               SELECT ''NOCOUNT''                         , CASE @@options & 512   WHEN 0 THEN 0 ELSE 1 END UNION ALL
               SELECT ''ANSI_NULL_DFLT_ON''               , CASE @@options & 1024  WHEN 0 THEN 0 ELSE 1 END UNION ALL
               SELECT ''ANSI_NULL_DFLT_OFF''              , CASE @@options & 2048  WHEN 0 THEN 0 ELSE 1 END UNION ALL
               SELECT ''CONCAT_NULL_YIELDS_NULL''         , CASE @@options & 4096  WHEN 0 THEN 0 ELSE 1 END UNION ALL
               SELECT ''NUMERIC_ROUNDABORT''              , CASE @@options & 8192  WHEN 0 THEN 0 ELSE 1 END UNION ALL
               SELECT ''XACT_ABORT''                      , CASE @@options & 16384 WHEN 0 THEN 0 ELSE 1 END
        ) AS s
        FOR XML RAW
        );';

    IF @saveResults = 1
    BEGIN
        DECLARE @TSQLStatementGUID varchar(36) = NEWID();
        PRINT(N'TSQLStatementGUID in log table is: ' + @TSQLStatementGUID + @crlf);
    END;

    WHILE @stepNumber < @numberOfExecution
    BEGIN
        SET @stepNumber = @stepNumber + 1;

        IF @clearCache = 1
        BEGIN
            SELECT @planHandle = plan_handle
            FROM sys.dm_exec_cached_plans
            CROSS APPLY sys.dm_exec_sql_text(plan_handle)
            WHERE [text] LIKE @tsqlStatement;  /* LIKE instead = (equal) because = (equal) ignore trailing spaces */

            IF @planHandle IS NOT NULL DBCC FREEPROCCACHE(@planHandle);
        END;

        IF @tsqlStatementBefore IS NOT NULL AND @tsqlStatementBefore <> ''
            EXECUTE sp_executesql @tsqlStatementBefore;

        BEGIN /* Run bencmark step and calculate it duration */
            SET @startStep = CASE WHEN @dateTimeFunction = 'SYSDATETIME'    THEN SYSDATETIME()
                                  WHEN @dateTimeFunction = 'SYSUTCDATETIME' THEN SYSUTCDATETIME()
                             END;

           IF @dateTimeFunction = 'SYSDATETIME'
           BEGIN
               IF @additionalInfo = 0
               BEGIN
                   EXEC sp_executesql @tsqlStatement;
                   SET @endStep = SYSDATETIME();
               END;

               IF @additionalInfo = 1
               BEGIN
                   EXEC sp_executesql @tsqlStatement, N'@additionalXMLOUT XML OUTPUT', @additionalXMLOUT = @additionalXML OUTPUT SELECT @additionalXML;
                   SET @endStep = SYSDATETIME();
               END;
           END;

           IF @dateTimeFunction = 'SYSUTCDATETIME'
           BEGIN
               IF @additionalInfo = 0
               BEGIN
                   EXEC sp_executesql @tsqlStatement;
                   SET @endStep = SYSUTCDATETIME();
               END;

               IF @additionalInfo = 1
               BEGIN
                   EXEC sp_executesql @tsqlStatement, N'@additionalXMLOUT XML OUTPUT', @additionalXMLOUT = @additionalXML OUTPUT SELECT @additionalXML;
                   SET @endStep = SYSUTCDATETIME();
               END;
           END;

        END;

        SET @stepDuration = CASE WHEN @durationAccuracy = 'ns'  THEN DATEDIFF(ns,  @startStep, @endStep)
                                 WHEN @durationAccuracy = 'mcs' THEN DATEDIFF(mcs, @startStep, @endStep)
                                 WHEN @durationAccuracy = 'ms'  THEN DATEDIFF(ms,  @startStep, @endStep)
                                 WHEN @durationAccuracy = 'ss'  THEN DATEDIFF(ss,  @startStep, @endStep)
                                 WHEN @durationAccuracy = 'mi'  THEN DATEDIFF(mi,  @startStep, @endStep)
                                 WHEN @durationAccuracy = 'hh'  THEN DATEDIFF(hh,  @startStep, @endStep)
                                 WHEN @durationAccuracy = 'dd'  THEN DATEDIFF(dd,  @startStep, @endStep)
                                 WHEN @durationAccuracy = 'wk'  THEN DATEDIFF(wk,  @startStep, @endStep)
                                 ELSE 0
                            END;

        INSERT @BenchmarkTSQL (
              StepNumber
            , StartBenchmark
            , EndBenchmark
            , StartStep
            , EndStep
            , StepDuration
            , DurationAccuracy
            , ClearCache
            , PrintStepInfo
            , AdditionalInfo
            )
        VALUES (
              @stepNumber
            , @startBenchmark
            , /* it does not matter which function use (this is NOT NULL column)
                  becasue we update this column later with correct values */
              SYSDATETIME()
            , @startStep
            , @endStep
            , @stepDuration
            , @durationAccuracy
            , @clearCache
            , @printStepInfo
            , @additionalXML
            );

       IF @saveResults = 1
       BEGIN
          INSERT INTO benchmark.BenchmarkTSQL(
            TSQLStatementGUID
          , StepRowNumber
          , StartBenchmark
          , EndBenchmark
          , StartStep
          , EndStep
          , StepDuration
          , DurationAccuracy
          , TsqlStatementBefore
          , TsqlStatement
          , TsqlStatementAfter
          , ClearCache
          , PrintStepInfo
          , OriginalLogin
          , AdditionalInfo
          )
          SELECT @TSQLStatementGUID AS TSQLStatementGUID
               , @stepNumber AS StepRowNumber
               , StartBenchmark
               , EndBenchmark
               , StartStep
               , EndStep
               , StepDuration
               , DurationAccuracy
               , @tsqlStatementBefore
               , @tsqlStatement
               , @tsqlStatementAfter
               , ClearCache
               , PrintStepInfo
               , @originalLogin AS OriginalLogin
               , @additionalXML AS AdditionalInfo
           FROM @BenchmarkTSQL
           WHERE StepNumber = @stepNumber;
       END;

       IF @printStepInfo = 1
       BEGIN
       /* Using RAISEEROR for interactive step printing http://sqlity.net/en/984/print-vs-raiserror/ */
           SET @raiseError = 'Run ' + CASE WHEN @stepNumber < 10   THEN '   ' + CAST(@stepNumber AS varchar(30))
                                           WHEN @stepNumber < 100  THEN '  '  + CAST(@stepNumber AS varchar(30))
                                           WHEN @stepNumber < 1000 THEN ' '   + CAST(@stepNumber AS varchar(30))
                                           ELSE CAST(@stepNumber AS varchar(30))
                                      END +
                              ', start: '    + CONVERT(varchar(27), @startStep, 121) +
                              ', finish: '   + CONVERT(varchar(27), CASE WHEN @dateTimeFunction = 'SYSDATETIME'    THEN SYSDATETIME()
                                                                         WHEN @dateTimeFunction = 'SYSUTCDATETIME' THEN SYSUTCDATETIME()
                                                                    END, 121) +
                              ', step duration: ' + CAST(@stepDuration AS varchar(100)) + @durationAccuracy + '.';
           RAISERROR(@raiseError, 0, 1) WITH NOWAIT;
        END;

        IF @tsqlStatementAfter IS NOT NULL AND @tsqlStatementAfter <> ''
            EXECUTE sp_executesql @tsqlStatementAfter;

    END;

    SELECT @min = MIN(StepDuration), @avg = AVG(StepDuration), @max = MAX(StepDuration)
      FROM @BenchmarkTSQL;

    DECLARE @endBenchmark datetime2(7) = CASE WHEN @dateTimeFunction = 'SYSDATETIME'    THEN SYSDATETIME()
                                              WHEN @dateTimeFunction = 'SYSUTCDATETIME' THEN SYSUTCDATETIME()
                                         END;

    IF @saveResults = 1
    BEGIN
        UPDATE benchmark.BenchmarkTSQL
           SET EndBenchmark = @endBenchmark
         WHERE TSQLStatementGUID = @TSQLStatementGUID;
    END;

    IF @calcMedian = 1
    BEGIN
        SELECT @median =
        (
             (SELECT MAX(TMIN) FROM
                  (SELECT TOP(50) PERCENT
                          CASE WHEN @durationAccuracy = 'ns'  THEN DATEDIFF(ns,  StartStep, EndStep)
                               WHEN @durationAccuracy = 'mcs' THEN DATEDIFF(mcs, StartStep, EndStep)
                               WHEN @durationAccuracy = 'ms'  THEN DATEDIFF(ms,  StartStep, EndStep)
                               WHEN @durationAccuracy = 'ss'  THEN DATEDIFF(ss,  StartStep, EndStep)
                               WHEN @durationAccuracy = 'mi'  THEN DATEDIFF(mi,  StartStep, EndStep)
                               WHEN @durationAccuracy = 'hh'  THEN DATEDIFF(hh,  StartStep, EndStep)
                               WHEN @durationAccuracy = 'dd'  THEN DATEDIFF(dd,  StartStep, EndStep)
                               WHEN @durationAccuracy = 'wk'  THEN DATEDIFF(wk,  StartStep, EndStep)
                               ELSE 0
                          END AS TMIN
                   FROM @BenchmarkTSQL
                   ORDER BY TMIN
                  ) AS BottomHalf
             )
             +
             (SELECT MIN(TMAX) FROM
                  (SELECT TOP 50 PERCENT
                          CASE WHEN @durationAccuracy = 'ns'  THEN DATEDIFF(ns,  StartStep, EndStep)
                               WHEN @durationAccuracy = 'mcs' THEN DATEDIFF(mcs, StartStep, EndStep)
                               WHEN @durationAccuracy = 'ms'  THEN DATEDIFF(ms,  StartStep, EndStep)
                               WHEN @durationAccuracy = 'ss'  THEN DATEDIFF(ss,  StartStep, EndStep)
                               WHEN @durationAccuracy = 'mi'  THEN DATEDIFF(mi,  StartStep, EndStep)
                               WHEN @durationAccuracy = 'hh'  THEN DATEDIFF(hh,  StartStep, EndStep)
                               WHEN @durationAccuracy = 'dd'  THEN DATEDIFF(dd,  StartStep, EndStep)
                               WHEN @durationAccuracy = 'wk'  THEN DATEDIFF(wk,  StartStep, EndStep)
                               ELSE 0
                          END AS TMAX
                   FROM @BenchmarkTSQL
                   ORDER BY TMAX DESC
                  ) AS TopHalf
             )
         ) / 2.0;
    END;

    DECLARE @endTime datetime2(7) = CASE WHEN @dateTimeFunction = 'SYSDATETIME'    THEN SYSDATETIME()
                                         WHEN @dateTimeFunction = 'SYSUTCDATETIME' THEN SYSUTCDATETIME()
                                    END;

    /* Using RAISEEROR for interactive step printing http://sqlity.net/en/984/print-vs-raiserror/ */
    SET @raiseError = @crlf +
         'Min: '       + CAST(@min AS varchar(30)) + @durationAccuracy +
         ', Max: '     + CAST(@max AS varchar(30)) + @durationAccuracy +
         ', Average: ' + CAST(@avg AS varchar(30)) + @durationAccuracy +
         CASE WHEN @calcMedian = 1 THEN ', Median: ' + CAST(@median AS varchar(30)) + @durationAccuracy ELSE '' END +
         @crlf +
         'Benchmark ended at ' + CONVERT(varchar(23), @endTime, 121) +
         ' by ' + @originalLogin;
    RAISERROR(@raiseError, 0, 1) WITH NOWAIT;

    DECLARE @benchmarkDuration bigint = CASE WHEN @durationAccuracy = 'ns'  THEN DATEDIFF(ns,  @startBenchmark, @endBenchmark)
                                             WHEN @durationAccuracy = 'mcs' THEN DATEDIFF(mcs, @startBenchmark, @endBenchmark)
                                             WHEN @durationAccuracy = 'ms'  THEN DATEDIFF(ms,  @startBenchmark, @endBenchmark)
                                             WHEN @durationAccuracy = 'ss'  THEN DATEDIFF(ss,  @startBenchmark, @endBenchmark)
                                             WHEN @durationAccuracy = 'mi'  THEN DATEDIFF(mi,  @startBenchmark, @endBenchmark)
                                             WHEN @durationAccuracy = 'hh'  THEN DATEDIFF(hh,  @startBenchmark, @endBenchmark)
                                             WHEN @durationAccuracy = 'dd'  THEN DATEDIFF(dd,  @startBenchmark, @endBenchmark)
                                             WHEN @durationAccuracy = 'wk'  THEN DATEDIFF(wk,  @startBenchmark, @endBenchmark)
                                             ELSE 0
                                        END;

    /* Using RAISEEROR for interactive step printing http://sqlity.net/en/984/print-vs-raiserror/ */
    SET @raiseError = @crlf + 'Duration of benchmark: ' +  CAST(@benchmarkDuration AS varchar(30)) + @durationAccuracy + '.'  + @crlf + + @crlf;
    RAISERROR(@raiseError, 0, 1) WITH NOWAIT;

END TRY

BEGIN CATCH
    PRINT('Error: '       + CONVERT(varchar(50), ERROR_NUMBER())  +
          ', Severity: '  + CONVERT(varchar(5), ERROR_SEVERITY()) +
          ', State: '     + CONVERT(varchar(5), ERROR_STATE())    +
          ', Procedure: ' + ISNULL(ERROR_PROCEDURE(), '-')        +
          ', Line: '      + CONVERT(varchar(5), ERROR_LINE())     +
          ', User name: ' + CONVERT(sysname, ORIGINAL_LOGIN())
          );
    PRINT(ERROR_MESSAGE());

    IF ERROR_NUMBER() = 535
    PRINT('Your @durationAccuracy = ' + @durationAccuracy +
    '. Try to use @durationAccuracy with a less precise datepart - seconds (ss) or minutes (mm) or days (dd).' + @crlf +
    'But in log table master.dbo.BenchmarkTSQL (if you run stored procedure with @saveResult = 1) all times saving with datetime2(7) precise!' + @crlf +
    'You can manualy calculate difference after decreasing precise datepart.' + @crlf +
    'For analyze log table see latest example in document section.') + @crlf + + @crlf;
END CATCH;
GO

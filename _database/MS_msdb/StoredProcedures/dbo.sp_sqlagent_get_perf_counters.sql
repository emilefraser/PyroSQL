SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_sqlagent_get_perf_counters
  @all_counters BIT = 0
AS
BEGIN

  SET NOCOUNT ON

  -- 32 bit fraction counter types
  DECLARE @perfTypeRawFraction INT
  DECLARE @perfTypeRawBase     INT

  -- A counter of type PERF_RAW_FRACTION, which is a 32-bit counter value.
  SET @perfTypeRawFraction = 537003008 --  In hex, 0x20020400.

   -- A count of type PERF_RAW_BASE, which is the 32-bit divisor used
   -- when handling PERF_RAW_FRACTION types. This counter type should
   -- not be displayed to the user since it is used for mathematical
   -- operations.
  SET @perfTypeRawBase     = 1073939459 -- In hex, 0x40030403.


  -- 64 bit fraction counter types
  DECLARE @perfTypeLargeRawFraction INT
  DECLARE @perfTypeLargeRawBase     INT

  -- A counter of type PERF_LARGE RAW_FRACTION, which is a 64-bit counter value.
  SET @perfTypeLargeRawFraction = 537003264 --  In hex, 0x20020500.

   -- A count of type PERF_LARGE_RAW_BASE, which is the 64-bit divisor used
   -- when handling PERF_LARGE_RAW_FRACTION types. This counter type should
   -- not be displayed to the user since it is used for mathematical
   -- operations.
  SET @perfTypeLargeRawBase     = 1073939712 -- In hex, 0x40030500.



  IF (@all_counters = 0)
  BEGIN
        SELECT  spi1.object_name,
                spi1.counter_name,
                'instance_name' = CASE spi1.instance_name
                                    WHEN N'' THEN NULL
                                    ELSE spi1.instance_name
                                    END,
                'value' = CASE spi1.cntr_type
                            WHEN @perfTypeRawFraction -- 32 bit fraction
                                THEN CONVERT(FLOAT, spi1.cntr_value) / (SELECT CASE spi2.cntr_value
                                                                            WHEN 0 THEN 1
                                                                            ELSE spi2.cntr_value
                                                                            END
                                                                        FROM sysalerts_performance_counters_view spi2
                                                                        WHERE (RTRIM(spi1.counter_name) + ' ' = SUBSTRING(spi2.counter_name, 1, PATINDEX('% base%', LOWER(spi2.counter_name))))
                                                                        AND spi1.object_name = spi2.object_name
                                                                        AND spi1.server_name = spi2.server_name
                                                                        AND spi1.instance_name = spi2.instance_name
                                                                        AND spi2.cntr_type = @perfTypeRawBase
                                                                        )
                            WHEN @perfTypeLargeRawFraction  -- 64 bit fraction
                                THEN CONVERT(FLOAT, spi1.cntr_value) / (SELECT CASE spi2.cntr_value
                                                                            WHEN 0 THEN 1
                                                                            ELSE spi2.cntr_value
                                                                            END
                                                                        FROM sysalerts_performance_counters_view spi2
                                                                        WHERE (RTRIM(spi1.counter_name) + ' ' = SUBSTRING(spi2.counter_name, 1, PATINDEX('% base%', LOWER(spi2.counter_name))))
                                                                        AND spi1.object_name = spi2.object_name
                                                                        AND spi1.server_name = spi2.server_name
                                                                        AND spi1.instance_name = spi2.instance_name
                                                                        AND spi2.cntr_type = @perfTypeLargeRawBase
                                                                        )
                                ELSE spi1.cntr_value
                            END,
       'type' = spi1.cntr_type,
        spi1.server_name
        FROM sysalerts_performance_counters_view spi1,
        (
                SELECT DISTINCT
                    SUBSTRING(performance_condition,
                                PATINDEX('%:%', performance_condition) + 1,
                                CHARINDEX('|', performance_condition,
                                            PATINDEX('%_|_%', performance_condition) + 2)-(PATINDEX('%:%', performance_condition) + 1
                                         )
                             )
                AS performance_condition_s
                FROM msdb.dbo.sysalerts
                WHERE performance_condition IS NOT NULL
                AND ISNULL(event_id, 0) <> 8 -- exclude WMI events that reuse performance_condition field
                AND enabled = 1
        ) tmp -- We want to select only those counters that have an enabled performance sysalert
        WHERE spi1.cntr_type <> @perfTypeRawBase      -- ignore 32-bit denominator counter type
        AND spi1.cntr_type <> @perfTypeLargeRawBase      -- ignore 64-bit denominator counter type
        AND tmp.performance_condition_s = (spi1.object_name + '|' + spi1.counter_name)
        OPTION (HASH JOIN, LOOP JOIN) -- Avoid merge join when small number of alerts are defined
  END
  ELSE
  BEGIN
        SELECT  spi1.object_name,
                spi1.counter_name,
                'instance_name' = CASE spi1.instance_name
                                    WHEN N'' THEN NULL
                                    ELSE spi1.instance_name
                                    END,
                'value' = CASE spi1.cntr_type
                            WHEN @perfTypeRawFraction -- 32 bit fraction
                            THEN CONVERT(FLOAT, spi1.cntr_value) / (SELECT CASE spi2.cntr_value
                                                                        WHEN 0 THEN 1
                                                                        ELSE spi2.cntr_value
                                                                        END
                                                                    FROM sysalerts_performance_counters_view spi2
                                                                    WHERE (RTRIM(spi1.counter_name) + ' ' = SUBSTRING(spi2.counter_name, 1, PATINDEX('% base%', LOWER(spi2.counter_name))))
                                                                    AND spi1.object_name = spi2.object_name
                                                                    AND spi1.server_name = spi2.server_name
                                                                    AND spi1.instance_name = spi2.instance_name
                                                                    AND spi2.cntr_type = @perfTypeRawBase
                                                                    )
                            WHEN @perfTypeLargeRawFraction  -- 64 bit fraction
                            THEN CONVERT(FLOAT, spi1.cntr_value) / (SELECT CASE spi2.cntr_value
                                                                        WHEN 0 THEN 1
                                                                        ELSE spi2.cntr_value
                                                                        END
                                                                    FROM sysalerts_performance_counters_view spi2
                                                                    WHERE (RTRIM(spi1.counter_name) + ' ' = SUBSTRING(spi2.counter_name, 1, PATINDEX('% base%', LOWER(spi2.counter_name))))
                                                                    AND spi1.object_name = spi2.object_name
                                                                    AND spi1.server_name = spi2.server_name
                                                                    AND spi1.instance_name = spi2.instance_name
                                                                    AND spi2.cntr_type = @perfTypeLargeRawBase
                                                                    )
                            ELSE spi1.cntr_value
                        END,
                'type' = spi1.cntr_type,
                spi1.server_name
        FROM sysalerts_performance_counters_view spi1
        WHERE spi1.cntr_type <> @perfTypeRawBase      -- ignore 32-bit denominator counter type
        AND spi1.cntr_type <> @perfTypeLargeRawBase -- ignore 64-bit denominator counter type
  END
END


GO

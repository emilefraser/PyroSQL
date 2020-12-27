/*
This script is given &quot;As Is&quot; with no warranties and plenty of caveats. Use at your own risk!
For more on data profiling, see Chapter 10 in &quot;SQL Server 2012 Data Integration Recipes&quot;, Apress, 2012
*/
-----------------------------------------------------------------------
-- User-defined variables
-----------------------------------------------------------------------
USE CarSales -- Your database here
GO
DECLARE @TABLE_SCHEMA NVARCHAR(128) = &#39;dbo&#39;  -- Your schema here
DECLARE @TABLE_NAME NVARCHAR(128) = &#39;client&#39; -- Your table here
DECLARE @ColumnListIN NVARCHAR(4000) = &#39;&#39;    -- Enter a comma-separated list of specific columns
                                                     -- to profile, or leave blank for all
DECLARE @TextCol BIT = 1  -- Analyse all text (char/varchar/nvarchar) data type columns
DECLARE @NumCol BIT = 1   -- Analyse all numeric data type columns
DECLARE @DateCol BIT = 1  -- Analyse all date data type data type columns
DECLARE @LobCol BIT = 1   -- Analyse all VAR(char/nchar/binary) MAX data type columns (potentially time-consuming)
DECLARE @AdvancedAnalysis BIT = 1 -- Perform advanced analysis (threshold counts/domain analysis) 
                                  --(potentially time-consuming)
DECLARE @DistinctValuesMinimum INT = 200 -- Minimum number of distinct values to suggest a reference 
                                         -- table and/or perform domain analysis
DECLARE @BoundaryPercent NUMERIC(3,2) = 0.57 -- Percent of records at upper/lower threshold to suggest
                                             -- a possible anomaly
DECLARE @NullBoundaryPercent NUMERIC(5,2) = 90.00 -- Percent of NULLs to suggest a possible anomaly
DECLARE @DataTypePercentage INT = 2 -- Percentage variance allowed when suggesting another data type 
                                    -- for a column
-----------------------------------------------------------------------
-- Process variables
-----------------------------------------------------------------------
DECLARE @DATA_TYPE VARCHAR(128) = &#39;&#39;
DECLARE @FULLSQL VARCHAR(MAX) = &#39;&#39;
DECLARE @SQLMETADATA VARCHAR(MAX) = &#39;&#39;
DECLARE @NUMSQL VARCHAR(MAX) = &#39;&#39;
DECLARE @DATESQL VARCHAR(MAX) = &#39;&#39;
DECLARE @LOBSQL VARCHAR(MAX) = &#39;&#39;
DECLARE @COLUMN_NAME VARCHAR(128)
DECLARE @CHARACTER_MAXIMUM_LENGTH INT
DECLARE @ROWCOUNT BIGINT = 0
DECLARE @ColumnList VARCHAR(4000) = &#39; &#39;
DECLARE @TableCheck TINYINT
DECLARE @ColumnCheck SMALLINT
DECLARE @DataTypeVariance INT
-----------------------------------------------------------------------

-- Start the process:
BEGIN
TRY
-- Test that the schema and table exist
SELECT
 @TableCheck = COUNT (*) 
   FROM INFORMATION_SCHEMA.TABLES 
   WHERE TABLE_SCHEMA = @TABLE_SCHEMA 
   AND TABLE_NAME = @TABLE_NAME

IF @TableCheck &lt;&gt; 1
 BEGIN
  RAISERROR (&#39;The table does not exist&#39;,16,1)
  RETURN
 END
-----------------------------------------------------------------------
-- Parse list of columns to process / get list of columns according to types required
-----------------------------------------------------------------------
IF OBJECT_ID(&#39;tempdb..#ColumnList&#39;) IS NOT NULL
 DROP TABLE tempdb..#ColumnList;

CREATE TABLE #ColumnList (COLUMN_NAME VARCHAR(128), DATA_TYPE VARCHAR(128), CHARACTER_MAXIMUM_LENGTH INT) -- Used to hold list of columns to process
IF @ColumnListIN &lt;&gt; &#39;&#39; -- See if there is a list of columns to process
BEGIN
 -- Process list
 SET @ColumnList = @ColumnListIN + &#39;,&#39;
 DECLARE @CharPosition int
 WHILE CHARINDEX(&#39;,&#39;, @ColumnList) &gt; 0
  BEGIN
   SET @CharPosition = CHARINDEX(&#39;,&#39;, @ColumnList)
   INSERT INTO #ColumnList (COLUMN_NAME) VALUES (LTRIM(RTRIM(LEFT(@ColumnList, @CharPosition - 1))))
   SET @ColumnList = STUFF(@ColumnList, 1, @CharPosition, &#39;&#39;)
  END -- While loop
-- update with datatype and length

  UPDATE CL
   SET CL.CHARACTER_MAXIMUM_LENGTH = ISNULL(ISC.CHARACTER_MAXIMUM_LENGTH,0)
      ,CL.DATA_TYPE = ISC.DATA_TYPE
   FROM #ColumnList CL
   INNER JOIN INFORMATION_SCHEMA.COLUMNS ISC
     ON CL.COLUMN_NAME = ISC.COLUMN_NAME
  WHERE ISC.TABLE_NAME = @TABLE_NAME
  AND ISC.TABLE_SCHEMA = @TABLE_SCHEMA
 END
-- If test for list of column names
ELSE
 BEGIN
 -- Use all column names, to avoid filtering
  IF @TextCol = 1
   BEGIN
    INSERT INTO #ColumnList (COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH)
     SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS
     WHERE DATA_TYPE IN (&#39;varchar&#39;, &#39;nvarchar&#39;, &#39;char&#39;, &#39;nchar&#39;, &#39;binary&#39;)
     AND TABLE_NAME = @TABLE_NAME
     AND TABLE_SCHEMA = @TABLE_SCHEMA
     AND CHARACTER_MAXIMUM_LENGTH &gt; 0
   END
 IF @NumCol = 1
  BEGIN
   INSERT INTO #ColumnList (COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH)
   SELECT COLUMN_NAME, DATA_TYPE, ISNULL(CHARACTER_MAXIMUM_LENGTH,0) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE DATA_TYPE IN (&#39;numeric&#39;, &#39;int&#39;, &#39;bigint&#39;, &#39;tinyint&#39;, &#39;smallint&#39;, &#39;decimal&#39;, &#39;money&#39;, &#39;smallmoney&#39;, &#39;float&#39;,&#39;real&#39;)
   AND TABLE_NAME = @TABLE_NAME
   AND TABLE_SCHEMA = @TABLE_SCHEMA
  END
 IF @DateCol = 1
  BEGIN
   INSERT INTO #ColumnList (COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH)
   SELECT COLUMN_NAME, DATA_TYPE, ISNULL(CHARACTER_MAXIMUM_LENGTH,0) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE DATA_TYPE IN (&#39;Date&#39;, &#39;DateTime&#39;, &#39;SmallDateTime&#39;, #39;DateTime2&#39;, &#39;time&#39;)
   AND TABLE_NAME = @TABLE_NAME
   AND TABLE_SCHEMA = @TABLE_SCHEMA
  END

IF @LOBCol = 1
 BEGIN
  INSERT INTO #ColumnList (COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH)
   SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS
   WHERE DATA_TYPE IN (&#39;varchar&#39;, &#39;nvarchar&#39;, &#39;varbinary&#39;, &#39;xml&#39;)
   AND TABLE_NAME = @TABLE_NAME
   AND TABLE_SCHEMA = @TABLE_SCHEMA
   AND CHARACTER_MAXIMUM_LENGTH = -1
 END
END
-- Else test to get all column names
-----------------------------------------------------------------------

-- Test that there are columns to analyse
SELECT @ColumnCheck = COUNT (*) FROM #ColumnList WHERE DATA_TYPE IS NOT NULL
IF @ColumnCheck = 0
 BEGIN
  RAISERROR(&#39;The columns do not exist in the selected database or no columns are selected&#39;,16,1)
  RETURN
 END
-----------------------------------------------------------------------
-- Create Temp table used to hold profiling data
-----------------------------------------------------------------------
IF OBJECT_ID(&#39;tempdb..#ProfileData&#39;) IS NOT NULL
 DROP TABLE tempdb..#ProfileData;
 CREATE TABLE #ProfileData
 (
  TABLE_SCHEMA NVARCHAR(128),
  TABLE_NAME NVARCHAR(128),
  COLUMN_NAME NVARCHAR(128),
  ColumnDataLength INT,
  DataType VARCHAR(128),
  MinDataLength BIGINT,
  MaxDataLength BIGINT,
  AvgDataLength BIGINT,
  MinDate SQL_VARIANT,
  MaxDate SQL_VARIANT,
  NoDistinct BIGINT,
  NoNulls NUMERIC(32,4),
  NoZeroLength NUMERIC(32,4),
  PercentageNulls NUMERIC(9,4),
  PercentageZeroLength NUMERIC(9,4),
  NoDateWithHourminuteSecond BIGINT NULL,
  NoDateWithSecond BIGINT NULL,
  NoIsNumeric BIGINT NULL,
  NoIsDate BIGINT NULL,
  NoAtLimit BIGINT NULL,
  IsFK BIT NULL DEFAULT 0,
  DataTypeComments NVARCHAR(1500)
 );
-- Get row count
DECLARE @ROWCOUNTTEXT NVARCHAR(1000) = &#39;&#39;
DECLARE @ROWCOUNTPARAM NVARCHAR(50) = &#39;&#39;

SET @ROWCOUNTTEXT = &#39;SELECT @ROWCOUNTOUT = COUNT (*) FROM &#39; + QUOTENAME(@TABLE_SCHEMA) + &#39;.&#39; + QUOTENAME(@TABLE_NAME) + &#39; WITH (NOLOCK)&#39;
SET @ROWCOUNTPARAM = &#39;@ROWCOUNTOUT INT OUTPUT&#39;

EXECUTE sp_executesql @ROWCOUNTTEXT, @ROWCOUNTPARAM, @ROWCOUNTOUT = @ROWCOUNT OUTPUT
-----------------------------------------------------------------------
-- Test that there are records to analyse
IF @ROWCOUNT = 0
 BEGIN
  RAISERROR(&#39;There is no data in the table to analyse&#39;,16,1)
  RETURN
 END
-----------------------------------------------------------------------
-- Define the dynamic SQL used for each column to analyse
-----------------------------------------------------------------------
SET @SQLMETADATA = &#39;INSERT INTO #ProfileData (ColumnDataLength,COLUMN_NAME,TABLE_SCHEMA,TABLE_NAME,DataType,MaxDataLength,MinDataLength,AvgDataLength,MaxDate,MinDate,NoDateWithHourminuteSecond,NoDateWithSecond,NoIsNumeric,NoIsDate,NoNulls,NoZeroLength,NoDistinct)&#39;

DECLARE SQLMETADATA_CUR CURSOR LOCAL FAST_FORWARD FOR 
 SELECT COLUMN_NAME, CHARACTER_MAXIMUM_LENGTH, DATA_TYPE FROM #ColumnList

OPEN SQLMETADATA_CUR 
FETCH NEXT FROM SQLMETADATA_CUR INTO @COLUMN_NAME, @CHARACTER_MAXIMUM_LENGTH, @DATA_TYPE 

WHILE @@FETCH_STATUS = 0 
 BEGIN 
  SET @SQLMETADATA = @SQLMETADATA +&#39;
  SELECT TOP 100 PERCENT &#39; + CAST(@CHARACTER_MAXIMUM_LENGTH AS VARCHAR(20)) + &#39; ,&#39;&#39;&#39; + QUOTENAME(@COLUMN_NAME) + &#39;&#39;&#39;
  ,&#39;&#39;&#39; + QUOTENAME(@TABLE_SCHEMA) + &#39;&#39;&#39;
  ,&#39;&#39;&#39; + QUOTENAME(@TABLE_NAME) + &#39;&#39;&#39;
  ,&#39;&#39;&#39; + @DATA_TYPE + &#39;&#39;&#39;&#39;
   + CASE
      WHEN @DATA_TYPE IN (&#39;varchar&#39;, &#39;nvarchar&#39;, &#39;char&#39;, &#39;nchar&#39;) 
	   AND @CHARACTER_MAXIMUM_LENGTH &gt;= 0 
	     THEN + &#39;
  , MAX(LEN(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;)) 
  , MIN(LEN(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;)) 
  , AVG(LEN(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;))
  ,NULL
  ,NULL 
  ,NULL 
  ,NULL 
  ,(SELECT COUNT (*) from &#39;
   + QUOTENAME(@TABLE_SCHEMA) + &#39;.&#39; + QUOTENAME(@TABLE_NAME) + &#39; WHERE ISNUMERIC(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;) = 1) 
  ,(SELECT COUNT (*) from &#39; + QUOTENAME(@TABLE_SCHEMA) + &#39;.&#39; + QUOTENAME(@TABLE_NAME) + &#39; WHERE ISDATE(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;) = 1) &#39;
  WHEN @DATA_TYPE IN (&#39;numeric&#39;, &#39;int&#39;, &#39;bigint&#39;, &#39;tinyint&#39;, &#39;smallint&#39;, &#39;decimal&#39;, &#39;money&#39;, &#39;smallmoney&#39;, &#39;float&#39;,&#39;real&#39;) THEN + &#39;
  ,MAX(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;) 
  ,MIN(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;) 
  ,AVG(CAST(&#39; + QUOTENAME(@COLUMN_NAME) + &#39; AS NUMERIC(36,2)))
  ,NULL
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL &#39;
   WHEN @DATA_TYPE IN (&#39;DateTime&#39;, &#39;SmallDateTime&#39;) THEN + &#39;
  ,NULL 
  ,NULL 
  ,NULL 
  ,MAX(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;) 
  ,MIN(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;)
  ,(SELECT COUNT (*) from &#39; 
   + QUOTENAME(@TABLE_SCHEMA) + &#39;.&#39; + QUOTENAME(@TABLE_NAME) + &#39; WHERE (CONVERT(NUMERIC(20,12), &#39; + QUOTENAME(@COLUMN_NAME) + &#39; ) - FLOOR(CONVERT(NUMERIC(20,12), &#39; + QUOTENAME(@COLUMN_NAME) + &#39;)) &lt;&gt; 0))
  ,(SELECT COUNT (*) from &#39;
   + QUOTENAME(@TABLE_SCHEMA) + &#39;.&#39; + QUOTENAME(@TABLE_NAME) + &#39; WHERE DATEPART(ss,&#39; + QUOTENAME(@COLUMN_NAME) + &#39;) &lt;&gt; 0 OR DATEPART(mcs,&#39; + QUOTENAME(@COLUMN_NAME) + &#39;) &lt;&gt; 0) 
  ,NULL 
  ,NULL &#39;
    WHEN @DATA_TYPE IN (&#39;DateTime2&#39;) THEN + &#39;
  ,NULL 
  ,NULL 
  ,NULL 
  ,MAX(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;) 
  ,MIN(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;)
  ,NULL
  ,NULL
  ,NULL 
  ,NULL &#39;
   WHEN @DATA_TYPE IN (&#39;Date&#39;) THEN + &#39;
  ,NULL 
  ,NULL 
  ,NULL 
  ,MAX(&#39;
   + QUOTENAME(@COLUMN_NAME) + &#39;) 
  ,MIN(&#39;
  + QUOTENAME(@COLUMN_NAME) + &#39;)
  ,NULL 
  ,NLL 
  ,NULL 
  ,NULL &#39;
   WHEN @DATA_TYPE IN (&#39;xml&#39;) THEN + &#39;
  ,MAX(LEN(CAST(&#39; + QUOTENAME(@COLUMN_NAME) + &#39; AS NVARCHAR(MAX)))) 
  ,MIN(LEN(CAST(&#39; + QUOTENAME(@COLUMN_NAME) + &#39; AS NVARCHAR(MAX)))) 
  ,AVG(LEN(CAST(&#39; + QUOTENAME(@COLUMN_NAME) + &#39; AS NVARCHAR(MAX)))) 
  ,NULL
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL &#39;
  WHEN @DATA_TYPE IN (&#39;varbinary&#39;,&#39;varchar&#39;,&#39;nvarchar&#39;) AND  @CHARACTER_MAXIMUM_LENGTH = -1 THEN + &#39;
  ,MAX(LEN(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;)) 
  ,MIN(LEN(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;)) 
  ,AVG(LEN(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;))
  ,NULL
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL &#39;
   WHEN @DATA_TYPE IN (&#39;binary&#39;) THEN + &#39;
  ,MAX(LEN(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;)) 
  ,MIN(LEN(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;)) 
  ,AVG(LEN(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;))
  ,NULL
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL &#39;
   WHEN @DATA_TYPE IN (&#39;time&#39;) THEN + &#39;
  ,NULL 
  ,NULL 
  ,NULL 
  ,MAX(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;) 
  ,MIN(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;)
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL &#39;
   ELSE + &#39;
  ,NULL 
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,NULL 
  ,NULL 
  ,NULL 
  ,NULL &#39;
  END + &#39;
  ,(SELECT COUNT(*) FROM &#39; + QUOTENAME(@TABLE_SCHEMA) + &#39;.&#39; + QUOTENAME(@TABLE_NAME) + &#39; WHERE &#39; + QUOTENAME(@COLUMN_NAME) + &#39; IS NULL)&#39;
   + CASE
   WHEN @DATA_TYPE IN (&#39;varchar&#39;, &#39;nvarchar&#39;, &#39;char&#39;, &#39;nchar&#39;) THEN + &#39;
  ,(SELECT COUNT(*) FROM &#39; + QUOTENAME(@TABLE_SCHEMA) + &#39;.&#39; + QUOTENAME(@TABLE_NAME) +  &#39; WHERE LEN(LTRIM(RTRIM(&#39; + QUOTENAME(@COLUMN_NAME) + &#39;))) = &#39;&#39;&#39;&#39;)&#39;
   ELSE + &#39;
  ,NULL&#39;
   END + &#39;
  ,(SELECT COUNT(DISTINCT &#39; + QUOTENAME(@COLUMN_NAME) + &#39;) FROM &#39; + QUOTENAME(@TABLE_SCHEMA) + &#39;.&#39; + QUOTENAME(@TABLE_NAME) + &#39; WHERE &#39; + QUOTENAME(@COLUMN_NAME) + &#39; IS NOT NULL )
  FROM &#39; + QUOTENAME(@TABLE_SCHEMA) + &#39;.&#39; + QUOTENAME(@TABLE_NAME) + &#39; WITH (NOLOCK)
  UNION&#39;

 FETCH NEXT FROM SQLMETADATA_CUR INTO @COLUMN_NAME, @CHARACTER_MAXIMUM_LENGTH, @DATA_TYPE 

END 

CLOSE SQLMETADATA_CUR 
DEALLOCATE SQLMETADATA_CUR 

SET @SQLMETADATA = LEFT(@SQLMETADATA, LEN(@SQLMETADATA) -5)

EXEC (@SQLMETADATA)
-----------------------------------------------------------------------
-- Final Calculations
-----------------------------------------------------------------------
-- Indicate Foreign Keys
; WITH FK_CTE (FKColumnName)
AS
(
 SELECT
   DISTINCT CU.COLUMN_NAME
  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
   INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE CU
     ON TC.CONSTRAINT_NAME = CU.CONSTRAINT_NAME 
     AND TC.TABLE_SCHEMA = CU.TABLE_SCHEMA 
     AND TC.TABLE_NAME = CU.TABLE_NAME
     AND TC.TABLE_SCHEMA = @TABLE_SCHEMA
     AND TC.TABLE_NAME = @TABLE_NAME
     AND CONSTRAINT_TYPE = &#39;FOREIGN KEY&#39;
)
UPDATE P
 SET P.IsFK = 1
 FROM #ProfileData P
  INNER JOIN FK_CTE CTE
   ON P.COLUMN_NAME = CTE.FKColumnName
-- Calculate percentages
UPDATE #ProfileData
 SET PercentageNulls = (NoNulls / @ROWCOUNT) * 100
    ,PercentageZeroLength = (NoZeroLength / @ROWCOUNT) * 100
-- Add any comments
-- Datatype suggestions
-- First get number of records where a variation could be an anomaly
SET @DataTypeVariance = ROUND((@ROWCOUNT * @DataTypePercentage) / 100, 0)

UPDATE #ProfileData
  SET DataTypeComments = &#39;Possibly could be one of the DATE types. &#39;
 WHERE NoIsDate BETWEEN (@ROWCOUNT -@DataTypeVariance) AND (@ROWCOUNT + @DataTypeVariance)
 AND DataType IN (&#39;varchar&#39;, &#39;nvarchar&#39;, &#39;char&#39;, &#39;nchar&#39;)

UPDATE #ProfileData
  SET DataTypeComments = &#39;Possibly could be one of the NUMERIC types. &#39;
 WHERE NoIsNumeric BETWEEN (@ROWCOUNT -@DataTypeVariance) AND (@ROWCOUNT + @DataTypeVariance)
 AND DataType IN (&#39;varchar&#39;, &#39;nvarchar&#39;, &#39;char&#39;, &#39;nchar&#39;)

UPDATE #ProfileData
  SET DataTypeComments = &#39;Possibly could be INT type. &#39;
 WHERE MinDataLength &gt;= -2147483648
 AND MaxDataLength &lt;= 2147483648
 AND DataType IN (&#39;bigint&#39;)
 
UPDATE #ProfileData
  SET DataTypeComments = &#39;Possibly could be SMALLINT type. &#39;
 WHERE MinDataLength &gt;= -32768
 AND MaxDataLength &lt;= 32767
 AND DataType IN (&#39;bigint&#39;,&#39;int&#39;)

UPDATE #ProfileData
  SET DataTypeComments = &#39;Possibly could be TINYINT type. &#39;
 WHERE MinDataLength &gt;= 0
 AND MaxDataLength &lt;= 255
 AND DataType IN (&#39;bigint&#39;,&#39;int&#39;,&#39;smallint&#39;)

UPDATE #ProfileData
  SET DataTypeComments = &#39;Possibly could be SMALLDATE type. &#39;
 WHERE NoDateWithSecond = 0
 AND MinDate &gt;= &#39;19000101&#39;
 AND MaxDate &lt;= &#39;20790606&#39;
 AND DataType IN (&#39;datetime&#39;,&#39;datetime2&#39;)

UPDATE #ProfileData
  SET DataTypeComments = &#39;Possibly could be DATE type (SQL Server 2008 only). &#39;
 WHERE NoDateWithHourminuteSecond = 0
 AND DataType IN (&#39;datetime&#39;,&#39;datetime2&#39;)

UPDATE #ProfileData
  SET DataTypeComments = &#39;Possibly could be DATETIME type. &#39;
 WHERE MinDate &gt;= &#39;17530101&#39;
 AND MaxDate &lt;= &#39;99991231&#39;
 AND DataType IN (&#39;datetime2&#39;)

-- Empty column suggestions
UPDATE #ProfileData
  SET DataTypeComments = ISNULL(DataTypeComments,&#39;&#39;) + &#39;Seems empty - is it required? &#39;
 WHERE (PercentageNulls = 100 OR PercentageZeroLength = 100)
 AND IsFK = 0

-- Null column suggestions
UPDATE #ProfileData
  SET DataTypeComments = ISNULL(DataTypeComments,&#39;&#39;) + &#39;There is a large percentage of NULLs - attention may be required. &#39;
 WHERE PercentageNulls &gt;= @NullBoundaryPercent

-- Distinct value suggestions
UPDATE #ProfileData
  SET DataTypeComments = ISNULL(DataTypeComments,&#39;&#39;) + &#39;Few distinct elements - potential for reference/lookup table (contains NULLs).&#39;
 WHERE NoDistinct &lt; @DistinctValuesMinimum
 AND @ROWCOUNT &gt; @DistinctValuesMinimum
 AND IsFK = 0
 AND PercentageNulls &lt;&gt; 100
 AND NoNulls &lt;&gt; 0

-- FK suggestions
UPDATE #ProfileData
  SET DataTypeComments = ISNULL(DataTypeComments,&#39;&#39;) + &#39;Few distinct elements - potential for Foreign Key.&#39;
 WHERE NoDistinct &lt; @DistinctValuesMinimum
 AND @ROWCOUNT &gt; @DistinctValuesMinimum
 AND IsFK = 0
 AND NoNulls = 0
 AND DataType NOT LIKE &#39;%Date%&#39;
 AND DataType &lt;&gt; &#39;Time&#39;

-- Filestream suggestions
UPDATE #ProfileData
  SET DataTypeComments = &#39;Possibly a good candidate for FILESTREAM (SQL Server 2008 only).&#39;
 WHERE AvgDataLength &gt;= 1000000
 AND DataType IN (&#39;varbinary&#39;)
 AND ColumnDataLength = -1

UPDATE #ProfileData
  SET DataTypeComments = &#39;Possibly not a good candidate for FILESTREAM (SQL Server 2008 only).&#39;
 WHERE AvgDataLength &lt; 1000000
 AND DataType IN (&#39;varbinary&#39;)
 AND ColumnDataLength = -1

-- Sparse Column Suggestions
IF OBJECT_ID(&#39;tempdb..#SparseThresholds&#39;) IS NOT NULL
  DROP TABLE tempdb..#SparseThresholds;

  CREATE TABLE #SparseThresholds (DataType VARCHAR(128), Threshold NUMERIC(9,4))

  INSERT INTO #SparseThresholds (DataType, Threshold)
   VALUES 
    (&#39;tinyint&#39;,86),
    (&#39;smallint&#39;,76),    
    (&#39;int&#39;,64),    
    (&#39;bigint&#39;,52),    
    (&#39;real&#39;,64),    
    (&#39;float&#39;,52),    
    (&#39;money&#39;,64),    
    (&#39;smallmoney&#39;,64),    
    (&#39;smalldatetime&#39;,52),    
    (&#39;datetime&#39;,52),    
    (&#39;uniqueidentifier&#39;,43),    
    (&#39;date&#39;,69),    
    (&#39;datetime2&#39;,52),    
    (&#39;decimal&#39;,42),    
    (&#39;nuumeric&#39;,42),    
    (&#39;char&#39;,60),    
    (&#39;varchar&#39;,60),    
    (&#39;nchar&#39;,60),    
    (&#39;nvarchar&#39;,60),    
    (&#39;binary&#39;,60),    
    (&#39;varbinary&#39;,60),    
    (&#39;xml&#39;,60)    

; WITH Sparse_CTE (COLUMN_NAME, SparseComment)
AS
(
SELECT
  P.COLUMN_NAME
 ,CASE
  WHEN P.PercentageNulls &gt;= T.Threshold THEN &#39;Could benefit from sparse columns. &#39;
  ELSE &#39;&#39;
  END AS SparseComment
FROM #ProfileData P
 INNER JOIN #SparseThresholds T
  ON P.DataType = T.DataType
)
UPDATE PT
  SET PT.DataTypeComments = 
      CASE WHEN PT.DataTypeComments IS NULL THEN CTE.SparseComment
           ELSE ISNULL(PT.DataTypeComments,&#39;&#39;) + CTE.SparseComment + &#39;. &#39;
      END
 FROM #ProfileData PT
  INNER JOIN Sparse_CTE CTE
   ON PT.COLUMN_NAME = CTE.COLUMN_NAME

-----------------------------------------------------------------------
-- Optional advanced analysis
-----------------------------------------------------------------------
IF @AdvancedAnalysis = 1
 BEGIN
-----------------------------------------------------------------------
-- Data at data boundaries
-----------------------------------------------------------------------
  IF OBJECT_ID(&#39;tempdb..#LimitTest&#39;) IS NOT NULL
    DROP TABLE tempdb..#LimitTest;

    CREATE TABLE #LimitTest (COLUMN_NAME VARCHAR(128), NoAtLimit BIGINT);

    DECLARE @advancedtestSQL VARCHAR(MAX) = &#39;INSERT INTO #LimitTest (COLUMN_NAME, NoAtLimit)&#39; + CHAR(13)

    SELECT @advancedtestSQL = @advancedtestSQL + &#39;SELECT &#39;&#39;&#39;+ COLUMN_NAME + &#39;&#39;&#39;, COUNT(&#39;+ COLUMN_NAME + &#39;) FROM &#39; + @TABLE_SCHEMA + &#39;.&#39; + @TABLE_NAME + 
     CASE
       WHEN DataType IN (&#39;numeric&#39;, &#39;int&#39;, &#39;bigint&#39;, &#39;tinyint&#39;, &#39;smallint&#39;, &#39;decimal&#39;, &#39;money&#39;, &#39;smallmoney&#39;, &#39;float&#39;,&#39;real&#39;) THEN &#39; WHERE &#39;+ COLUMN_NAME + &#39; = &#39; + CAST(ISNULL(MaxDataLength,0) AS VARCHAR(40)) + &#39; OR &#39;+ COLUMN_NAME + &#39; = &#39; + CAST(ISNULL(MinDataLength,0) AS VARCHAR(40)) + CHAR(13) + &#39; UNION&#39; + CHAR(13)
       ELSE &#39; WHERE LEN(&#39;+ COLUMN_NAME + &#39;) = &#39; + CAST(ISNULL(MaxDataLength,0) AS VARCHAR(40)) + &#39; OR LEN(&#39;+ COLUMN_NAME + &#39;) = &#39; + CAST(ISNULL(MinDataLength,0) AS VARCHAR(40)) + CHAR(13) + &#39; UNION&#39; + CHAR(13)
     END
    FROM #ProfileData 
    WHERE DataType IN (&#39;numeric&#39;, &#39;int&#39;, &#39;bigint&#39;, &#39;tinyint&#39;, &#39;smallint&#39;, &#39;decimal&#39;, &#39;money&#39;, &#39;smallmoney&#39;, &#39;float&#39;,&#39;real&#39;,&#39;varchar&#39;, &#39;nvarchar&#39;, &#39;char&#39;, &#39;nchar&#39;, &#39;binary&#39;)

    SET @advancedtestSQL = LEFT(@advancedtestSQL,LEN(@advancedtestSQL) -6) 

    EXEC (@advancedtestSQL)

    UPDATE M
      SET M.NoAtLimit = T.NoAtLimit
         ,M.DataTypeComments = 
           CASE
             WHEN CAST(T.NoAtLimit AS NUMERIC(36,2)) / CAST(@ROWCOUNT AS NUMERIC(36,2)) &gt;= @BoundaryPercent THEN ISNULL(M.DataTypeComments,&#39;&#39;) + &#39;Large numbers of data elements at the max/minvalues. &#39;
             ELSE M.DataTypeComments
           END
    FROM #ProfileData M
     INNER JOIN #LimitTest T
      ON M.COLUMN_NAME = T.COLUMN_NAME

   -----------------------------------------------------------------------
   -- Domain analysis
   -----------------------------------------------------------------------
   IF OBJECT_ID(&#39;tempdb..#DomainAnalysis&#39;) IS NOT NULL
     DROP TABLE tempdb..#DomainAnalysis;

   CREATE TABLE #DomainAnalysis
   (
    DomainName NVARCHAR(128)
   ,DomainElement NVARCHAR(4000)
   ,DomainCounter BIGINT
   ,DomainPercent NUMERIC(7,4)
   );

   DECLARE @DOMAINSQL VARCHAR(MAX) = &#39;INSERT INTO #DomainAnalysis (DomainName, DomainElement, DomainCounter) &#39;

   DECLARE SQLDOMAIN_CUR CURSOR LOCAL FAST_FORWARD FOR 
     SELECT COLUMN_NAME, DataType 
	  FROM #ProfileData 
	   WHERE NoDistinct &lt; @DistinctValuesMinimum

   OPEN SQLDOMAIN_CUR 

   FETCH NEXT FROM SQLDOMAIN_CUR INTO @COLUMN_NAME, @DATA_TYPE 

   WHILE @@FETCH_STATUS = 0 
    BEGIN 

     SET @DOMAINSQL = @DOMAINSQL + &#39;SELECT &#39;&#39;&#39; + @COLUMN_NAME + &#39;&#39;&#39; AS DomainName, CAST( &#39;+ @COLUMN_NAME + &#39; AS VARCHAR(4000)) AS DomainElement, COUNT(ISNULL(CAST(&#39; + @COLUMN_NAME + &#39; AS NVARCHAR(MAX)),&#39;&#39;&#39;&#39;)) AS DomainCounter FROM &#39; + @TABLE_SCHEMA + &#39;.&#39; + @TABLE_NAME + &#39; GROUP BY &#39; + @COLUMN_NAME + &#39;&#39;
     + &#39; UNION &#39;

     FETCH NEXT FROM SQLDOMAIN_CUR INTO @COLUMN_NAME, @DATA_TYPE 
   END 

  CLOSE SQLDOMAIN_CUR 

  DEALLOCATE SQLDOMAIN_CUR 

  SET @DOMAINSQL = LEFT(@DOMAINSQL, LEN(@DOMAINSQL) -5) + &#39; ORDER BY DomainName ASC, DomainCounter DESC &#39;

   EXEC (@DOMAINSQL)
   -- Now calculate percentages (this appraoch is faster than doing it when performing the domain analysis)

   ; WITH DomainCounter_CTE (DomainName, DomainCounterTotal)
   AS
  (
   SELECT DomainName, SUM(ISNULL(DomainCounter,0)) AS DomainCounterTotal
    FROM #DomainAnalysis 
    GROUP BY DomainName
  )

  UPDATE D
    SET D.DomainPercent = (CAST(D.DomainCounter AS NUMERIC(36,4)) / CAST(CTE.DomainCounterTotal AS NUMERIC(36,4))) * 100
   FROM #DomainAnalysis D
    INNER JOIN DomainCounter_CTE CTE
     ON D.DomainName = CTE.DomainName
   WHERE D.DomainCounter &lt;&gt; 0
 END

-- Advanced analysis
-----------------------------------------------------------------------
-- Output results from the profile and domain data tables
-----------------------------------------------------------------------

select
   *
 from #ProfileData

IF @AdvancedAnalysis = 1
 BEGIN
  select
    *
   from #DomainAnalysis
 END

END TRY

BEGIN CATCH

 SELECT
  ERROR_NUMBER() AS ErrorNumber
 ,ERROR_SEVERITY() AS ErrorSeverity
 ,ERROR_STATE() AS ErrorState
 ,ERROR_PROCEDURE() AS ErrorProcedure
 ,ERROR_LINE() AS ErrorLine
 ,ERROR_MESSAGE() AS ErrorMessage;
 
END CATCH
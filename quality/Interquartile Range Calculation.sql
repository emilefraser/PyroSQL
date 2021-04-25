CREATE PROCEDURE [Calculations].[InterquartileRangeSP]
@DatabaseName as nvarchar(128) = NULL, @SchemaName as nvarchar(128), @TableName as nvarchar(128),@ColumnName AS nvarchar(128), @PrimaryKeyName as nvarchar(400), @OrderByCode as tinyint = 1, @DecimalPrecision AS nvarchar(50)
AS
SET @DatabaseName = @DatabaseName + ‘.’
DECLARE @SchemaAndTableName nvarchar(400)
SET @SchemaAndTableName = ISNull(@DatabaseName, ”) + @SchemaName + ‘.’ + @TableName
DECLARE @SQLString nvarchar(max)

SET @SQLString = ‘DECLARE @OrderByCode tinyint,
@Count bigint,
@LowerPoint bigint,
@UpperPoint bigint,
@LowerRemainder decimal(38,37), — use the maximum precision and scale for these two variables to make the

procedure flexible enough to handle large datasets; I suppose I could use a float
@UpperRemainder decimal(38,37),
@LowerQuartile decimal(‘ + @DecimalPrecision + ‘),
@UpperQuartile decimal(‘ + @DecimalPrecision + ‘),
@InterquartileRange decimal(‘ + @DecimalPrecision + ‘),
@LowerInnerFence decimal(‘ + @DecimalPrecision + ‘),
@UpperInnerFence decimal(‘ + @DecimalPrecision + ‘),
@LowerOuterFence decimal(‘ + @DecimalPrecision + ‘),
@UpperOuterFence decimal(‘ + @DecimalPrecision + ‘) 

SET @OrderByCode = ‘ + CAST(@OrderByCode AS nvarchar(50)) + ‘ SELECT @Count=Count(‘ + @ColumnName + ‘)
FROM ‘ + @SchemaAndTableName +
‘ WHERE ‘ + @ColumnName + ‘ IS NOT NULL

SELECT @LowerPoint = (@Count + 1) / 4, @LowerRemainder =  ((CAST(@Count AS decimal(‘ + @DecimalPrecision + ‘)) + 1) % 4) /4,
@UpperPoint = ((@Count + 1) *3) / 4, @UpperRemainder =  (((CAST(@Count AS decimal(‘ + @DecimalPrecision + ‘)) + 1) *3) % 4) / 4; –multiply by 3 for the left s’ + @PrimaryKeyName + ‘e on the upper point to get 75 percent

WITH TempCTE
(‘ + @PrimaryKeyName + ‘, RN, ‘ + @ColumnName + ‘)
AS (SELECT ‘ + @PrimaryKeyName + ‘, ROW_NUMBER() OVER (PARTITION BY 1 ORDER BY ‘ + @ColumnName + ‘ ASC) AS RN, ‘ + @ColumnName + ‘
FROM ‘ + @SchemaAndTableName + ‘

WHERE ‘ + @ColumnName + ‘ IS NOT NULL),
TempCTE2 (QuartileValue)
AS (SELECT TOP 1 ‘ + @ColumnName + ‘ + ((Lead(‘ + @ColumnName + ‘, 1) OVER (ORDER BY ‘ + @ColumnName + ‘) – ‘ + @ColumnName + ‘) * @LowerRemainder) AS QuartileValue
FROM TempCTE
WHERE RN BETWEEN @LowerPoint AND @LowerPoint + 1

UNION

SELECT TOP 1 ‘ + @ColumnName + ‘ + ((Lead(‘ + @ColumnName + ‘, 1) OVER (ORDER BY ‘ + @ColumnName + ‘) – ‘ + @ColumnName + ‘) * @UpperRemainder) AS QuartileValue
FROM TempCTE
WHERE RN BETWEEN @UpperPoint AND @UpperPoint + 1)

SELECT @LowerQuartile = (SELECT TOP 1 QuartileValue

FROM TempCTE2 ORDER BY QuartileValue ASC), @UpperQuartile = (SELECT TOP 1 QuartileValue

FROM TempCTE2 ORDER BY QuartileValue DESC)

SELECT @InterquartileRange = @UpperQuartile – @LowerQuartile
SELECT @LowerInnerFence = @LowerQuartile – (1.5 * @InterquartileRange), @UpperInnerFence = @UpperQuartile + (1.5 * @InterquartileRange), @LowerOuterFence = @LowerQuartile – (3 * @InterquartileRange), @UpperOuterFence = @UpperQuartile + (3 * @InterquartileRange)

–SELECT @LowerPoint AS LowerPoint, @LowerRemainder AS LowerRemainder, @UpperPoint AS UpperPoint, @UpperRemainder AS UpperRemainder

— uncomment this line to debug the inner calculations

SELECT @LowerQuartile AS LowerQuartile, @UpperQuartile AS UpperQuartile, @InterquartileRange AS InterQuartileRange,@LowerInnerFence AS LowerInnerFence, @UpperInnerFence AS UpperInnerFence,@LowerOuterFence AS LowerOuterFence, @UpperOuterFence AS UpperOuterFence

SELECT ‘ + @PrimaryKeyName + ‘, ‘ + @ColumnName + ‘, OutlierDegree
FROM  (SELECT ‘ + @PrimaryKeyName + ‘, ‘ + @ColumnName + ‘,
       ”OutlierDegree” =  CASE WHEN (‘ + @ColumnName + ‘ < @LowerInnerFence AND ‘ + @ColumnName + ‘ >= @LowerOuterFence) OR (‘ +
@ColumnName + ‘ > @UpperInnerFence

AND ‘ + @ColumnName + ‘ <= @UpperOuterFence) THEN 1
       WHEN ‘ + @ColumnName + ‘ < @LowerOuterFence OR ‘ + @ColumnName + ‘ > @UpperOuterFence THEN 2
       ELSE 0 END
       FROM ‘ + @SchemaAndTableName + ‘
       WHERE ‘ + @ColumnName + ‘ IS NOT NULL) AS T1
      ORDER BY CASE WHEN @OrderByCode = 1 THEN ‘ + @PrimaryKeyName + ‘ END ASC,
CASE WHEN @OrderByCode = 2 THEN ‘ + @PrimaryKeyName + ‘ END DESC,
CASE WHEN @OrderByCode = 3 THEN ‘ + @ColumnName + ‘ END ASC,
CASE WHEN @OrderByCode = 4 THEN ‘ + @ColumnName + ‘ END DESC,
CASE WHEN @OrderByCode = 5 THEN OutlierDegree END ASC,
CASE WHEN @OrderByCode = 6 THEN OutlierDegree END DESC‘

–SELECT @SQLString — uncomment this to debug string errors
EXEC (@SQLString)
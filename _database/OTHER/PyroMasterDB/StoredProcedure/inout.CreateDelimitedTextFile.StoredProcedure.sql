SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[CreateDelimitedTextFile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[CreateDelimitedTextFile] AS' 
END
GO
-- =============================================
-- Author: Joseph Biggert
-- Date: 03/19/2009
-- Version: 1.6
-- Description:	This SP will create a delimited text file depending on the specified parameters.
-- More Information: http://www.attobase.com
-- Additional Comments: Changing the FirstRow argument to anything greater than 0 will cause the header row be removed from the csv
--						ColumnList should be delimited by a comma and do not include any qualifiers
--						Criteria should NOT include the where keyword
--						DestinationFile will always be overwritten no matter what
--						OtherConnection Parameter is not used
--						If source is a file, it must include a path using the '\' as the separator
--						To specify a Tab character as the delimiter, use the word "TAB" for @Delimiter parameter
-- =============================================
ALTER PROCEDURE [inout].[CreateDelimitedTextFile] 
(
@Source varchar(max),
@DestinationFile varchar(max),
@ColumnList varchar(max) = '',
@Delimiter varchar(256) = ',',
@Qualifier varchar(256) = '"',
@Criteria varchar(max) = '',
@FirstRow int = 0,
@LastRow int = 0,
@Username varchar(256) = '',
@Password varchar(256) = '',
@Server varchar(256) = '',
@SourceType varchar(100) = '',
@SourceTableName varchar(128) = '',
@OtherConnection varchar(max) = ''
)
AS
BEGIN

-- Declare variable
DECLARE @HeaderCount int
DECLARE @Header varchar(MAX)
DECLARE @SQL varchar(MAX)
DECLARE @COLNAME varchar(MAX)
declare @SUBSQL varchar(max)
DECLARE @TEMPVIEWNAME varchar(max)
declare @counter int

-- If TAB is specified as the delimiter, switch to the tab character
IF @Delimiter = 'TAB'
SET @Delimiter = CHAR(9)

-- Otherconnection is not used but kept for future development
SET @OtherConnection = ''

-- Set the name of the temporary view
SET @TEMPVIEWNAME = 'TEMPVIEW'+convert(varchar(max),newid())

begin try

-- Try to figure out the source type in case one is not given and it appears something other than SQL may be given
begin try
IF (charindex('\',@SOURCE) > 0 AND charindex('.', reverse(@SOURCE)) = 4 AND @SourceType='')
BEGIN
	SET @SourceType = SUBSTRING(UPPER(@SOURCE),LEN(@SOURCE)-2,3)
END
ELSE
	SET @SourceType = 'SQL'
end try
begin catch
-- If an error occurs during this time, ignore it and assume SQL source type
	SET @SourceType = 'SQL'
end catch


IF (UPPER(@SourceType) <> 'SQL')
BEGIN
	IF (@OtherConnection <> '')
		-- This will be used in the future but disabled for now from previous set statement (I left this in here because I have a horrible memory!)
		exec ('create view ['+@TEMPVIEWNAME+'-other] as (select * from OpenRowset('+@OtherConnection+'))')
	ELSE
	BEGIN
		-- If the source is a delimited file, create a view to the file
		DECLARE @filepath varchar(256)
		DECLARE @filename varchar(256)
		DECLARE @OtherViewSQL varchar(max)

		-- Get the file path and filename
		select @filepath=reverse(substring(reverse(@Source), charindex('\', reverse(@Source))+1, len(@Source) - charindex('\', reverse(@Source)) ))
		select @filename=reverse(substring(reverse(@Source), 0, charindex('\', reverse(@Source)) ))
		-- Create view to the file using its connector
		If(UPPER(@SourceType) = 'DELIMITED' OR UPPER(@SourceType) = 'CSV' OR Upper(@SourceType) = 'TEXT' OR Upper(@SourceType) = 'TXT')
		exec('create view ['+@TEMPVIEWNAME+'-other] as (select * from OpenRowset(''MSDASQL'', ''Driver={Microsoft Text Driver (*.txt; *.csv)};DefaultDir='+@filepath+';'',''select * from ['+@filename+']''))')
		else if(UPPER(@SourceType) = 'DBF' OR UPPER(@SourceType) = 'DBASE' OR UPPER(@SourceType) = 'DBASE3' OR UPPER(@SourceType) = 'DBASEIII' OR UPPER(@SourceType) = 'DBASE 3' OR UPPER(@SourceType) = 'DBASE III' OR UPPER(@SourceType) = 'FOXPRO')
		exec('create view ['+@TEMPVIEWNAME+'-other] as (select * from OpenRowset(''MSDASQL'', ''Driver={Microsoft dBase Driver (*.dbf)};DBQ='+@filepath+';'',''select * from ['+@filename+']''))')
		else IF(UPPER(@SourceType) = 'ACCESS' OR UPPER(@SourceType) = 'MDB')
		exec('create view ['+@TEMPVIEWNAME+'-other] as (select * from OpenRowset(''MICROSOFT.JET.OLEDB.4.0'', '''+@filepath+'\'+@filename+''' ;;,['+@SourceTableName+']))')
		else IF(UPPER(@SourceType) = 'EXCEL' OR UPPER(@SourceType) = 'XLS')
		exec('create view ['+@TEMPVIEWNAME+'-other] as (select * from OpenRowset(''MICROSOFT.JET.OLEDB.4.0'', ''Excel 8.0;DATABASE='+@filepath+'\'+@filename+''',''select * from ['+@SourceTableName+'$]''))')
	END


-- Set the source table to the new view
SET @Source = @TEMPVIEWNAME+'-other'

END
ELSE
	SET @SourceTableName = @Source

-- Check to see if columnlist is provided
IF (@ColumnList <> '')
	BEGIN
		-- Get header count from columnlist
		SELECT @HeaderCount = ((LEN(RTRIM(LTRIM(@ColumnList))) - LEN(REPLACE(RTRIM(LTRIM(@ColumnList)), ',', '')))+1)

		-- Build delimited file header row
		SELECT @Header = COALESCE(@Header  + ',', '') + 
	    CASE WHEN @Qualifier = '' THEN ' '''+@Qualifier+'''+CASE when isnumeric(['+column_name+']) = 1 AND
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = '''+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+''' 
		and (UPPER(data_type) <> ''VARCHAR'' OR UPPER(data_type) <> ''NVARCHAR'' OR UPPER(data_type) <> ''CHAR'' OR UPPER(data_type) <>''NCHAR'') 
		and Upper(column_name)='''+UPPER(column_name)+''') THEN -1 ELSE 0
		END = 0
		THEN cast(cast(['+column_name+'] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when ['+column_name+'] = '''' THEN NULL ELSE ['+column_name+'] END as varchar(max)) END+'''+@Qualifier+''' as ['+column_name+']'
		ELSE ' '''+@Qualifier+'''+ISNULL(CASE when isnumeric(['+column_name+']) = 1 AND
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = '''+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+''' 
		and (UPPER(data_type) <> ''VARCHAR'' OR UPPER(data_type) <> ''NVARCHAR'' OR UPPER(data_type) <> ''CHAR'' OR UPPER(data_type) <>''NCHAR'') 
		and Upper(column_name)='''+UPPER(column_name)+''') THEN -1 ELSE 0
		END = 0
		THEN cast(cast(['+column_name+'] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when ['+column_name+'] = '''' THEN NULL ELSE ['+column_name+'] END as varchar(max)) END,'''')+'''+@Qualifier+''' as ['+column_name+']'
				END
		FROM ( SELECT column_name, rank() OVER (ORDER BY ordinal_position) as rank
		FROM INFORMATION_SCHEMA.columns
		where UPPER(table_name) = Upper((REPLACE(REPLACE(@Source,'[',''),']',''))) AND charindex(','+column_name+',',RTRIM(LTRIM(','+@ColumnList+','))) > 0
		) t ORDER BY t.rank ASC 

		-- Initialize main view query
		SET @SQL = 'SELECT '

		-- Build main view query
		set @counter = 0
		while @counter < @HeaderCount
			begin
				-- Increase counter
				set @counter = @counter + 1
				-- Get column name
				SELECT TOP 1 @colname = column_name FROM ( SELECT TOP (@counter) column_name, rank() OVER (ORDER BY ordinal_position) as rank
				FROM INFORMATION_SCHEMA.columns
				where UPPER(table_name) = ((Upper((REPLACE(REPLACE(@Source,'[',''),']',''))))) AND charindex(','+column_name+',',RTRIM(LTRIM(','+@ColumnList+','))) > 0
				ORDER BY rank ASC ) as t ORDER BY rank DESC
				-- Add to main view query
				IF @counter = @HeaderCount
					BEGIN
						SET @SQL = @SQL + ''''+@Qualifier+'''+ SUBSTRING(RTRIM(LTRIM('''+@ColumnList+''')),charindex('''+@colname+''',RTRIM(LTRIM('''+@ColumnList+'''))), LEN('''+@colname+'''))+'''+@Qualifier+''' as ['+@colname+'] '
					END
				ELSE
					BEGIN
						SET @SQL = @SQL + ''''+@Qualifier+'''+ SUBSTRING(RTRIM(LTRIM('''+@ColumnList+''')),charindex('''+@colname+''',RTRIM(LTRIM('''+@ColumnList+'''))), LEN('''+@colname+'''))+'''+@Qualifier+''' as ['+@colname+@Delimiter+'], '
					END
			end
	END
ELSE
	BEGIN
		-- Get header count from columnlist
		SELECT @HeaderCount = count(column_name)
		FROM INFORMATION_SCHEMA.columns
		where UPPER(table_name) = Upper((REPLACE(REPLACE(@Source,'[',''),']','')))

		-- Build delimited file header row
		SELECT @Header = COALESCE(@Header  + ',', '') + 
	    CASE WHEN @Qualifier = '' THEN ' '''+@Qualifier+'''+CASE when isnumeric(['+column_name+']) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = '''+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+''' 
		and (UPPER(data_type) <> ''VARCHAR'' OR UPPER(data_type) <> ''NVARCHAR'' OR UPPER(data_type) <> ''CHAR'' OR UPPER(data_type) <>''NCHAR'') 
		and Upper(column_name)='''+UPPER(column_name)+''') THEN -1 ELSE 0
		END = 0
		THEN cast(cast(['+column_name+'] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when ['+column_name+'] = '''' THEN NULL ELSE ['+column_name+'] END as varchar(max)) END+'''+@Qualifier+''' as ['+column_name+']'
		ELSE ' '''+@Qualifier+'''+ISNULL(CASE when isnumeric(['+column_name+']) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = '''+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+''' 
		and (UPPER(data_type) <> ''VARCHAR'' OR UPPER(data_type) <> ''NVARCHAR'' OR UPPER(data_type) <> ''CHAR'' OR UPPER(data_type) <>''NCHAR'') 
		and Upper(column_name)='''+UPPER(column_name)+''') THEN -1 ELSE 0
		END = 0
		THEN cast(cast(['+column_name+'] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when cast(['+column_name+'] as varchar(max)) = '''' THEN NULL ELSE ['+column_name+'] END as varchar(max)) END,'''')+'''+@Qualifier+''' as ['+column_name+']'
		END
		FROM ( SELECT column_name, rank() OVER (ORDER BY ordinal_position) as rank
		FROM INFORMATION_SCHEMA.columns
		where UPPER(table_name) = Upper((REPLACE(REPLACE(@Source,'[',''),']','')))
		) t ORDER BY t.rank ASC 
		-- Initialize main view query
		SET @SQL = 'SELECT '

		-- Build main view query
		set @counter = 0

		while @counter < @HeaderCount
			begin
				-- Increase counter
				set @counter = @counter + 1
				-- Get column name
				SELECT TOP 1 @colname = column_name FROM ( SELECT TOP (@counter) column_name, rank() OVER (ORDER BY ordinal_position) as rank
				FROM INFORMATION_SCHEMA.columns
				where UPPER(table_name) = Upper((REPLACE(REPLACE(@Source,'[',''),']','')))
				ORDER BY rank ASC ) as t ORDER BY rank DESC

				-- Add to main view query
				IF @counter = @HeaderCount
					BEGIN
						SET @SQL = @SQL + ''''+@Qualifier+'''+ cast(min(case ordinal_position when '+cast(@counter as varchar)+' then column_name end) as varchar)+'''+@Qualifier+''' as ['+@colname+'] '
					END
				ELSE
					BEGIN
						SET @SQL = @SQL + ''''+@Qualifier+'''+cast(min(case ordinal_position when '+cast(@counter as varchar)+' then column_name end) as varchar)+'''+@Qualifier+''' as ['+@colname+'], '
					END
			end

		SET @SQL = @SQL + ' from ['+db_name()+'].information_schema.columns where UPPER(table_name) = Upper('''+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+''') '

	END
-- Finish up the main view query
SET @SQL = @SQL + ' union all '
SET @SQL = @SQL + ' select '
SET @SQL = @SQL + @Header + ' FROM ['+db_name()+']..['+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+']'

-- Add criteria if exists
IF (@Criteria <> '')
BEGIN
	SET @SQL = @SQL + ' WHERE '+@Criteria+' '
END

-- Create temporary view
exec('create view ['+@TEMPVIEWNAME+'] as ('+@SQL+')')

-- Execute bcp on temporary view
DECLARE @bcpcmd varchar(8000)
SET @bcpcmd = 'bcp ["'+db_name()+']..['+@TEMPVIEWNAME+']" out "'+@DestinationFile+'" -k -c -t "'+@Delimiter+'"'
-- Add first row and last row arguments to bcp command
IF (@FirstRow > 0)
SET @bcpcmd = @bcpcmd + ' -F '+cast(@FirstRow as varchar)
IF (@LastRow > 0)
SET @bcpcmd = @bcpcmd + ' -L '+cast(@LastRow as varchar)

-- Add server login information
IF (@Username <> '')
BEGIN
	SET @bcpcmd = @bcpcmd + ' -U '+@Username
	IF (@Password <> '')
	SET @bcpcmd = @bcpcmd + ' -P '+@Password
END
ELSE
BEGIN
	SET @bcpcmd = @bcpcmd + ' -T '
END

IF (@Server <> '')
SET @bcpcmd = @bcpcmd + ' -S '+@Server

exec master..xp_cmdshell @bcpcmd

-- Drop temporary view

exec('IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'''+@TEMPVIEWNAME+''')) DROP View ['+@TEMPVIEWNAME+']')
exec('IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'''+@TEMPVIEWNAME+'-other'')) DROP VIEW ['+@TEMPVIEWNAME+'-other]')
end try
begin catch
	-- show error if one occurs
	SELECT 'ERROR: UNABLE TO CREATE DELIMITED TEXT FILE (Reason:' + error_message() + ')'
	begin try
		-- Drop view if an error occurs
		exec('IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'''+@TEMPVIEWNAME+''')) DROP View ['+@TEMPVIEWNAME+']')
		exec('IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'''+@TEMPVIEWNAME+'-other'')) DROP VIEW ['+@TEMPVIEWNAME+'-other]')
	end try
	begin catch
	end catch
end catch
END

GO

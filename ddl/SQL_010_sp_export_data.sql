USE master;
GO
IF OBJECT_ID('dbo.sp_export_data') IS NOT NULL
  DROP PROCEDURE dbo.sp_export_data;
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: Script rows of data as Insert Statements
--#################################################################################################
CREATE PROC [dbo].[sp_export_data]
(
 @table_name VARCHAR(776),    -- The table/view for which the INSERT statements will be generated using the existing data
 @target_table VARCHAR(776) = NULL,  -- Use this parameter to specify a different table name into which the data will be inserted
 @include_column_list BIT = 1,  -- Use this parameter to include/ommit column list in the generated INSERT statement
 @from VARCHAR(MAX) = NULL,   -- Use this parameter to filter the rows based on a filter condition (using WHERE)
 @include_timestamp BIT = 0,   -- Specify 1 for this parameter, if you want to include the TIMESTAMP/ROWVERSION column's data in the INSERT statement
 @debug_mode BIT = 0,   -- If @debug_mode is set to 1, the SQL statements constructed by this procedure will be printed for later examination
 @owner VARCHAR(64) = NULL,  -- Use this parameter if you are not the owner of the table
 @ommit_images BIT = 0,   -- Use this parameter to generate INSERT statements by omitting the 'image' columns
 @ommit_identity BIT = 0,  -- Use this parameter to ommit the identity columns
 @top INT = NULL,   -- Use this parameter to generate INSERT statements only for the TOP n rows
 @cols_to_include VARCHAR(MAX) = NULL, -- List of columns to be included in the INSERT statement
 @cols_to_exclude VARCHAR(MAX) = NULL, -- List of columns to be excluded from the INSERT statement
 @disable_constraints BIT = 0,  -- When 1, disables foreign key constraints and enables them after the INSERT statements
 @ommit_computed_cols BIT = 0  -- When 1, computed columns will not be included in the INSERT statement
 
)
AS
BEGIN

/***********************************************************************************************************
Procedure: sp_export_data/sp_export_data(renamed by scripts@stormrage.com due to minor adaptation)  (Build 22) 
  (Copyright © 2002 Narayana Vyas Kondreddi. All rights reserved.)
                                          
Purpose: To generate INSERT statements from existing data. 
  These INSERTS can be executed to regenerate the data at some other location.
  This procedure is also useful to create a database setup, where in you can 
  script your data along with your table definitions.

Written by: Narayana Vyas Kondreddi
         http://vyaskn.tripod.com

Acknowledgements:
  Divya Kalra -- For beta testing
  Mark Charsley -- For reporting a problem with scripting uniqueidentifier columns with NULL values
  Artur Zeygman -- For helping me simplify a bit of code for handling non-dbo owned tables
  Joris Laperre   -- For reporting a regression bug in handling text/ntext columns

Tested on:  SQL Server 7.0 and SQL Server 2000 and SQL Server 2005

Date created: January 17th 2001 21:52 GMT

Date modified: May 1st 2002 19:50 GMT

Email:   vyaskn@hotmail.com

NOTE:  This procedure may not work with tables with too many columns.
  Results can be unpredictable with huge text columns or SQL Server 2000's sql_variant data types
  Whenever possible, Use @include_column_list parameter to ommit column list in the INSERT statement, for better results
  IMPORTANT: This procedure is not tested with internation data (Extended characters or Unicode). If needed
  you might want to convert the datatypes of character variables in this procedure to their respective unicode counterparts
  like nchar and nvarchar

  ALSO NOTE THAT THIS PROCEDURE IS NOT UPDATED TO WORK WITH NEW DATA TYPES INTRODUCED IN SQL SERVER 2005 / YUKON
  

Example 1: To generate INSERT statements for table 'titles':
  
  EXEC sp_export_data 'titles'

Example 2:  To ommit the column list in the INSERT statement: (Column list is included by default)
  IMPORTANT: If you have too many columns, you are advised to ommit column list, as shown below,
  to avoid erroneous results
  
  EXEC sp_export_data 'titles', @include_column_list = 0

Example 3: To generate INSERT statements for 'titlesCopy' table from 'titles' table:

  EXEC sp_export_data 'titles', 'titlesCopy'

Example 4: To generate INSERT statements for 'titles' table for only those titles 
  which contain the word 'Computer' in them:
  NOTE: Do not complicate the FROM or WHERE clause here. It's assumed that you are good with T-SQL if you are using this parameter

  EXEC sp_export_data 'titles', @from = "from titles where title like '%Computer%'"

Example 5:  To specify that you want to include TIMESTAMP column's data as well in the INSERT statement:
  (By default TIMESTAMP column's data is not scripted)

  EXEC sp_export_data 'titles', @include_timestamp = 1

Example 6: To print the debug information:
  
  EXEC sp_export_data 'titles', @debug_mode = 1

Example 7:  If you are not the owner of the table, use @owner parameter to specify the owner name
  To use this option, you must have SELECT permissions on that table

  EXEC sp_export_data Nickstable, @owner = 'Nick'

Example 8:  To generate INSERT statements for the rest of the columns excluding images
  When using this otion, DO NOT set @include_column_list parameter to 0.

  EXEC sp_export_data imgtable, @ommit_images = 1

Example 9:  To generate INSERT statements excluding (ommiting) IDENTITY columns:
  (By default IDENTITY columns are included in the INSERT statement)

  EXEC sp_export_data mytable, @ommit_identity = 1

Example 10:  To generate INSERT statements for the TOP 10 rows in the table:
  
  EXEC sp_export_data mytable, @top = 10

Example 11:  To generate INSERT statements with only those columns you want:
  
  EXEC sp_export_data titles, @cols_to_include = "'title','title_id','au_id'"

Example 12:  To generate INSERT statements by omitting certain columns:
  
  EXEC sp_export_data titles, @cols_to_exclude = "'title','title_id','au_id'"

Example 13: To avoid checking the foreign key constraints while loading data with INSERT statements:
  
  EXEC sp_export_data titles, @disable_constraints = 1

Example 14:  To exclude computed columns from the INSERT statement:
  EXEC sp_export_data MyTable, @ommit_computed_cols = 1
***********************************************************************************************************/

SET NOCOUNT ON
CREATE TABLE #Results(ID INT IDENTITY NOT NULL PRIMARY KEY,resultstext VARCHAR(MAX) )
--Making sure user only uses either @cols_to_include or @cols_to_exclude
IF ((@cols_to_include IS NOT NULL) AND (@cols_to_exclude IS NOT NULL))
 BEGIN
  RAISERROR('Use either @cols_to_include or @cols_to_exclude. Do not use both the parameters at once',16,1)
  RETURN -1 --Failure. Reason: Both @cols_to_include and @cols_to_exclude parameters are specified
 END

--Making sure the @cols_to_include and @cols_to_exclude parameters are receiving values in proper format
IF ((@cols_to_include IS NOT NULL) AND (PATINDEX('''%''',@cols_to_include) = 0))
 BEGIN
  RAISERROR('Invalid use of @cols_to_include property',16,1)
  PRINT 'Specify column names surrounded by single quotes and separated by commas'
  PRINT 'Eg: EXEC sp_export_data titles, @cols_to_include = "''title_id'',''title''"'
  RETURN -1 --Failure. Reason: Invalid use of @cols_to_include property
 END

IF ((@cols_to_exclude IS NOT NULL) AND (PATINDEX('''%''',@cols_to_exclude) = 0))
 BEGIN
  RAISERROR('Invalid use of @cols_to_exclude property',16,1)
  PRINT 'Specify column names surrounded by single quotes and separated by commas'
  PRINT 'Eg: EXEC sp_export_data titles, @cols_to_exclude = "''title_id'',''title''"'
  RETURN -1 --Failure. Reason: Invalid use of @cols_to_exclude property
 END


--Checking to see if the database name is specified along wih the table name
--Your database context should be local to the table for which you want to generate INSERT statements
--specifying the database name is not allowed
IF (PARSENAME(@table_name,3)) IS NOT NULL
 BEGIN
  RAISERROR('Do not specify the database name. Be in the required database and just specify the table name.',16,1)
  RETURN -1 --Failure. Reason: Database name is specified along with the table name, which is not allowed
 END

--Checking for the existence of 'user table' or 'view'
--This procedure is not written to work on system tables
--To script the data in system tables, just create a view on the system tables and script the view instead

IF @owner IS NULL
 BEGIN
  IF ((OBJECT_ID(@table_name,'U') IS NULL) AND (OBJECT_ID(@table_name,'V') IS NULL)) 
   BEGIN
    RAISERROR('User table or view not found.',16,1)
    PRINT 'You may see this error, if you are not the owner of this table or view. In that case use @owner parameter to specify the owner name.'
    PRINT 'Make sure you have SELECT permission on that table or view.'
    RETURN -1 --Failure. Reason: There is no user table or view with this name
   END
 END
ELSE
 BEGIN
  IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @table_name AND (TABLE_TYPE = 'BASE TABLE' OR TABLE_TYPE = 'VIEW') AND TABLE_SCHEMA = @owner)
   BEGIN
    RAISERROR('User table or view not found.',16,1)
    PRINT 'You may see this error, if you are not the owner of this table. In that case use @owner parameter to specify the owner name.'
    PRINT 'Make sure you have SELECT permission on that table or view.'
    RETURN -1 --Failure. Reason: There is no user table or view with this name  
   END
 END

--Variable declarations
DECLARE  @Column_ID INT,   
  @Column_List VARCHAR(MAX), 
  @Column_Name VARCHAR(128), 
  @Start_Insert VARCHAR(786), 
  @Data_Type VARCHAR(128), 
  @Actual_Values VARCHAR(MAX), --This is the string that will be finally executed to generate INSERT statements
  @IDN VARCHAR(128)  --Will contain the IDENTITY column's name in the table

--Variable Initialization
SET @IDN = ''
SET @Column_ID = 0
SET @Column_Name = ''
SET @Column_List = ''
SET @Actual_Values = ''

IF @owner IS NULL 
 BEGIN
  SET @Start_Insert = 'INSERT INTO ' + '[' + RTRIM(COALESCE(@target_table,@table_name)) + ']' 
 END
ELSE
 BEGIN
  SET @Start_Insert = 'INSERT ' + '[' + LTRIM(RTRIM(@owner)) + '].' + '[' + RTRIM(COALESCE(@target_table,@table_name)) + ']'   
 END


--To get the first column's ID

SELECT @Column_ID = MIN(ORDINAL_POSITION)  
FROM INFORMATION_SCHEMA.COLUMNS (NOLOCK) 
WHERE  TABLE_NAME = @table_name AND
(@owner IS NULL OR TABLE_SCHEMA = @owner)



--Loop through all the columns of the table, to get the column names and their data types
WHILE @Column_ID IS NOT NULL
 BEGIN
  SELECT  @Column_Name = QUOTENAME(COLUMN_NAME), 
  @Data_Type = DATA_TYPE 
  FROM  INFORMATION_SCHEMA.COLUMNS (NOLOCK) 
  WHERE  ORDINAL_POSITION = @Column_ID AND 
  TABLE_NAME = @table_name AND
  (@owner IS NULL OR TABLE_SCHEMA = @owner)



  IF @cols_to_include IS NOT NULL --Selecting only user specified columns
  BEGIN
   IF CHARINDEX( '''' + SUBSTRING(@Column_Name,2,LEN(@Column_Name)-2) + '''',@cols_to_include) = 0 
   BEGIN
    GOTO SKIP_LOOP
   END
  END

  IF @cols_to_exclude IS NOT NULL --Selecting only user specified columns
  BEGIN
   IF CHARINDEX( '''' + SUBSTRING(@Column_Name,2,LEN(@Column_Name)-2) + '''',@cols_to_exclude) <> 0 
   BEGIN
    GOTO SKIP_LOOP
   END
  END

  --Making sure to output SET IDENTITY_INSERT ON/OFF in case the table has an IDENTITY column
  IF (SELECT COLUMNPROPERTY( OBJECT_ID(QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + @table_name),SUBSTRING(@Column_Name,2,LEN(@Column_Name) - 2),'IsIdentity')) = 1 
  BEGIN
   IF @ommit_identity = 0 --Determing whether to include or exclude the IDENTITY column
    SET @IDN = @Column_Name
   ELSE
    GOTO SKIP_LOOP   
  END
  
  --Making sure whether to output computed columns or not
  IF @ommit_computed_cols = 1
  BEGIN
   IF (SELECT COLUMNPROPERTY( OBJECT_ID(QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + @table_name),SUBSTRING(@Column_Name,2,LEN(@Column_Name) - 2),'IsComputed')) = 1 
   BEGIN
    GOTO SKIP_LOOP     
   END
  END
  
  --Tables with columns of IMAGE data type are not supported for obvious reasons
  IF(@Data_Type IN ('image'))
   BEGIN
    IF (@ommit_images = 0)
     BEGIN
      RAISERROR('Tables with image columns are not supported.',16,1)
      PRINT 'Use @ommit_images = 1 parameter to generate INSERTs for the rest of the columns.'
      PRINT 'DO NOT ommit Column List in the INSERT statements. If you ommit column list using @include_column_list=0, the generated INSERTs will fail.'
      RETURN -1 --Failure. Reason: There is a column with image data type
     END
    ELSE
     BEGIN
     GOTO SKIP_LOOP
     END
   END

  --Determining the data type of the column and depending on the data type, the VALUES part of
  --the INSERT statement is generated. Care is taken to handle columns with NULL values. Also
  --making sure, not to lose any data from flot, real, money, smallmomey, datetime columns
  SET @Actual_Values = @Actual_Values  +
  CASE 
   WHEN @Data_Type IN ('char','varchar','nchar','nvarchar') 
    THEN 
     'COALESCE('''''''' + REPLACE(RTRIM(' + @Column_Name + '),'''''''','''''''''''')+'''''''',''NULL'')'
   WHEN @Data_Type IN ('datetime','smalldatetime') 
    THEN 
     'COALESCE('''''''' + RTRIM(CONVERT(char,' + @Column_Name + ',109))+'''''''',''NULL'')'
   WHEN @Data_Type IN ('uniqueidentifier') 
    THEN  
     'COALESCE('''''''' + REPLACE(CONVERT(char(255),RTRIM(' + @Column_Name + ')),'''''''','''''''''''')+'''''''',''NULL'')'
   WHEN @Data_Type IN ('text','ntext') 
    THEN  
     'COALESCE('''''''' + REPLACE(CONVERT(char(8000),' + @Column_Name + '),'''''''','''''''''''')+'''''''',''NULL'')'     
   WHEN @Data_Type IN ('binary','varbinary') 
    THEN  
     'COALESCE(RTRIM(CONVERT(char,' + 'CONVERT(int,' + @Column_Name + '))),''NULL'')'  
   WHEN @Data_Type IN ('timestamp','rowversion') 
    THEN  
     CASE 
      WHEN @include_timestamp = 0 
       THEN 
        '''DEFAULT''' 
       ELSE 
        'COALESCE(RTRIM(CONVERT(char,' + 'CONVERT(int,' + @Column_Name + '))),''NULL'')'  
     END
   WHEN @Data_Type IN ('float','real','money','smallmoney')
    THEN
     'COALESCE(LTRIM(RTRIM(' + 'CONVERT(char, ' +  @Column_Name  + ',2)' + ')),''NULL'')' 
   ELSE 
    'COALESCE(LTRIM(RTRIM(' + 'CONVERT(char, ' +  @Column_Name  + ')' + ')),''NULL'')' 
  END   + '+' +  ''',''' + ' + '
  
  --Generating the column list for the INSERT statement
  SET @Column_List = @Column_List +  @Column_Name + ',' 

  SKIP_LOOP: --The label used in GOTO

  SELECT  @Column_ID = MIN(ORDINAL_POSITION) 
  FROM  INFORMATION_SCHEMA.COLUMNS (NOLOCK) 
  WHERE  TABLE_NAME = @table_name AND 
  ORDINAL_POSITION > @Column_ID AND
  (@owner IS NULL OR TABLE_SCHEMA = @owner)


 --Loop ends here!
 END

--To get rid of the extra characters that got concatenated during the last run through the loop
SET @Column_List = LEFT(@Column_List,LEN(@Column_List) - 1)
SET @Actual_Values = LEFT(@Actual_Values,LEN(@Actual_Values) - 6)

IF LTRIM(@Column_List) = '' 
 BEGIN
  RAISERROR('No columns to select. There should at least be one column to generate the output',16,1)
  RETURN -1 --Failure. Reason: Looks like all the columns are ommitted using the @cols_to_exclude parameter
 END

--Forming the final string that will be executed, to output the INSERT statements
IF (@include_column_list <> 0)
 BEGIN
  SET @Actual_Values = 
   'SELECT ' +  
   CASE WHEN @top IS NULL OR @top < 0 THEN '' ELSE ' TOP ' + LTRIM(STR(@top)) + ' ' END + 
   '''' + RTRIM(@Start_Insert) + 
   ' ''+' + '''(' + RTRIM(@Column_List) +  '''+' + ''')''' + 
   ' +''VALUES(''+ ' +  @Actual_Values  + '+'')''' + ' ' + 
   COALESCE(@from,' FROM ' + CASE WHEN @owner IS NULL THEN '' ELSE '[' + LTRIM(RTRIM(@owner)) + '].' END + '[' + RTRIM(@table_name) + ']' + '(NOLOCK)')
 END
ELSE IF (@include_column_list = 0)
 BEGIN
  SET @Actual_Values = 
   'SELECT ' + 
   CASE WHEN @top IS NULL OR @top < 0 THEN '' ELSE ' TOP ' + LTRIM(STR(@top)) + ' ' END + 
   '''' + RTRIM(@Start_Insert) + 
   ' '' +''VALUES(''+ ' +  @Actual_Values + '+'')''' + ' ' + 
   COALESCE(@from,' FROM ' + CASE WHEN @owner IS NULL THEN '' ELSE '[' + LTRIM(RTRIM(@owner)) + '].' END + '[' + RTRIM(@table_name) + ']' + '(NOLOCK)')
 END 

--Determining whether to ouput any debug information
IF @debug_mode =1
 BEGIN
  INSERT INTO #Results(resultstext)
  SELECT '/*****START OF DEBUG INFORMATION*****' UNION ALL
  SELECT 'Beginning of the INSERT statement:' UNION ALL
  SELECT @Start_Insert UNION ALL
  SELECT '' UNION ALL
  SELECT 'The column list:' UNION ALL
  SELECT @Column_List UNION ALL
  SELECT '' UNION ALL
  SELECT 'The SELECT statement executed to generate the INSERTs' UNION ALL
  SELECT @Actual_Values UNION ALL
  SELECT '' UNION ALL
  SELECT '*****END OF DEBUG INFORMATION*****/' UNION ALL
  SELECT ''
 END
INSERT INTO #Results(resultstext)
SELECT '--INSERTs generated by ''sp_generate_inserts'' stored procedure written by Vyas' UNION ALL
SELECT '--renamed to ''sp_export_data'' And Print Statements changed to SELECTS as an adaptation by lowell@stormrage.com' UNION ALL
SELECT '--Build number: 22' UNION ALL
SELECT '--Problems/Suggestions? Contact Vyas @ vyaskn@hotmail.com' UNION ALL
SELECT '--http://vyaskn.tripod.com' UNION ALL
SELECT '' UNION ALL
SELECT 'SET NOCOUNT ON' UNION ALL
SELECT ''


--Determining whether to print IDENTITY_INSERT or not
IF (@IDN <> '')
 BEGIN
  INSERT INTO #Results(resultstext)
  SELECT 'SET IDENTITY_INSERT ' + QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + QUOTENAME(@table_name) + ' ON' UNION ALL
  SELECT 'GO' UNION ALL
  SELECT ''
 END


IF @disable_constraints = 1 AND (OBJECT_ID(QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + @table_name, 'U') IS NOT NULL)
 BEGIN
  IF @owner IS NULL
   BEGIN
      INSERT INTO #Results(resultstext)
    SELECT  'ALTER TABLE ' + QUOTENAME(COALESCE(@target_table, @table_name)) + ' NOCHECK CONSTRAINT ALL' AS '--Code to disable constraints temporarily'
   END
  ELSE
   BEGIN
      INSERT INTO #Results(resultstext)
    SELECT  'ALTER TABLE ' + QUOTENAME(@owner) + '.' + QUOTENAME(COALESCE(@target_table, @table_name)) + ' NOCHECK CONSTRAINT ALL' AS '--Code to disable constraints temporarily'
   END
INSERT INTO #Results(resultstext)
  SELECT 'GO'
 END
INSERT INTO #Results(resultstext)
SELECT '' UNION ALL
SELECT 'PRINT ''Inserting values into ' + '[' + RTRIM(COALESCE(@target_table,@table_name)) + ']' + ''''


--All the hard work pays off here!!! You'll get your INSERT statements, when the next line executes!
INSERT INTO #Results(resultstext)
EXEC (@Actual_Values)
INSERT INTO #Results(resultstext)
SELECT 'PRINT ''Done''' UNION ALL
SELECT ''


IF @disable_constraints = 1 AND (OBJECT_ID(QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + @table_name, 'U') IS NOT NULL)
 BEGIN
  IF @owner IS NULL
   BEGIN
      INSERT INTO #Results(resultstext)
    SELECT  'ALTER TABLE ' + QUOTENAME(COALESCE(@target_table, @table_name)) + ' CHECK CONSTRAINT ALL'  AS '--Code to enable the previously disabled constraints'
   END
  ELSE
   BEGIN
      INSERT INTO #Results(resultstext)
    SELECT  'ALTER TABLE ' + QUOTENAME(@owner) + '.' + QUOTENAME(COALESCE(@target_table, @table_name)) + ' CHECK CONSTRAINT ALL' AS '--Code to enable the previously disabled constraints'
   END
INSERT INTO #Results(resultstext)
  SELECT 'GO'
 END
INSERT INTO #Results(resultstext)
SELECT ''
IF (@IDN <> '')
 BEGIN
  INSERT INTO #Results(resultstext)
  SELECT 'SET IDENTITY_INSERT ' + QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + QUOTENAME(@table_name) + ' OFF' UNION ALL
  SELECT 'GO'
 END
INSERT INTO #Results(resultstext)
SELECT 'SET NOCOUNT OFF'


SET NOCOUNT OFF
SELECT resultstext FROM #Results ORDER BY ID
RETURN 0 --Success. We are done!
END
GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject 'sp_export_data'
--#################################################################################################
GO
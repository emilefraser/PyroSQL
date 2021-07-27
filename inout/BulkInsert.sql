SET QUOTED_IDENTIFIER OFF

DECLARE @query varchar(1000)
DECLARE @numfiles int
DECLARE @filename varchar(100)
DECLARE @files TABLE (Name varchar(200) NULL)

--Delete the contents of the rawData table and let the user know
IF @ResetTable = 1
BEGIN
PRINT 'Emptying table [' + @TableName + ']...'
EXEC ('DELETE ' + @TableName)
END

--Pull a list of the CSV file names from the folder that they're stored in
SET @query ='master.dbo.xp_cmdshell "dir '+@filepath+@pattern +' /b"'
INSERT @files(Name) EXEC (@query)
DECLARE curs_files CURSOR FOR
SELECT Name FROM @files WHERE Name IS NOT NULL

--For each CSV file, execute a query
SET @numfiles =0
OPEN curs_files
FETCH NEXT FROM curs_files INTO @filename
WHILE (@@FETCH_STATUS = 0)
BEGIN
SET @numfiles+=1

--BULK INSERT each CSV file into the rawData view and update the rawData table with the file name and the upload datetime
SET @query = ('BULK INSERT ' + @ViewName
+ ' FROM ''' + @Filepath+@filename + ''' WITH(
CODEPAGE = ''65001'',
DATAFILETYPE = ''char'',
FIRSTROW = 2,
FIELDTERMINATOR=''","'',
ROWTERMINATOR=''0x0a'');'

+ ' UPDATE ' + @TableName
+ ' SET [FileName] = ' + '''' + @filename + ''''
+ ' WHERE [FileName] Is Null;'

+ ' UPDATE ' + @TableName
+ ' SET [UploadDatetime] = ' + '''' + CAST(GETDATE() as nvarchar(1000)) + ''''
+ ' WHERE [UploadDatetime] Is Null;'
)

PRINT 'Importing [' + @filename + '] into [' + @TableName + ']...'
EXEC (@query)

FETCH NEXT FROM curs_files INTO @filename
END
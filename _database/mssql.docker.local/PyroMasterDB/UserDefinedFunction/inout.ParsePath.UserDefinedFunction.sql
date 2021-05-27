SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[ParsePath]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [inout].[ParsePath] (
	@FilePath NVARCHAR(300) =  N''C:\Users\Andy\Documents\GitHub\dba-database\stored-procedures\dbo.Alert_Blocking.sql''
)
RETURNS TABLE
AS
RETURN

WITH ParseInfo AS(
    SELECT FilePath      = @FilePath,
           PathLen       = LEN(@FilePath),
           FinalSlashPos = CHARINDEX(''\'', REVERSE(@FilePath), 1)
    ),
    ParsedPaths AS (
    SELECT DirectoryPath = LEFT (FilePath, PathLen - FinalSlashPos + 1),
           FullFileName  = RIGHT(FilePath, FinalSlashPos - 1),
           FileExtension = RIGHT(FilePath, CHARINDEX(''.'', REVERSE(FilePath)) - 1),
           *
    FROM ParseInfo
    )
SELECT DirectoryPath,
       FullFileName,
       BareFilename = LEFT(FullFilename,LEN(FullFilename)-(LEN(FileExtension)+1)),
       FileExtension
FROM ParsedPaths

' 
END
GO

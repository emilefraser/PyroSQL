SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/*
	EXEC fileio.GetFileList 
		@Directory			= 'D:\Database\localdb\MsManagement\sch\DataManager_schema'
	,	@FileOnly_Filter	= 1
	,	@Recurse_Depth		= 2
	,	@Extension_Filter	= 'sql'
*/

CREATE   PROCEDURE [fileio].[GetFileList_]
	@Directory				NVARCHAR(512)
,	@FileOnly_Filter		INT					= 1
,	@Extension_Filter		NVARCHAR(128)		= NULL
,	@Recurse_Depth			INT					= 1

AS 
BEGIN

	--DECLARE @IsFileOnly BIT
	--DECLARE @Extension_Filter NVARCHAR(10) = 'sql'


	--DROP TYPE DirectoryTree
	--CREATE TYPE DirectoryTree AS TABLE (
	--	[ID]				INT				IDENTITY (1, 1)
	--  , [DirectoryName]	    NVARCHAR(512)	NULL
	--  , [FileName]			NVARCHAR(128)	NULL
	--  , [FilePath]			AS				[DirectoryName] + '\' + [FileName]
	--  , [Depth]				INT				NULL
	--  , [IsFile]			BIT				NULL
	--  , [FileExtention]		VARCHAR(50)		NULL
	--)

	--DECLARE @Directory NVARCHAR(1000) = 	'D:\Database\localdb\MsManagement\sch\DataManager_schema' 

	--	Xp_dirtree has three parameters: 
	--	directory	– This is the directory you pass when you call the stored procedure; for example ‘D:Backup’.
	--	depth		– This tells the stored procedure how many subfolder levels to display.  The default of 0 will display all subfolders.
	--	file		– This will either display files as well as each folder.  The default of 0 will not display any files.
	DECLARE @files TABLE (
		[ID]				INT				IDENTITY (1, 1)
	  , [DirectoryName]	    NVARCHAR(512)	NULL
	  , [FileName]			NVARCHAR(128)	NULL
	  , [FilePath]			AS				[DirectoryName] + '\' + [FileName]
	  , [Depth]				INT				NULL
	  , [IsFile]			BIT				NULL
	  , [FileExtention]		VARCHAR(50)		NULL
	)
	
	INSERT INTO @files (
		[FileName]
	  , [Depth]
	  , [IsFile]
	)
	----EXEC master.sys.xp_dirtree
	----	'D:\Database\localdb\MsManagement\sch\DataManager_schema' --@Directory
	----  , 2 --@Recurse_Depth
	----  , 1 --@FileOnly_Filter
	  EXEC master.sys.xp_dirtree
			@Directory
	  ,		@Recurse_Depth
	  ,		@FileOnly_Filter

	SELECT * FROM @files


	UPDATE
		@files
	SET
		[DirectoryName]			= @Directory
	  , [FileExtention]			= (SELECT Item FROM [MsHelper].[dbo].[udf_split_String] ([FileName], '.', 0))

	SELECT * FROM @files

	IF(@Extension_Filter IS NOT NULL)
	BEGIN
		DELETE FROM
			@files
		WHERE
			[FileName] NOT LIKE '%' + @Extension_Filter
	END


	SELECT * FROM @files


END
GO

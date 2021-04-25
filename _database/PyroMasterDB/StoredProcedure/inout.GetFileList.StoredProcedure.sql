SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[GetFileList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[GetFileList] AS' 
END
GO
/*
	Written By: Emile Fraser	
	Date: 2021-04-01
	Desription: Gets filelist from folder via xp_dirtree
*/
/*
	EXEC [inout].[GetFileList] 
		@Directory			= '/sql/DataVault/AdventureWorks_DV/OLTP/Original/TestData' 
	,	@FileOnly_Filter	= 1
	,	@Recurse_Depth		= 1
	,	@Extension_Filter	= 'csv'
*/

ALTER   PROCEDURE [inout].[GetFileList]
	@Directory				NVARCHAR(512)
,	@FileOnly_Filter		INT					= 1
,	@Extension_Filter		NVARCHAR(128)		= NULL
,	@Recurse_Depth			INT					= 1

AS 
BEGIN

	
	--	Xp_dirtree has three parameters: 
	--	directory	– This is the directory you pass when you call the stored procedure; for example ‘D:Backup’.
	--	depth		– This tells the stored procedure how many subfolder levels to display.  The default of 0 will display all subfolders.
	--	file		– This will either display files as well as each folder.  The default of 0 will not display any files.
	DECLARE @files TABLE (
		[ID]							INT				IDENTITY (1, 1)
	  , [DirectoryName]					NVARCHAR(512)	NULL
	  , [FileName]						NVARCHAR(128)	NULL
	  , [FilePath]						AS				[DirectoryName] + '/' + [FileName]
	  , [Depth]							INT				NULL
	  , [IsFile]						BIT				NULL
	  ,	[FileNameWithoutExtension]		VARCHAR(50)		NULL
	  , [FileExtention]					VARCHAR(50)		NULL
	)
	
	INSERT INTO @files (
		[FileName]
	  , [Depth]
	  , [IsFile]
	)
	EXEC master.sys.xp_dirtree
		--'D:\Database\localdb\DataVault\AdventureWorks_DV\OLTP\Original\TestData' (LOCAL)		
		@Directory				-- '/sql/DataVault/AdventureWorks_DV/OLTP/Original/TestData'   (DOCKER)
	  , @Recurse_Depth			-- 2
	  , @FileOnly_Filter		-- 1

	--SELECT * FROM @files

	UPDATE
		@files
	SET
		[DirectoryName]					= @Directory
	  , [FileNameWithoutExtension]		= (SELECT TOP 1 Item FROM [PyroMasterDB].[string].[SplitStringWithDelimeterAndSplit]([FileName], '.', 0) ORDER BY ChunkNumber ASC)
	  , [FileExtention]					= (SELECT TOP 1 Item FROM [PyroMasterDB].[string].[SplitStringWithDelimeterAndSplit]([FileName], '.', 0) ORDER BY ChunkNumber DESC)

	--SELECT * FROM @files

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

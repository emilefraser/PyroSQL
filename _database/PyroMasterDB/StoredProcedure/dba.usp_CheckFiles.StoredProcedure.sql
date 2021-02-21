SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[usp_CheckFiles]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[usp_CheckFiles] AS' 
END
GO

ALTER PROC [dba].[usp_CheckFiles]
AS

/**************************************************************************************************************
**  Purpose: 
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  02/21/2012		Michael Rounds			1.0					Comments creation
**  06/10/2012		Michael Rounds			1.1					Updated to use new FileStatsHistory table
**	08/31/2012		Michael Rounds			1.2					Changed VARCHAR to NVARCHAR
**	04/17/2013		Matthew Monroe			1.2.1				Added database names "[model]" and "[tempdb]"
**	04/25/2013		Matthew Monroe			1.3					Factored out duplicate code into usp_CheckFilesWork
**	05/03/2013		Michael Rounds			1.3.1				Removed param @MinimumFileSizeMB - value is collected from AlertSettings now
**																Removed DECLARE and other SQL not being used anymore
***************************************************************************************************************/

BEGIN

	SET NOCOUNT ON

	/* GET STATS */

	/*Populate File Stats tables*/
	EXEC dba.usp_FileStats @InsertFlag=1

	/* LOG FILES */
	EXEC dba.usp_CheckFilesWork @CheckTempDB=0, @WarnGrowingLogFiles=0

	/* TEMP DB */
	EXEC dba.usp_CheckFilesWork @CheckTempDB=1, @WarnGrowingLogFiles=1

END
GO

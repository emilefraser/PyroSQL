SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE   PROC [dbo].[usp_CheckFiles]
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
**	06/21/2013		Michael Rounds			1.3.2				Fixed paramter calls
**	07/23/2013		Michael Rounds			1.4					Tweaked to support Case-sensitive
***************************************************************************************************************/
BEGIN
	SET NOCOUNT ON

	/* GET STATS */

	/*Populate File Stats tables*/
	EXEC [MsAdmin].dbo.usp_FileStats @InsertFlag=1

	/* LOG FILES */
	EXEC [MsAdmin].dbo.usp_CheckFilesWork @CheckTempDB=0, @WarnGrowingLogFiles=1

	/* TEMP DB */
	EXEC [MsAdmin].dbo.usp_CheckFilesWork @CheckTempDB=1, @WarnGrowingLogFiles=0

END

GO

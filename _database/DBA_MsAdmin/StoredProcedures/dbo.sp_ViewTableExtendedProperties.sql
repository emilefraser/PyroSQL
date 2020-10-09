SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE    PROCEDURE [dbo].[sp_ViewTableExtendedProperties] (@TABLENAME nvarchar(255))
AS
/**************************************************************************************************************
**  Purpose:
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  11/06/2012		Michael Rounds			1.0					Comments creation
***************************************************************************************************************/
DECLARE @cmd NVARCHAR (255)

SET @cmd = 'SELECT objtype, objname, name, value FROM fn_listextendedproperty (NULL, ''schema'', ''dbo'', ''table'', ''' + @TABLENAME + ''', ''column'', default);'

EXEC sp_executesql @cmd


GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[sp_ViewTableExtendedProperties]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[sp_ViewTableExtendedProperties] AS' 
END
GO

ALTER PROCEDURE [dba].[sp_ViewTableExtendedProperties] (@tablename nvarchar(255))
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

SET @cmd = 'SELECT objtype, objname, name, value FROM fn_listextendedproperty (NULL, ''schema'', ''dba'', ''table'', ''' + @TABLENAME + ''', ''column'', default);'

EXEC sp_executesql @cmd

GO

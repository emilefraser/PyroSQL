SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[Depends_ReferencedProcedures]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[Depends_ReferencedProcedures]
AS
SELECT * FROM (SELECT NAME AS ProcedureName, SUBSTRING(( SELECT '', '' + OBJDEP.NAME
FROM  sysdepends
    INNER JOIN sys.objects OBJ ON sysdepends.ID = OBJ.OBJECT_ID
          INNER JOIN sys.objects OBJDEP ON sysdepends.DEPID = OBJDEP.OBJECT_ID
WHERE obj.type = ''P''
AND Objdep.type in (''P'', ''V'', ''U'', ''TR'', ''FN'', ''IF'', ''TF'')
AND sysdepends.id = procs.object_id
--AND OBJ.Name = ''usp_RPT_R0040''
ORDER BY OBJ.name

FOR
XML PATH('''')), 2, 8000) AS NestedProcedures

FROM sys.procedures procs
) InnerTab
WHERE NestedProcedures IS NOT NULL
' 
GO

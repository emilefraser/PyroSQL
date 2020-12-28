SELECT * FROM (SELECT NAME AS ProcedureName, SUBSTRING(( SELECT ', ' + OBJDEP.NAME
FROM  sysdepends
    INNER JOIN sys.objects OBJ ON sysdepends.ID = OBJ.OBJECT_ID
          INNER JOIN sys.objects OBJDEP ON sysdepends.DEPID = OBJDEP.OBJECT_ID
WHERE obj.type = 'P'
AND Objdep.type in ('P', 'V', 'U', 'TR', 'FN', 'IF', 'TF')
AND sysdepends.id = procs.object_id
--AND OBJ.Name = 'usp_RPT_R0040'
ORDER BY OBJ.name

FOR
XML PATH('')), 2, 8000) AS NestedProcedures

FROM sys.procedures procs
) InnerTab
WHERE NestedProcedures IS NOT NULL


-- objects referenced by specified stored proc
;WITH ref_list AS
    (SELECT o.object_id, OBJECT_SCHEMA_NAME(o.object_id) AS schema_name, o.name AS object_name, o.type_desc
       FROM sys.sql_expression_dependencies ed
       INNER JOIN sys.objects o ON ed.referenced_id = o.object_id
       WHERE ed.referencing_id = OBJECT_ID('EMS.sp_StageFullLoad_KEYS_EMS_dbo_SalesInvoice_EMS_KEYS','P')
         AND ed.referenced_id <> ed.referencing_id
     UNION ALL
     SELECT o2.object_id, OBJECT_SCHEMA_NAME(o2.object_id) AS schema_name, o2.name AS object_name, o2.type_desc
       FROM ref_list rl
       INNER JOIN sys.sql_expression_dependencies ed2 ON rl.object_id = ed2.referencing_id
       INNER JOIN sys.objects o2 ON ed2.referenced_id = o2.object_id
       WHERE ed2.referenced_id <> ed2.referencing_id
      )
SELECT DISTINCT schema_name, object_name, type_desc
  FROM ref_list;
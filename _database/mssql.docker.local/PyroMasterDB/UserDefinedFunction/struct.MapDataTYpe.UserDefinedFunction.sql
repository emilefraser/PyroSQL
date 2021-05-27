SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[struct].[MapDataTYpe]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
--
-- Name:
--      fn_helpdatatypemap
--
-- Description:
--      Retrieve data type map as inline table
--
-- Returns:
--      0 if successful
--      1 if failed
--
-- Security:
--      public
--
-- Notes:
--      Produces the full data type map based on input
--      parameters.  Includes filtered version based
--      on source and destination dbms, and defaults.
--

CREATE FUNCTION [struct].[MapDataTYpe]
(
    @source_dbms            sysname = ''%'',
    @source_version         sysname = ''%'',
    @source_type            sysname = ''%'',
    @destination_dbms       sysname = ''%'',
    @destination_version    sysname = ''%'',
    @destination_type       sysname = ''%'',
    @defaults_only          bit     = 0
)
RETURNS @retDataMap TABLE
(
    mapping_id                  int,
    source_dbms                 sysname collate database_default,
    source_version              sysname NULL,
    source_type                 sysname collate database_default,
    source_length_min           bigint,
    source_length_max           bigint,
    source_precision_min        bigint,
    source_precision_max        bigint,
    source_scale_min            int,
    source_scale_max            int,
    source_nullable             bit,
    source_createparams         int,
    destination_dbms            sysname collate database_default,
    destination_version         sysname collate database_default NULL,
    destination_type            sysname collate database_default,
    destination_length          bigint,
    destination_precision       bigint,
    destination_scale           int,
    destination_nullable        bit,
    destination_createparams    int,
    dataloss                    bit,
    is_default                  bit
)
AS
BEGIN
    DECLARE @filter  nvarchar(4000)

    -- Prepare dbms for case insensitive searches
    SET @source_dbms        = UPPER(@source_dbms)
    SET @destination_dbms   = UPPER(@destination_dbms)

    INSERT  @retDataMap
    SELECT  dm.datatype_mapping_id,
            src.dbms,
            src.version,
            srcdt.type,
            map.src_len_min,
            map.src_len_max,
            map.src_prec_min,
            map.src_prec_max,
            map.src_scale_min,
            map.src_scale_max,
            map.src_nullable,
            srcdt.createparams,
            dest.dbms,
            dest.version,
            destdt.type,
            dm.dest_length,
            CASE
                WHEN dm.dest_precision > 0 and dm.dest_scale > dm.dest_precision THEN dm.dest_scale
                ELSE dm.dest_precision
            END,
            dm.dest_scale,
            dm.dest_nullable,
            dm.dest_createparams,
            dm.dataloss,
            case
                when map.default_datatype_mapping_id = dm.datatype_mapping_id then 1
                else 0
            end as [is_default]
    FROM    msdb.dbo.MSdbms src,
            msdb.dbo.MSdbms dest,
            msdb.dbo.MSdbms_datatype srcdt,
            msdb.dbo.MSdbms_datatype destdt,
            msdb.dbo.MSdbms_map map,
            msdb.dbo.MSdbms_datatype_mapping dm
    WHERE   src.dbms_id             = map.src_dbms_id
      AND   dest.dbms_id            = map.dest_dbms_id
      AND   srcdt.datatype_id       = map.src_datatype_id
      AND   map.map_id              = dm.map_id
      AND   dm.dest_datatype_id     = destdt.datatype_id
      AND   (@source_dbms = ''%'' OR src.dbms = @source_dbms)
      AND   sys.fn_IHcompareversion(src.version, @source_version) = 1
      AND   (@destination_dbms = ''%'' OR dest.dbms = @destination_dbms)
      AND   sys.fn_IHcompareversion(dest.version, @destination_version) = 1
      AND   (@source_type = N''%'' OR srcdt.type = @source_type)
      AND   (@destination_type = N''%'' OR destdt.type = @destination_type)
      AND   (@defaults_only = 0 OR map.default_datatype_mapping_id = dm.datatype_mapping_id)
    ORDER BY src.dbms,
             src.version,
             dest.dbms,
             dest.version,
             srcdt.type,
             [is_default] desc,
             destdt.type
    
    RETURN
END' 
END
GO

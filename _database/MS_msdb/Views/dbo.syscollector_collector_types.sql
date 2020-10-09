SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [dbo].[syscollector_collector_types]
AS
    SELECT 
        t.collector_type_uid,
        t.name,
        t.parameter_schema,
        t.parameter_formatter,
        s1.id AS collection_package_id,
        dbo.fn_syscollector_get_package_path(s1.id) AS collection_package_path,
        s1.name AS collection_package_name,
        s2.id AS upload_package_id,
        dbo.fn_syscollector_get_package_path(s2.id) AS upload_package_path,
        s2.name AS upload_package_name,
        t.is_system
    FROM 
        [dbo].[syscollector_collector_types_internal] AS t,
        sysssispackages s1,
        sysssispackages s2
    WHERE t.collection_package_folderid = s1.folderid
      AND t.collection_package_name = s1.name
      AND t.upload_package_folderid = s2.folderid
      AND t.upload_package_name = s2.name

GO

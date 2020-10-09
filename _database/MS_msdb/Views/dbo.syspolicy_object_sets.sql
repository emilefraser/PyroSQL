SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [dbo].[syspolicy_object_sets]
AS
    SELECT     
        os.object_set_id,
        os.object_set_name,
        os.facet_id,
        facet.name as facet_name,
        os.is_system
    FROM [dbo].[syspolicy_object_sets_internal] AS os INNER JOIN [dbo].[syspolicy_management_facets] AS facet
    ON os.facet_id = facet.management_facet_id

GO

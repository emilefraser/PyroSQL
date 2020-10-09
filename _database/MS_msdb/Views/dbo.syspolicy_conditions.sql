SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [dbo].[syspolicy_conditions]
AS
    SELECT
        c.condition_id, c.name, c.date_created, c.description, c.created_by, 
        c.modified_by, c.date_modified, c.is_name_condition, mf.name AS facet, c.expression, c.obj_name, c.is_system 
    FROM [dbo].[syspolicy_conditions_internal] c 
    LEFT OUTER JOIN [dbo].[syspolicy_management_facets] mf ON c.facet_id = mf.management_facet_id

GO

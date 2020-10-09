SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [dbo].[syscollector_config_store]
AS
    SELECT
        s.parameter_name,
        s.parameter_value
    FROM 
        [dbo].[syscollector_config_store_internal] s

GO

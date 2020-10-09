SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW dbo.sysutility_ucp_policy_configuration AS
(    
    SELECT 1 AS utilization_type
        , CAST(UnderUtilizationOccurenceFrequency AS INT) AS occurence_frequency
        , CAST(UnderUtilizationTrailingWindow AS INT) AS trailing_window
    FROM (SELECT name, current_value FROM msdb.dbo.sysutility_ucp_configuration) config
        PIVOT (MAX(current_value) FOR name IN (UnderUtilizationOccurenceFrequency, UnderUtilizationTrailingWindow)) pvt

    UNION ALL

    SELECT 2 AS utilization_type
        , CAST(OverUtilizationOccurenceFrequency AS INT) AS occurence_frequency
        , CAST(OverUtilizationTrailingWindow AS INT) AS trailing_window
    FROM (SELECT name, current_value FROM msdb.dbo.sysutility_ucp_configuration) config
        PIVOT (MAX(current_value) FOR name IN (OverUtilizationOccurenceFrequency, OverUtilizationTrailingWindow)) pvt
) 

GO

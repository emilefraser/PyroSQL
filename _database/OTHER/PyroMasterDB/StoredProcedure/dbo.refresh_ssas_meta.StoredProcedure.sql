SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[refresh_ssas_meta]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[refresh_ssas_meta] AS' 
END
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB reads ssas tabular meta data into repository
*/
ALTER   PROCEDURE [dbo].[refresh_ssas_meta] as 
begin 

if object_id('tempdb..#ssas_queries') is not null
	drop table #ssas_queries
/* 
disable because : SQL Server blocked access to STATEMENT 'OpenRowset/OpenDatasource' of component 'Ad Hoc Distributed Queries' because this component is turned off as part of the security configuration for this server. A system administrator can enable the use of 'Ad Hoc Distributed Queries' by using sp_configure. For more information about enabling 'Ad Hoc Distributed Queries', search for 'Ad Hoc Distributed Queries' in SQL Server Books Online.
	 
select * into #ssas_queries from openrowset('MSOLAP',
 'DATASOURCE=ssas01.company.nl;Initial Catalog=TAB_CKTO_respons_company;User=company\991371;password=anT1svsrnv'
 , '
select [name], [QueryDefinition] from 
[$System].[TMSCHEMA_PARTITIONS]
' ) 
	
select * from 
#ssas_queries
*/
end











GO

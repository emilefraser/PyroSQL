SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE view [INTEGRATION].[vw_egress_Company] as
select CompanyID, CompanyCode, CompanyName, CompanyLogo, ReportingCompanyLogo
from CONFIG.Company

GO

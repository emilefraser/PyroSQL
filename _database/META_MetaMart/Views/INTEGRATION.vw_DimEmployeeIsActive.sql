SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [INTEGRATION].[vw_DimEmployeeIsActive]
AS 

--Provides a list of the current active employees
SELECT DISTINCT(EmployeeKey) as Employeekey FROM INTEGRATION.ingress_dimemployee 
WHERE EmployeeDischargeDate IS NULL OR EmployeeEngagementdate > Getdate()





GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 1 Oct 2018
-- Description: Get a Report Position ID (user) from a domain account name.
-- =============================================
--Sample Execution: SELECT [ACCESS].[udf_GetReportPositionFromDomainAccount]('THARISA\tjohnson')
CREATE FUNCTION [ACCESS].[udf_GetPersonAccessControlListFromDomainAccount]
(
	@DomainAccount VARCHAR(200)
)
RETURNS INT
AS
BEGIN
	DECLARE @PACLID INT

	SET @PACLID = (
	/*
			SELECT ISNULL(reppos.ReportPositionID, reppos_nonemployee.ReportPositionID)
			  FROM ACCESS.ReportUser [user]
				   LEFT JOIN SOURCELINK.Employee emp ON
						emp.EmployeeID = [user].EmployeeID
				   LEFT JOIN SOURCELINK.EmployeePosition pos ON
						pos.EmployeeID = emp.EmployeeID
				   LEFT JOIN ACCESS.PersonAccessControlList reppos ON
						reppos.EmployeePositionID = pos.EmployeePositionID
				   LEFT JOIN ACCESS.PersonAccessControlList reppos_nonemployee ON
						reppos_nonemployee.NonEmployeeReportUserID = [user].ReportUserID
			 WHERE [user].DomainAccount = @DomainAccount
			 */
			 --************************************************************** --WORKS
			 SELECT ISNULL(PACL.OrgChartPositionID, PACL_NonEmp.OrgChartPositionID)
			  FROM GOV.Person P
				   LEFT JOIN GOV.PersonEmployee PE ON  --done
						PE.PersonID = P.PersonID
				   LEFT JOIN GOV.OrgChartPosition OCP ON
						OCP.PersonEmployeeID = PE.PersonEmployeeID
				   LEFT JOIN ACCESS.PersonAccessControlList PACL ON
						PACL.OrgChartPositionID = OCP.OrgChartPositionID
				   LEFT JOIN ACCESS.PersonAccessControlList PACL_NonEmp ON
						PACL_NonEmp.PersonNonEmployeeID = P.PersonID
			 WHERE P.DomainAccountName = @DomainAccount

			 --**************************************************************

		)
	
	RETURN @PACLID
    
END

GO

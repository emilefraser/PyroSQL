SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [GOV].[vw_mat_Person]
AS 
SELECT
[PersonID] AS [Person ID],
[FirstName] AS [First Name],
[Surname] AS [Surname],
[DomainAccountName] AS [Domain Account Name],
[Email] AS [Email],
[MobileNo] AS [Mobile No],
[WorkNo] AS [Work No],
[Department] AS [Department],
[SubDepartment] AS [Sub Department],
[Team] AS [Team],
[IsIntegratedRecord] AS [Is Integrated Record],
[PersonUniqueKey] AS [Person Unique Key],
[CreatedDT] AS [Created Date],
[UpdatedDT] AS [Updated Date],
[IsActive] AS [Is Active]
from GOV.Person

GO

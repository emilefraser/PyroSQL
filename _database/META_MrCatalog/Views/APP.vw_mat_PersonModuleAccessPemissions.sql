SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [APP].[vw_mat_PersonModuleAccessPemissions]
AS
SELECT lrtma.[Action Code], lrtma.[Action Description], lrtma.[Module ID], lrtma.[Module Action ID], lrtma.[Module Description], 
lrtma.[Module Name], lrtma.[Role ID], lrtma.[Role Code], lrtma.[Role Description], lpwrtdd.[Data Domain ID], 
lpwrtdd.[Data Domain Code], lpwrtdd.Email, lpwrtdd.[First Name], lpwrtdd.Surname, lpwrtdd.Department, 
lpwrtdd.[Data Domain Description]
FROM APP.vw_mat_LinkRoleToModuleAction lrtma LEFT JOIN
GOV.vw_mat_LinkPersonWithRoleToDataDomain lpwrtdd ON lpwrtdd.[Role ID] = lrtma.[Role ID]
WHERE lrtma.[Is Active] = 1
AND lpwrtdd.[Is Active] = 1


GO

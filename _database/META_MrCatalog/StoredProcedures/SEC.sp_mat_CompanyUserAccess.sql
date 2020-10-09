SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:		sp_mat_CompanyUserAcces
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [SEC].[sp_mat_CompanyUserAccess] 
	-- Add the parameters for the stored procedure here
	@Username varchar(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	CompanyID as [Company ID]
			, CompanyCode as [Company Code]
			, CompanyName as [Company Description]
	FROM	
			(
				SELECT	1 AS CompanyID
						, 'THM' AS CompanyCode 
						, 'Tharisa Minerals' as CompanyName
			) UserAccessList
END

GO

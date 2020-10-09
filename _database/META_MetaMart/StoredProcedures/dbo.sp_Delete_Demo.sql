SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROC [dbo].[sp_Delete_Demo]

   @ID Int
    As
    Begin   
	DECLARE @IsDeleted bit

	Update DemoTable
	SET IsDeleted = 1
	Where ID = @ID
    End

GO

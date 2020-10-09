SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

create PROCEDURE [APP].[sp_Report_Error]
AS
    SELECT   
        ERROR_NUMBER() AS ErrorNumber  
        ,ERROR_SEVERITY() AS ErrorSeverity  
        ,ERROR_STATE() AS ErrorState  
        ,ERROR_LINE () AS ErrorLine  
        ,ERROR_PROCEDURE() AS ErrorProcedure  
        ,ERROR_MESSAGE() AS ErrorMessage;  



/****** Object:  StoredProcedure [APP].[sp_CRUD_Load_Config]    Script Date: 11/4/2019 2:24:37 PM ******/
SET ANSI_NULLS ON

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[tool].[GetBcpExportDynamic]'))
EXEC dbo.sp_executesql @statement = N'create   view [tool].[GetBcpExportDynamic]
as
   select
      name = ''"'' + name + ''"'' ,
      crdate = ''"'' + convert(varchar(8), crdate, 112) + ''"'' ,
      crtime = ''"'' + convert(varchar(8), crdate, 108) + ''"''
   from sys.sysobjects
' 
GO

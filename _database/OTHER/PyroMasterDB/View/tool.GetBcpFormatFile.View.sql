SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[tool].[GetBcpFormatFile]'))
EXEC dbo.sp_executesql @statement = N'create view [tool].[GetBcpFormatFile]
as
   select top 100 percent
      name = ''"'' + name + ''"'' ,
      crdate = ''"'' + convert(varchar(8), crdate, 112) + ''"'' ,
      crtime = ''"'' + convert(varchar(8), crdate, 108) + ''"''
   from sys.sysobjects
   order by crdate desc
' 
GO

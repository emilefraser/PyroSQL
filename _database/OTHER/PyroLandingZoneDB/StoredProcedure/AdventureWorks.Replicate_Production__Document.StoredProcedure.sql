SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__Document]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__Document] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__Document]
 AS
INSERT INTO [AdventureWorks].[Production__Document] (

)
SELECT 
[DocumentNode],
[DocumentLevel],
[Title],
[Owner],
[FolderFlag],
[FileName],
[FileExtension],
[Revision],
[ChangeNumber],
[Status],
[DocumentSummary],
[Document],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks].[Production].[Document];

GO

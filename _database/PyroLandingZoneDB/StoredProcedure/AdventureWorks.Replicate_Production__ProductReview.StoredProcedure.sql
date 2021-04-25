SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Replicate_Production__ProductReview]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [AdventureWorks].[Replicate_Production__ProductReview] AS' 
END
GO
ALTER   PROCEDURE [AdventureWorks].[Replicate_Production__ProductReview]
 AS
INSERT INTO [AdventureWorks].[Production__ProductReview] (

)
SELECT 
[ProductReviewID],
[ProductID],
[ReviewerName],
[ReviewDate],
[EmailAddress],
[Rating],
[Comments],
[ModifiedDate]
FROM [AdventureWorks].[Production].[ProductReview];

GO

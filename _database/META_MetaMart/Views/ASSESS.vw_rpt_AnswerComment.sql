SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- ====================================================================
-- Create AnswerComment View
-- ====================================================================
CREATE VIEW [ASSESS].[vw_rpt_AnswerComment] AS (
SELECT
[AnswerCommentID],
[Comment],
[AnswerID]
FROM [ASSESS].[AnswerComment]
)

GO

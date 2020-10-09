SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [ASSESS].[sp_CRUD_Answer]
(
    @Id INT, --Answer ID
    @AnswerComment NVARCHAR(MAX), --Comment of Answer
	@AssessmentResponseID INT, --Id of Assessment Response
	@QuestionID INT, --Id of Question
	@SelectedAnswerOptionID INT, -- Selected Answer Option Id
    @TransactionAction NVARCHAR(20) = null -- Type of transaction, "Create", "Update", "Delete"
)
AS
BEGIN
    DECLARE @TransactionDT DATETIME2(7) = getDate() -- Date of transaction
	DECLARE @AssignedID INT --Holder for Scope_Identity()
    IF @TransactionAction = 'Create'
        BEGIN
            --Insert into Answer Table
            INSERT INTO [ASSESS].[Answer] ([AssessmentResponseID],[QuestionID],[AnswerOptionID])
            VALUES(@AssessmentResponseID,@QuestionID,@SelectedAnswerOptionID)
			SET @AssignedID = SCOPE_IDENTITY()
			INSERT INTO [ASSESS].[AnswerComment] ([Comment],[AnswerID])
			VALUES (@AnswerComment,@AssignedID)
        END
    IF @TransactionAction = 'Update'
        BEGIN
            UPDATE [ASSESS].[Answer]
            SET [AssessmentResponseID] = @AssessmentResponseID,
				[QuestionID] = @QuestionID,
				[AnswerOptionID] = @SelectedAnswerOptionID      
            WHERE [AnswerID] = @Id
			UPDATE [ASSESS].[AnswerComment]
            SET [Comment] = @AnswerComment  
            WHERE [AnswerID] = @Id
        END
    IF @TransactionAction = 'Delete'
        BEGIN
            --Set InActive
            DELETE [ASSESS].[Answer]      
            WHERE [AnswerID] = @Id
        END
END

GO

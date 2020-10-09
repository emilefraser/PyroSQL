SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [ASSESS].[sp_CRUD_MicrosoftFormsDump]
(
	@MicrosoftFormsDumpID INT,
	@ID INT,
	@Start_time DATETIME2(7),
	@Completion_time DATETIME2(7),
	@Email	NVARCHAR(MAX),	
	@Name	NVARCHAR(MAX),	
	@Evaluation_Date DATE,	
	@Department NVARCHAR(MAX),	
	@Job_Grade NVARCHAR(MAX),	
	@Gender NVARCHAR(MAX),	
	@Age NVARCHAR(MAX),	
	@Length_of_Service NVARCHAR(MAX),	
	@Highest_Qualification NVARCHAR(MAX),	
	@Question_1	NVARCHAR(MAX),
	@Question_1_1	NVARCHAR(MAX),
	@Question_2	NVARCHAR(MAX),
	@Question_2_1	NVARCHAR(MAX),
	@Question_3	NVARCHAR(MAX),
	@Question_3_1	NVARCHAR(MAX),
	@Question_4	NVARCHAR(MAX),
	@Question_4_1	NVARCHAR(MAX),
	@Question_5	NVARCHAR(MAX),
	@Question_5_1	NVARCHAR(MAX),
	@Question_6	NVARCHAR(MAX),
	@Question_6_1	NVARCHAR(MAX),
	@Question_7	NVARCHAR(MAX),
	@Question_7_1	NVARCHAR(MAX),
	@Question_8	NVARCHAR(MAX),
	@Question_8_1	NVARCHAR(MAX),
	@Question_9	NVARCHAR(MAX),
	@Question_9_1	NVARCHAR(MAX),
	@Question_10	NVARCHAR(MAX),
	@Question_10_1	NVARCHAR(MAX),
	@Question_11	NVARCHAR(MAX),
	@Question_11_1	NVARCHAR(MAX),
	@Question_12	NVARCHAR(MAX),
	@Question_12_1	NVARCHAR(MAX),
	@Question_13	NVARCHAR(MAX),
	@Question_13_1	NVARCHAR(MAX),
	@Question_14	NVARCHAR(MAX),
	@Question_14_1	NVARCHAR(MAX),
	@Question_15	NVARCHAR(MAX),
	@Question_15_1	NVARCHAR(MAX),
	@Question_16	NVARCHAR(MAX),
	@Question_16_1	NVARCHAR(MAX),
	@Question_17	NVARCHAR(MAX),
	@Question_17_1	NVARCHAR(MAX),
	@Question_18	NVARCHAR(MAX),
	@Question_18_1	NVARCHAR(MAX),
	@Question_19	NVARCHAR(MAX),
	@Question_19_1	NVARCHAR(MAX),
	@Question_20	NVARCHAR(MAX),
	@Question_20_1	NVARCHAR(MAX),
	@Question_21	NVARCHAR(MAX),
	@Question_21_1	NVARCHAR(MAX),
	@Question_22	NVARCHAR(MAX),
	@Question_22_1	NVARCHAR(MAX),
	@Question_23	NVARCHAR(MAX),
	@Question_23_1	NVARCHAR(MAX),
    @TransactionAction NVARCHAR(20) = null -- Type of transaction, "Create", "Update", "Delete"
)
AS
BEGIN
    DECLARE @TransactionDT DATETIME2(7) = getDate() -- Date of transaction
    IF @TransactionAction = 'Create'
        BEGIN
            --Insert into Answer Table
            INSERT INTO [ASSESS].[MicrosoftFormsDump] 
					([ID],[Start_time],[Completion_time],[Email],[Name],[Evaluation_Date],[Department],[Job_Grade],[Gender],[Age],
					[Length_of_Service],[Highest_Qualification],[Question_1],[Question_1.1],[Question_2],[Question_2.1],[Question_3],
					[Question_3.1],[Question_4],[Question_4.1],[Question_5],[Question_5.1],[Question_6],[Question_6.1],[Question_7],
					[Question_7.1],[Question_8],[Question_8.1],[Question_9],[Question_9.1],[Question_10],[Question_10.1],[Question_11],
					[Question_11.1],[Question_12],[Question_12.1],[Question_13],[Question_13.1],[Question_14],[Question_14.1],[Question_15],
					[Question_15.1],[Question_16],[Question_16.1],[Question_17],[Question_17.1],[Question_18],[Question_18.1],[Question_19],
					[Question_19.1],[Question_20],[Question_20.1],[Question_21],[Question_21.1],[Question_22],[Question_22.1],[Question_23],
					[Question_23.1])
            VALUES (@ID,@Start_time,@Completion_time,@Email,@Name,@Evaluation_Date,@Department,@Job_Grade,@Gender, 	
					@Age,@Length_of_Service,@Highest_Qualification,@Question_1,@Question_1_1,@Question_2,@Question_2_1,@Question_3,	
					@Question_3_1,@Question_4,@Question_4_1,@Question_5,@Question_5_1,@Question_6,@Question_6_1,@Question_7,@Question_7_1,	
					@Question_8,@Question_8_1,@Question_9,@Question_9_1,@Question_10,@Question_10_1,@Question_11,@Question_11_1,	
					@Question_12,@Question_12_1,@Question_13,@Question_13_1,@Question_14,@Question_14_1,@Question_15,@Question_15_1,
					@Question_16,@Question_16_1,@Question_17,@Question_17_1,@Question_18,@Question_18_1,@Question_19,@Question_19_1,	
					@Question_20,@Question_20_1,@Question_21,@Question_21_1,@Question_22,@Question_22_1,@Question_23,@Question_23_1)
        END
    IF @TransactionAction = 'Update'
        BEGIN
            UPDATE [ASSESS].[MicrosoftFormsDump]
            SET [ID] = @ID ,
				[Start_time] = @Start_time ,
				[Completion_time] = @Completion_time ,
				[Email] = @Email,
				[Name] = @Name,
				[Evaluation_Date] = @Evaluation_Date ,
				[Department] = @Department ,
				[Job_Grade] = @Job_Grade ,
				[Gender] = @Gender ,
				[Age] = @Age ,
				[Length_of_Service] = @Length_of_Service ,
				[Highest_Qualification] = @Highest_Qualification ,
				[Question_1] = @Question_1,
				[Question_1.1] = @Question_1_1,
				[Question_2] = @Question_2,
				[Question_2.1] = @Question_2_1,
				[Question_3] = @Question_3,
				[Question_3.1] = @Question_3_1,
				[Question_4] = @Question_4,
				[Question_4.1] = @Question_4_1,
				[Question_5] = @Question_5,
				[Question_5.1] = @Question_5_1,
				[Question_6] = @Question_6,
				[Question_6.1] = @Question_6_1,
				[Question_7] = @Question_7,
				[Question_7.1] = @Question_7_1,
				[Question_8] = @Question_8,
				[Question_8.1] = @Question_8_1,
				[Question_9] = @Question_9,
				[Question_9.1] = @Question_9_1,
				[Question_10] = @Question_10,
				[Question_10.1] = @Question_10_1,
				[Question_11] = @Question_11,
				[Question_11.1] = @Question_11_1,
				[Question_12] = @Question_12,
				[Question_12.1] = @Question_12_1,
				[Question_13] = @Question_13,
				[Question_13.1] = @Question_13_1,
				[Question_14] = @Question_14,
				[Question_14.1] = @Question_14_1,
				[Question_15] = @Question_15,
				[Question_15.1] = @Question_15_1,
				[Question_16] = @Question_16,
				[Question_16.1] = @Question_16_1,
				[Question_17] = @Question_17,
				[Question_17.1] = @Question_17_1,
				[Question_18] = @Question_18,
				[Question_18.1] = @Question_18_1,
				[Question_19] = @Question_19,
				[Question_19.1] = @Question_19_1,
				[Question_20] = @Question_20,
				[Question_20.1] = @Question_20_1,
				[Question_21] = @Question_21,
				[Question_21.1] = @Question_21_1,
				[Question_22] = @Question_22,
				[Question_22.1] = @Question_22_1,
				[Question_23] = @Question_23,
				[Question_23.1] = @Question_23_1
            WHERE [MicrosoftFormsDumpID] = @MicrosoftFormsDumpID
        END
    IF @TransactionAction = 'Delete'
        BEGIN
            --Set InActive
            DELETE [ASSESS].[MicrosoftFormsDump]      
            WHERE [MicrosoftFormsDumpID] = @MicrosoftFormsDumpID
        END
END

GO
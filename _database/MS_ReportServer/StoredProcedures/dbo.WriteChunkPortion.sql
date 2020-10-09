SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[WriteChunkPortion]
@ChunkPointer binary(16),
@IsPermanentSnapshot bit,
@DataIndex int = NULL,
@DeleteLength int = NULL,
@Content image
AS

IF @IsPermanentSnapshot != 0 BEGIN
    UPDATETEXT ChunkData.Content @ChunkPointer @DataIndex @DeleteLength @Content
END ELSE BEGIN
    UPDATETEXT [ReportServerTempDB].dbo.ChunkData.Content @ChunkPointer @DataIndex @DeleteLength @Content
END
GO

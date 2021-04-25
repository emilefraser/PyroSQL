SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[PersonSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[PersonSAT](
	[PersonVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[NameStyle] [bit] NULL,
	[EmailPromotion] [tinyint] NOT NULL,
	[FirstName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LastName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PersonTypeCode] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AdditionalContactInfo] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Demographics] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MiddleName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PasswordHash] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PasswordSalt] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Suffix] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Title] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[PersonVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonSAT__Perso__080C0D4A]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonSAT]'))
ALTER TABLE [datavault].[PersonSAT]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonSAT__Perso__11365028]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonSAT]'))
ALTER TABLE [datavault].[PersonSAT]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonSAT__Perso__139DBB87]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonSAT]'))
ALTER TABLE [datavault].[PersonSAT]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__PersonSAT__Email__023E255B]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonSAT]'))
ALTER TABLE [datavault].[PersonSAT]  WITH CHECK ADD CHECK  (([EmailPromotion]>=(0) AND [EmailPromotion]<=(2)))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__PersonSAT__Email__7A7D0802]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonSAT]'))
ALTER TABLE [datavault].[PersonSAT]  WITH CHECK ADD CHECK  (([EmailPromotion]>=(0) AND [EmailPromotion]<=(2)))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__PersonSAT__Email__7FD6B9FC]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonSAT]'))
ALTER TABLE [datavault].[PersonSAT]  WITH CHECK ADD CHECK  (([EmailPromotion]>=(0) AND [EmailPromotion]<=(2)))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__PersonSAT__Perso__00CADE35]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonSAT]'))
ALTER TABLE [datavault].[PersonSAT]  WITH CHECK ADD CHECK  (([PersonTypeCode]='EM' OR [PersonTypeCode]='GC' OR [PersonTypeCode]='IN' OR [PersonTypeCode]='SC' OR [PersonTypeCode]='SP' OR [PersonTypeCode]='VC'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__PersonSAT__Perso__03324994]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonSAT]'))
ALTER TABLE [datavault].[PersonSAT]  WITH CHECK ADD CHECK  (([PersonTypeCode]='EM' OR [PersonTypeCode]='GC' OR [PersonTypeCode]='IN' OR [PersonTypeCode]='SC' OR [PersonTypeCode]='SP' OR [PersonTypeCode]='VC'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__PersonSAT__Perso__7B712C3B]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonSAT]'))
ALTER TABLE [datavault].[PersonSAT]  WITH CHECK ADD CHECK  (([PersonTypeCode]='EM' OR [PersonTypeCode]='GC' OR [PersonTypeCode]='IN' OR [PersonTypeCode]='SC' OR [PersonTypeCode]='SP' OR [PersonTypeCode]='VC'))
GO

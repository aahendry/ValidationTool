CREATE DATABASE [ODataValidationSuite]
GO

USE [ODataValidationSuite]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValidationJobs](
[ID] [uniqueidentifier] NOT NULL,
[ResourceType] [nvarchar](100) NULL,
[ServiceType] [nvarchar](100) NULL,
[LevelTypes] [nvarchar](100) NULL,
[Complete] [bit] NULL,
[Version] [timestamp] NULL,
[RuleCount] [int] NULL,
[CreatedDate] [datetime] NULL,
[CompleteDate] [datetime] NULL,
[ErrorOccurred] [bit] NULL,
[ReqHeaders] [nvarchar](max) NULL,
CONSTRAINT [PK_ValidationJobs_1] PRIMARY KEY CLUSTERED
(
[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[LiveValidationJobs]    Script Date: 09/14/2011 16:12:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LiveValidationJobs](
[ID] [uniqueidentifier] NOT NULL,
[Uri] [nvarchar](300) NOT NULL,
[Format] [nvarchar](100) NOT NULL,
CONSTRAINT [PK_LiveValidationJob] PRIMARY KEY CLUSTERED
(
[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[LiveValidationJobs]  WITH CHECK ADD  CONSTRAINT [FK_LiveValidationJob_LiveValidationJob] FOREIGN KEY([ID])
REFERENCES [dbo].[LiveValidationJobs] ([ID])
GO

ALTER TABLE [dbo].[LiveValidationJobs] CHECK CONSTRAINT [FK_LiveValidationJob_LiveValidationJob]
GO

/****** Object:  Table [dbo].[OfflineValidationJobs]    Script Date: 09/14/2011 16:12:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[OfflineValidationJobs](
[ID] [uniqueidentifier] NOT NULL,
[PayloadText] [nvarchar](max) NOT NULL,
[MetadataText] [nvarchar](max) NULL,
CONSTRAINT [PK_OfflineValidationJobs] PRIMARY KEY CLUSTERED
(
[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[OfflineValidationJobs]  WITH CHECK ADD  CONSTRAINT [FK_OfflineValidationJobs_OfflineValidationJobs] FOREIGN KEY([ID])
REFERENCES [dbo].[OfflineValidationJobs] ([ID])
GO

ALTER TABLE [dbo].[OfflineValidationJobs] CHECK CONSTRAINT [FK_OfflineValidationJobs_OfflineValidationJobs]
GO

/****** Object:  View [dbo].[ExtValidationJobs] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ExtValidationJobs]
AS
SELECT     dbo.ValidationJobs.ID, dbo.ValidationJobs.RuleCount, dbo.LiveValidationJobs.Uri, dbo.ValidationJobs.ReqHeaders,
dbo.LiveValidationJobs.Format, dbo.ValidationJobs.ResourceType, dbo.ValidationJobs.ServiceType, dbo.ValidationJobs.LevelTypes, dbo.OfflineValidationJobs.PayloadText,
dbo.OfflineValidationJobs.MetadataText, dbo.ValidationJobs.Complete, dbo.ValidationJobs.ErrorOccurred, dbo.ValidationJobs.CreatedDate, dbo.ValidationJobs.CompleteDate
FROM         dbo.ValidationJobs LEFT OUTER JOIN
dbo.OfflineValidationJobs ON dbo.ValidationJobs.ID = dbo.OfflineValidationJobs.ID LEFT OUTER JOIN
dbo.LiveValidationJobs ON dbo.ValidationJobs.ID = dbo.LiveValidationJobs.ID

GO


/****** Object:  Trigger [dbo].[myInsertTrigger] ******/
/****** Purpose:  make the view an updateable view ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[myInsertTrigger]
ON  [dbo].[ExtValidationJobs]
INSTEAD OF INSERT
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

-- insert to the applicable table
IF (EXISTS (SELECT Uri FROM inserted WHERE Uri IS NOT NULL))
INSERT INTO [LiveValidationJobs]
SELECT ID, Uri, Format FROM inserted
ELSE
INSERT INTO [OfflineValidationJobs]
SELECT ID, PayloadText, MetadataText FROM inserted

-- insert the base table
INSERT INTO [ValidationJobs]
(ID, ResourceType, ServiceType, LevelTypes, RuleCount, CreatedDate, ReqHeaders)
SELECT I.ID, I.ResourceType, I.ServiceType, I.LevelTypes, I.RuleCount, I.CreatedDate, I.ReqHeaders FROM inserted I
END

GO

/****** Object:  Table [dbo].[RequestLog]    Script Date: 03/22/2011 13:33:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RequestLog](
[ID] [int] IDENTITY(1,1) NOT NULL,
[Uri] [nvarchar](max) NOT NULL,
[Date] [datetime] NOT NULL,
[Format] [nvarchar](50) NOT NULL,
CONSTRAINT [PK_RequestLog] PRIMARY KEY CLUSTERED
(
[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PayloadLines]    Script Date: 03/22/2011 13:33:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayloadLines](
[ID] [uniqueidentifier] NOT NULL,
[LineNumber] [int] NOT NULL,
[LineText] [nvarchar](max) NOT NULL,
[JobID] [uniqueidentifier] NOT NULL,
CONSTRAINT [PK_PayloadLines] PRIMARY KEY CLUSTERED
(
[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TestResults]    Script Date: 03/22/2011 13:33:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TestResults](
[ID] [int] IDENTITY(1,1) NOT NULL,
[RuleName] [nvarchar](50) NOT NULL,
[Description] [nvarchar](max) NOT NULL,
[HelpUri] [nvarchar](300) NULL,
[SpecificationUri] [nvarchar](300) NULL,
[LineNumberInError] [nvarchar](300) NULL,
[HeaderInError] [nvarchar](300) NULL,
[Classification] [nvarchar](50) NOT NULL,
[AppliesTo] [nvarchar](50) NULL,
[ODataLevel] [nvarchar](50) NOT NULL,
[ValidationJobID] [uniqueidentifier] NOT NULL,
[ErrorMessage] [nvarchar](max) NOT NULL,
CONSTRAINT [PK_TestResults] PRIMARY KEY CLUSTERED
(
[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Creating table 'ResultDetails'
CREATE TABLE [dbo].[ResultDetails] (
[ID] int IDENTITY(1,1) NOT NULL,
[RuleName] nvarchar(max)  NOT NULL,
[URI] nvarchar(max)  NULL,
[HTTPMethod] nvarchar(max)  NULL,
[RequestData] nvarchar(max)  NULL,
[RequestHeaders] nvarchar(max)  NULL,
[ResponseStatusCode] nvarchar(max)  NULL,
[ResponseHeaders] nvarchar(max)  NULL,
[ResponsePayload] nvarchar(max)  NULL,
[ErrorMessage] nvarchar(max)  NULL,
[TestResultID] int  NOT NULL
);
GO

-- Creating primary key on [Id] in table 'ResultDetails'
ALTER TABLE [dbo].[ResultDetails]
ADD CONSTRAINT [PK_ResultDetails]
PRIMARY KEY CLUSTERED ([Id] ASC);
GO

/****** Object:  ForeignKey [FK_PayloadLines_ValidationJobs]    Script Date: 03/22/2011 13:33:31 ******/
ALTER TABLE [dbo].[PayloadLines]  WITH CHECK ADD  CONSTRAINT [FK_PayloadLines_ValidationJobs] FOREIGN KEY([JobID])
REFERENCES [dbo].[ValidationJobs] ([ID])
GO
ALTER TABLE [dbo].[PayloadLines] CHECK CONSTRAINT [FK_PayloadLines_ValidationJobs]
GO
/****** Object:  ForeignKey [FK_TestResults_ValidationJobs]    Script Date: 03/22/2011 13:33:31 ******/
ALTER TABLE [dbo].[TestResults]  WITH CHECK ADD  CONSTRAINT [FK_TestResults_ValidationJobs] FOREIGN KEY([ValidationJobID])
REFERENCES [dbo].[ValidationJobs] ([ID])
GO
ALTER TABLE [dbo].[TestResults] CHECK CONSTRAINT [FK_TestResults_ValidationJobs]
GO

-- Creating foreign key on [TestResultID] in table 'ResultDetails'
ALTER TABLE [dbo].[ResultDetails]
ADD CONSTRAINT [FK_TestResult_ResultDetail]
FOREIGN KEY ([TestResultID])
REFERENCES [dbo].[TestResults]
([ID])
ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Creating non-clustered index for FOREIGN KEY 'FK_TestResult_ResultDetail'
CREATE INDEX [IX_FK_TestResult_ResultDetail]
ON [dbo].[ResultDetails]
([TestResultID]);
GO

/****** Object:  Table [dbo].[EngineRuntimeExceptions]    Script Date: 04/29/2011 10:39:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EngineRuntimeExceptions](
[JobId] [uniqueidentifier] NOT NULL,
[RuleName] [nvarchar](50) NOT NULL,
[TimeStamp] [datetime] NOT NULL,
[Message] [nvarchar](max) NULL,
[StackTrace] [nvarchar](max) NULL,
[Detail] [nvarchar](max) NULL,
[Uri] [nvarchar](300) NOT NULL,
[ID] [int] IDENTITY(1,1) NOT NULL,
CONSTRAINT [PK_EngineRuntimeExceptions] PRIMARY KEY CLUSTERED
(
[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[JobData](
[ID] [uniqueidentifier] NOT NULL,
[JobID] [uniqueidentifier] NOT NULL,
[RespHeaders] [nvarchar](max) NULL,
CONSTRAINT [PK_JobData] PRIMARY KEY CLUSTERED
(
[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[JobGroup]    Script Date: 12/12/2013 11:26:19 ******/
CREATE TABLE [dbo].[JobGroup](
	[MasterJobId] [uniqueidentifier] NOT NULL,
	[DerivativeJobId] [uniqueidentifier] NULL,
	[ResourceType] [nvarchar](100) NOT NULL,
	[RuleCount] [int] NOT NULL,
	[Issues] [nvarchar](max) NULL,
	[Uri] [nvarchar](300) NOT NULL,
 CONSTRAINT [PK_JobGroup] PRIMARY KEY CLUSTERED 
(
	[MasterJobId] ASC,
	[ResourceType] ASC,
	[Uri] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

/****** Object:  Table [dbo].[Record]    Script Date: 12/8/2014 11:02:04 AM ******/
CREATE TABLE [dbo].[Record](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MasterJobId1] [uniqueidentifier] NULL,
	[MasterJobId2] [uniqueidentifier] NULL,
	[MasterJobId3] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[ActiveTabNum] [tinyint] NOT NULL,
 CONSTRAINT [PK_Record] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
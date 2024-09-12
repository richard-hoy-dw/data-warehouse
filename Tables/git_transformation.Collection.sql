CREATE TABLE [git_transformation].[Collection]
(
[Catalog#] [nvarchar] (100) COLLATE Latin1_General_CI_AS NOT NULL,
[FK_Artist] [int] NULL,
[Title] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[FK_Label] [int] NULL,
[Format] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Rating] [int] NULL,
[Released] [int] NULL,
[Release_id] [int] NULL,
[CollectionFolder] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[DateAdded] [datetime2] NULL,
[CollectionMediaCondition] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[CollectionSleeveCondition] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[CollectionCover] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[CollectionSleeve] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[CollectionNotes] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[DateLoaded] [datetime2] NULL
) ON [PRIMARY]
GO
ALTER TABLE [git_transformation].[Collection] ADD CONSTRAINT [PK_Catalog#] PRIMARY KEY CLUSTERED ([Catalog#]) ON [PRIMARY]
GO
ALTER TABLE [git_transformation].[Collection] ADD CONSTRAINT [FK__Collectio__FK_Ar__5441852A] FOREIGN KEY ([FK_Artist]) REFERENCES [git_transformation].[Artists] ([PK_Artist])
GO
ALTER TABLE [git_transformation].[Collection] ADD CONSTRAINT [FK__Collectio__FK_La__5535A963] FOREIGN KEY ([FK_Label]) REFERENCES [git_transformation].[Labels] ([PK_Label])
GO

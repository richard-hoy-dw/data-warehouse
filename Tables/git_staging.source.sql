CREATE TABLE [git_staging].[source]
(
[Catalog#] [nvarchar] (100) COLLATE Latin1_General_CI_AS NOT NULL,
[Artist] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Title] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[Label] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
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
ALTER TABLE [git_staging].[source] ADD CONSTRAINT [PK_Source] PRIMARY KEY CLUSTERED ([Catalog#]) ON [PRIMARY]
GO

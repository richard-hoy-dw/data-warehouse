CREATE TABLE [git_transformation].[Artists]
(
[PK_Artist] [int] NOT NULL IDENTITY(1, 1),
[ArtistDescr] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [git_transformation].[Artists] ADD CONSTRAINT [PK_Artist] PRIMARY KEY CLUSTERED ([PK_Artist]) ON [PRIMARY]
GO

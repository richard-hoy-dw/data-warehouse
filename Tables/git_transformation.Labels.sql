CREATE TABLE [git_transformation].[Labels]
(
[PK_Label] [int] NOT NULL IDENTITY(1, 1),
[LabelDescr] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [git_transformation].[Labels] ADD CONSTRAINT [PK_Label] PRIMARY KEY CLUSTERED ([PK_Label]) ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [git_transformation].[get_collection]
AS
	BEGIN

	TRUNCATE TABLE [git_transformation].[Collection]
	
		INSERT INTO [git_transformation].[Collection]
			(
				[Catalog#]
				, [FK_Artist]
				, [Title]
				, [FK_Label]
				, [Format]
				, [Rating]
				, [Released]
				, [Release_id]
				, [CollectionFolder]
				, [DateAdded]
				, [CollectionMediaCondition]
				, [CollectionSleeveCondition]
				, [CollectionCover]
				, [CollectionSleeve]
				, [CollectionNotes]
				, [DateLoaded]
			)
					(SELECT [s].[Catalog#]
							, [a].[PK_Artist]
							, [s].[Title]
							, [l].[PK_Label]
							, [s].[Format]
							, [s].[Rating]
							, [s].[Released]
							, [s].[Release_id]
							, [s].[CollectionFolder]
							, [s].[DateAdded]
							, [s].[CollectionMediaCondition]
							, [s].[CollectionSleeveCondition]
							, [s].[CollectionCover]
							, [s].[CollectionSleeve]
							, [s].[CollectionNotes]
							, GETDATE()
					FROM	[git_staging].[source]						AS [s]
							INNER JOIN [git_transformation].[Artists] AS [a]
									ON [s].[Artist] = [a].[ArtistDescr]
							INNER JOIN [git_transformation].[Labels] AS [l]
									ON [s].[Label] = [l].[LabelDescr]);
	END;
GO

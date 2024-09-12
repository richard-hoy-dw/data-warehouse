SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [git_transformation].[get_artists]
AS
	BEGIN

INSERT INTO [git_transformation].[Artists]
	(
		[ArtistDescr]
	)
			(SELECT DISTINCT
					[Artist]
			FROM	[RH_TestDB].[git_staging].[source] S
			WHERE	NOT EXISTS
				(	SELECT	'x'
					FROM	git_transformation.[Artists] A1
					WHERE	S.[Artist] = A1.[ArtistDescr]))

END


GO

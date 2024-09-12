SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [git_transformation].[get_labels]
AS
	BEGIN

INSERT INTO [git_transformation].[Labels]
	(
		[LabelDescr]
	)
			(SELECT DISTINCT
					[Label]
			FROM	[RH_TestDB].[git_staging].[source] S
			WHERE	NOT EXISTS
				(	SELECT	'x'
					FROM	git_transformation.[Labels] A1
					WHERE	S.[Label] = A1.[LabelDescr]))
	
	END;
GO

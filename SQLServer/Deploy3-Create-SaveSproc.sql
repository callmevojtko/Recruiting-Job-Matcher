CREATE PROCEDURE dbo.StoSaveClientRequest @JSON NVARCHAR(MAX)

AS

/*********************************************************************\
Object Name: dbo.StoSaveClientRequest

Parameters: 
	@JSON NVARCHAR(MAX)

Purpose: 
	Saves the client request to the appropriate tables

Example: 
	DECLARE @JSON NVARCHAR(4000) = 
	N'[
	  {
		  "client":"Navient",
		  "title":"Reporting Analyst",
		  "skills":
		  [
			{
				"name":"SQL","experience":69
			},
			{
				"name":"Customer experience","experience":0
			},
			{
				"name":"Microsoft apps","experience":0
			}
		  ]
	  }
	]'

	EXEC dbo.StoSaveClientRequest @JSON NVARCHAR(MAX)

-----------------------------------------------------------------------
Change History
2023-01-25 - TH - Initial creation

\*********************************************************************/

SET NOCOUNT ON;

DECLARE @ClientId SMALLINT,
		@TitleId SMALLINT,
		@ClientRequestId INT;

DROP TABLE IF EXISTS #JSON_Data, #Skills;

--Table to store incoming JSON string
CREATE TABLE #JSON_Data (
	Client VARCHAR(500),
	Title VARCHAR(100),
	Skill VARCHAR(100),
	Experience TINYINT
)

--Requested skills
CREATE TABLE #Skills (
	SkillId SMALLINT,
	Skill VARCHAR(100),
	Experience TINYINT
)


--Format JSON to table structure
INSERT INTO #JSON_Data (Client, Title, Skill, Experience)
SELECT Client, Title, [name], Experience
FROM OPENJSON (@json)
WITH (  
	client VARCHAR(500), title VARCHAR(100),
	skills NVARCHAR(MAX) AS JSON 
)
CROSS APPLY 
	OPENJSON (skills)
	WITH ( 
		[name] VARCHAR(100), experience TINYINT
)

/*******************************************************\
Client

Add client to dbo.Client if does not exist
Assign the @ClientId
\*******************************************************/
IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.Client AS C INNER JOIN #JSON_Data AS JD ON C.[Name] = JD.Client)
BEGIN
	INSERT INTO dbo.Client ([name])
	SELECT DISTINCT Client
	FROM #JSON_Data

	SELECT @ClientId = SCOPE_IDENTITY()

END ELSE
BEGIN
	SELECT @ClientId = C.ClientId
	FROM dbo.Client AS C
	INNER JOIN #JSON_Data AS JD ON C.[Name] = JD.Client 

END


/*******************************************************\
Title

Add title to dbo.Title if does not exist
Assign the @TitleId
\*******************************************************/
IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.Title AS T INNER JOIN #JSON_Data AS JD ON T.[Name] = JD.Title)
BEGIN
	INSERT INTO dbo.Title ([name])
	SELECT DISTINCT Title
	FROM #JSON_Data

	SELECT @TitleId = SCOPE_IDENTITY()

END ELSE
BEGIN
	SELECT @TitleId = T.TitleId
	FROM dbo.Title AS T
	INNER JOIN #JSON_Data AS JD ON T.[Name] = JD.Title 

END


/*******************************************************\
Skills

Add skills to dbo.Skill if they do not exist
Add requested skills to #Skills
\*******************************************************/
INSERT INTO dbo.Skill ([name])
SELECT DISTINCT Skill
FROM #JSON_Data AS JD
LEFT OUTER JOIN dbo.Skill AS S ON JD.Skill = S.[Name]
WHERE S.SkillId IS NULL

INSERT INTO #Skills (SkillId, Skill, Experience)
SELECT DISTINCT S.SkillId, S.[Name], JD.Experience
FROM #JSON_Data AS JD
INNER JOIN dbo.Skill AS S ON JD.Skill = S.[Name]


/*******************************************************\
ClientRequest

Save the client request and assign Id
\*******************************************************/
INSERT INTO dbo.ClientRequest (ClientId)
VALUES (@ClientId)

SELECT @ClientRequestId = SCOPE_IDENTITY()


/*******************************************************\
ClientRequestToTitle

Assign the title to the request
\*******************************************************/
INSERT INTO dbo.ClientRequestToTitle (ClientRequestId, TitleId)
VALUES (@ClientRequestId, @TitleId)


/*******************************************************\
ClientRequestToSkill

Assign the skills to the request
\*******************************************************/
INSERT INTO dbo.ClientRequestToSkill (ClientRequestId, SkillId, YearsOfExperience)
SELECT @ClientRequestId, S.SkillId, S.Experience
FROM #Skills AS S


DROP TABLE IF EXISTS #JSON_Data, #Skills;

GO
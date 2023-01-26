USE [Role_Finder];
GO

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
		"client":"Google",
		"date_requested":"2023-01-30",
		"title":
		[
			{
				"title_name":"Senior Software Engineer",
				"title_exp":10
			}	  
		],
		"skills":
		[
			{
				"skill_name":"SQL",
				"skill_exp":5
			},
			{
				"skill_name":"Python",
				"skill_exp":5
			},
			{
				"skill_name":"C#",
				"skill_exp":5
			}
		]
		}
	]'

	EXEC dbo.StoSaveClientRequest @JSON

-----------------------------------------------------------------------
Change History
2023-01-25 - TH - Initial creation

\*********************************************************************/
SET NOCOUNT ON;
	
DROP TABLE IF EXISTS #JSON_Data, #Skills, #Titles;

DECLARE @ClientId SMALLINT,
		@ClientRequestId INT,
		--Logging
		@CalledProcedure VARCHAR(255) = 'dbo.StoSaveClientRequest', 
		@ActionType VARCHAR(100) = NULL,
		@Comment VARCHAR(1000) = NULL,
		@UserSessionId INT = NULL

SELECT @ActionType = 'Start'
EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
									@ActionType,
									@Comment,
									@UserSessionId OUTPUT

SELECT @ActionType = 'Info', @Comment = CAST(@JSON AS VARCHAR(1000))
EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
									@ActionType,
									@Comment,
									@UserSessionId


--Table to store incoming JSON string
CREATE TABLE #JSON_Data (
	Client VARCHAR(500),
	RequestDate DATE,
	Title_Name VARCHAR(100),
	Title_Exp TINYINT,
	Skill_Name VARCHAR(100),
	Skill_Exp TINYINT
)

--Requested skill(s)
CREATE TABLE #Skills (
	SkillId SMALLINT,
	Skill VARCHAR(100),
	Experience TINYINT
)

--Requested title(s)
CREATE TABLE #Titles (
	TitleId SMALLINT,
	Title VARCHAR(100),
	Experience TINYINT
)

BEGIN TRY
	--Format JSON to table structure
	INSERT INTO #JSON_Data (Client, RequestDate, Title_Name, Title_Exp, Skill_Name, Skill_Exp)
	SELECT DISTINCT Client,
					Date_Requested,
					Title_Name,
					Title_Exp,
					Skill_Name,
					Skill_Exp
	FROM OPENJSON (@json)
	WITH (  
		client VARCHAR(500),
		date_requested DATE,
		title NVARCHAR(MAX) AS JSON,
		skills NVARCHAR(MAX) AS JSON 
	)
	CROSS APPLY 
		OPENJSON (title)
		WITH ( 
			title_name VARCHAR(100), title_exp TINYINT
	)
	CROSS APPLY 
		OPENJSON (skills)
		WITH ( 
			skill_name VARCHAR(100), skill_exp TINYINT
	)

	--Logging
	SELECT @ActionType = 'Insert', @Comment = '#JSON_Data'
	EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
										@ActionType,
										@Comment,
										@UserSessionId
										

END TRY
BEGIN CATCH
	--Logging
	SELECT @ActionType = 'Error', @Comment = CAST(ERROR_MESSAGE() AS VARCHAR(1000))
	EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
										@ActionType,
										@Comment,
										@UserSessionId

END CATCH


/*******************************************************\
Client

Add client to dbo.Client if does not exist
Assign the @ClientId
\*******************************************************/
IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.Client AS C INNER JOIN #JSON_Data AS JD ON C.[Name] = JD.Client)
BEGIN
	BEGIN TRY
		INSERT INTO dbo.Client ([name])
		SELECT DISTINCT Client
		FROM #JSON_Data

		SELECT @ClientId = SCOPE_IDENTITY()

		--Logging
		SELECT @ActionType = 'Insert', @Comment = 'dbo.Client'
		EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
											@ActionType,
											@Comment,
											@UserSessionId

	END TRY
	BEGIN CATCH

		--Logging
		SELECT @ActionType = 'Error', @Comment = CAST(ERROR_MESSAGE() AS VARCHAR(1000))
		EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
											@ActionType,
											@Comment,
											@UserSessionId

	END CATCH

END ELSE
BEGIN
	SELECT @ClientId = C.ClientId
	FROM dbo.Client AS C
	INNER JOIN #JSON_Data AS JD ON C.[Name] = JD.Client 

END


/*******************************************************\
Title

Add title to dbo.Title if does not exist
Add requested title/experience to #Titles
\*******************************************************/
IF EXISTS (SELECT TOP 1 1
		   FROM #JSON_Data AS JD
		   LEFT OUTER JOIN dbo.Title AS T ON JD.Title_Name = T.[Name]
		   WHERE T.TitleId IS NULL)

BEGIN TRY
	INSERT INTO dbo.Title ([name])
	SELECT DISTINCT JD.Title_Name
	FROM #JSON_Data AS JD
	LEFT OUTER JOIN dbo.Title AS T ON JD.Title_Name = T.[Name]
	WHERE T.TitleId IS NULL

	--Logging
	SELECT @ActionType = 'Insert', @Comment = 'dbo.Title'
	EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
										@ActionType,
										@Comment,
										@UserSessionId

END TRY
BEGIN CATCH

	--Logging
	SELECT @ActionType = 'Error', @Comment = CAST(ERROR_MESSAGE() AS VARCHAR(1000))
	EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
										@ActionType,
										@Comment,
										@UserSessionId

END CATCH

INSERT INTO #Titles (TitleId, Title, Experience)
SELECT DISTINCT T.TitleId,
				T.[Name],
				JD.Title_Exp
FROM #JSON_Data AS JD
INNER JOIN dbo.Title AS T ON JD.Title_Name = T.[Name]


/*******************************************************\
Skills

Add skill(s) to dbo.Skill if they do not exist
Add requested skill(s)/experience to #Skills
\*******************************************************/
IF EXISTS (SELECT TOP 1 1
		   FROM #JSON_Data AS JD
		   LEFT OUTER JOIN dbo.Skill AS S ON JD.Skill_Name = S.[Name]
		   WHERE S.SkillId IS NULL)

BEGIN TRY
	INSERT INTO dbo.Skill ([name])
	SELECT DISTINCT JD.Skill_Name
	FROM #JSON_Data AS JD
	LEFT OUTER JOIN dbo.Skill AS S ON JD.Skill_Name = S.[Name]
	WHERE S.SkillId IS NULL

	--Logging
	SELECT @ActionType = 'Insert', @Comment = 'dbo.Skill'
	EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
										@ActionType,
										@Comment,
										@UserSessionId

END TRY
BEGIN CATCH

	--Logging
	SELECT @ActionType = 'Error', @Comment = CAST(ERROR_MESSAGE() AS VARCHAR(1000))
	EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
										@ActionType,
										@Comment,
										@UserSessionId

END CATCH

INSERT INTO #Skills (SkillId, Skill, Experience)
SELECT DISTINCT S.SkillId,
				S.[Name],
				JD.Skill_Exp
FROM #JSON_Data AS JD
INNER JOIN dbo.Skill AS S ON JD.Skill_Name = S.[Name]


/*******************************************************\
ClientRequest

Save the client request and assign Id
\*******************************************************/
BEGIN TRY
	INSERT INTO dbo.ClientRequest (ClientId, DateRequested)
	SELECT DISTINCT @ClientId,
					RequestDate
	FROM #JSON_Data

	SELECT @ClientRequestId = SCOPE_IDENTITY()

	--Logging
	SELECT @ActionType = 'Insert', @Comment = 'dbo.ClientRequest'
	EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
										@ActionType,
										@Comment,
										@UserSessionId

END TRY
BEGIN CATCH
	--Logging
	SELECT @ActionType = 'Error', @Comment = CAST(ERROR_MESSAGE() AS VARCHAR(1000))
	EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
										@ActionType,
										@Comment,
										@UserSessionId

END CATCH

/*******************************************************\
ClientRequestToTitle

Assign the job title to the request
\*******************************************************/
BEGIN TRY
	INSERT INTO dbo.ClientRequestToTitle (ClientRequestId, TitleId, Experience)
	SELECT DISTINCT @ClientRequestId,
					TitleId,
					Experience
	FROM #Titles

	--Logging
	SELECT @ActionType = 'Insert', @Comment = 'dbo.ClientRequestToTitle`'
	EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
										@ActionType,
										@Comment,
										@UserSessionId

END TRY
BEGIN CATCH
	--Logging
	SELECT @ActionType = 'Error', @Comment = CAST(ERROR_MESSAGE() AS VARCHAR(1000))
	EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
										@ActionType,
										@Comment,
										@UserSessionId

END CATCH


/*******************************************************\
ClientRequestToSkill

Assign the skill(s) to the request
\*******************************************************/
BEGIN TRY
	INSERT INTO dbo.ClientRequestToSkill (ClientRequestId, SkillId, Experience)
	SELECT DISTINCT @ClientRequestId,
					SkillId,
					Experience
	FROM #Skills

	--Logging
	SELECT @ActionType = 'Insert', @Comment = 'dbo.ClientRequestToSkill'
	EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
										@ActionType,
										@Comment,
										@UserSessionId

END TRY
BEGIN CATCH
	--Logging
	SELECT @ActionType = 'Error', @Comment = CAST(ERROR_MESSAGE() AS VARCHAR(1000))
	EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
										@ActionType,
										@Comment,
										@UserSessionId

END CATCH


SELECT @ActionType = 'Complete', @Comment = NULL
EXEC ExecutionAudit.StoExecutionLog @CalledProcedure,
									@ActionType,
									@Comment,
									@UserSessionId


DROP TABLE IF EXISTS #JSON_Data, #Skills;

GO
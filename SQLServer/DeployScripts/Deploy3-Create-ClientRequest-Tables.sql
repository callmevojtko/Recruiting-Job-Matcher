/*
CREATE TABLE dbo.Client
CREATE TABLE dbo.Title
CREATE TABLE dbo.Skill
CREATE TABLE dbo.ClientRequest
CREATE TABLE dbo.ClientRequestToSkill
CREATE TABLE dbo.ClientRequestToTitle

Deploy 3

*/

USE [Role_Finder];
GO

--Clients
CREATE TABLE dbo.Client (
    ClientId SMALLINT IDENTITY(1,1) NOT NULL,
    DateCreated DATETIME2 CONSTRAINT DF_dbo_Client_DateCreated DEFAULT (GETDATE()),
	DateUpdated DATETIME2 CONSTRAINT DF_dbo_Client_DateUpdated DEFAULT (GETDATE()),
    [Name] VARCHAR(500) NOT NULL
    CONSTRAINT PK_dbo_Client PRIMARY KEY (ClientId)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_dbo_Client_Name
ON dbo.Client ([Name]);
GO

CREATE TRIGGER TR_dbo_Client_DateUpdated
ON dbo.Client
AFTER UPDATE
AS
    UPDATE dbo.Client
    SET DateUpdated = GETDATE()
	FROM INSERTED I
	INNER JOIN dbo.Client C ON I.ClientId = C.ClientId
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Clients requesting a new hire.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'Client'
GO  

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Client name.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'Client',   
@level2type = N'Column',@level2name = 'Name' 
GO  



--Job Titles
CREATE TABLE dbo.Title (
    TitleId SMALLINT IDENTITY(1,1) NOT NULL,
    DateCreated DATETIME2 CONSTRAINT DF_dbo_Title_DateCreated DEFAULT (GETDATE()),
	DateUpdated DATETIME2 CONSTRAINT DF_dbo_Title_DateUpdated DEFAULT (GETDATE()),
    [Name] VARCHAR(100) NOT NULL
    CONSTRAINT PK_dbo_Title PRIMARY KEY (TitleId)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_dbo_Title_Name 
ON dbo.Title ([Name]);
GO

CREATE TRIGGER TR_dbo_Title_DateUpdated
ON dbo.Title
AFTER UPDATE
AS
    UPDATE dbo.Title
    SET DateUpdated = GETDATE()
	FROM INSERTED I
	INNER JOIN dbo.Title T ON I.TitleId = T.TitleId
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Stores job titles that were requested by a client',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'Title'
GO  

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Job title name.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'Title',   
@level2type = N'Column',@level2name = 'Name' 
GO 


--Skills
CREATE TABLE dbo.Skill (
    SkillId SMALLINT IDENTITY(1,1) NOT NULL,
    DateCreated DATETIME2 CONSTRAINT DF_dbo_Skill_DateCreated DEFAULT (GETDATE()),
	DateUpdated DATETIME2 CONSTRAINT DF_dbo_Skill_DateUpdated DEFAULT (GETDATE()),
    [Name] VARCHAR(100) NOT NULL,
	IsTech BIT NULL,
    CONSTRAINT PK_dbo_Skill PRIMARY KEY (SkillId)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_dbo_Skill_Name
ON dbo.Skill ([Name]) INCLUDE (IsTech);
GO

CREATE TRIGGER TR_dbo_Skill_DateUpdated
ON dbo.Skill
AFTER UPDATE
AS
    UPDATE dbo.Skill
    SET DateUpdated = GETDATE()
	FROM INSERTED I
	INNER JOIN dbo.Skill S ON I.SkillId = S.SkillId
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Stores skills required for the job.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'Skill'
GO  

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Name of the skill.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'Skill',   
@level2type = N'Column',@level2name = 'Name' 
GO 

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Specifies if the skill is a technical skill.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'Skill',   
@level2type = N'Column',@level2name = 'IsTech' 
GO 



--ClientRequests
CREATE TABLE dbo.ClientRequest (
	ClientRequestId INT IDENTITY(1,1) NOT NULL,
	DateCreated DATETIME2 CONSTRAINT DF_dbo_ClientRequest_DateCreated DEFAULT (GETDATE()),
	DateUpdated DATETIME2 CONSTRAINT DF_dbo_ClientRequest_DateUpdated DEFAULT (GETDATE()),
	ClientId SMALLINT NOT NULL CONSTRAINT FK_dbo_Client_dbo_ClientRequest FOREIGN KEY REFERENCES dbo.Client (ClientId),
	DateRequested DATE NOT NULL,
	DateClosed DATETIME2 NULL,
	CONSTRAINT PK_dbo_ClientRequest PRIMARY KEY (ClientRequestId)
);

CREATE NONCLUSTERED INDEX IX_dbo_ClientRequest_ClientId_DateClosed_DateRequested
ON dbo.ClientRequest(ClientId, DateClosed, DateRequested DESC);
GO

CREATE TRIGGER TR_dbo_ClientRequest_DateUpdated
ON dbo.ClientRequest
AFTER UPDATE
AS
    UPDATE dbo.ClientRequest
    SET DateUpdated = GETDATE()
	FROM INSERTED I
	INNER JOIN dbo.ClientRequest CR ON I.ClientRequestId = CR.ClientRequestId
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Stores requests made by a client.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequest'
GO  

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Client requesting a new hire.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequest',   
@level2type = N'Column',@level2name = 'ClientId' 
GO 

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Date the client requested a position.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequest',   
@level2type = N'Column',@level2name = 'DateRequested' 
GO 

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Date the client request was closed out.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequest',   
@level2type = N'Column',@level2name = 'DateClosed' 
GO 


--ClientRequestToSkills
CREATE TABLE dbo.ClientRequestToSkill (
	ClientRequestToSkillId INT IDENTITY(1,1) NOT NULL,
	DateCreated DATETIME2 CONSTRAINT DF_dbo_ClientRequestToSkill_DateCreated DEFAULT (GETDATE()),
	DateUpdated DATETIME2 CONSTRAINT DF_dbo_ClientRequestToSkill_DateUpdated DEFAULT (GETDATE()),
	ClientRequestId INT NOT NULL CONSTRAINT FK_dbo_ClientRequest_dbo_ClientRequestToSkill FOREIGN KEY REFERENCES dbo.ClientRequest (ClientRequestId),
	SkillId SMALLINT NOT NULL CONSTRAINT FK_dbo_Skill_dbo_ClientRequestToSkill FOREIGN KEY REFERENCES dbo.Skill (SkillId),
	Experience TINYINT CONSTRAINT DF_dbo_ClientRequestToSkill_Experience DEFAULT (0),
	CONSTRAINT PK_dbo_ClientRequestToSkill PRIMARY KEY (ClientRequestToSkillId)
);

CREATE UNIQUE NONCLUSTERED INDEX UQ_dbo_ClientRequestToSkill_ClientRequestId_SkillId_Experience
ON dbo.ClientRequestToSkill (ClientRequestId, SkillId, Experience);
GO

CREATE TRIGGER TR_dbo_ClientRequestToSkill_DateUpdated
ON dbo.ClientRequestToSkill
AFTER UPDATE
AS
    UPDATE dbo.ClientRequestToSkill
    SET DateUpdated = GETDATE()
	FROM INSERTED I
	INNER JOIN dbo.ClientRequestToSkill CRTS ON I.ClientRequestToSkillId = CRTS.ClientRequestToSkillId
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Skills requested by the client for a particular request.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequestToSkill'
GO  

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Client request.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequestToSkill',   
@level2type = N'Column',@level2name = 'ClientRequestId' 
GO 

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Skills requested by the client.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequestToSkill',   
@level2type = N'Column',@level2name = 'SkillId' 
GO 

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Years of experience for the requested skill.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequestToSkill',   
@level2type = N'Column',@level2name = 'Experience' 
GO 



--ClientRequestToTitle
CREATE TABLE dbo.ClientRequestToTitle (
	ClientRequestToTitleId INT IDENTITY(1,1) NOT NULL,
	DateCreated DATETIME2 CONSTRAINT DF_dbo_ClientRequestToTitle_DateCreated DEFAULT (GETDATE()),
	DateUpdated DATETIME2 CONSTRAINT DF_dbo_ClientRequestToTitle_DateUpdated DEFAULT (GETDATE()),
	ClientRequestId INT NOT NULL CONSTRAINT FK_dbo_ClientRequest_dbo_ClientRequestToTitle FOREIGN KEY REFERENCES dbo.ClientRequest (ClientRequestId),
	TitleId SMALLINT NOT NULL CONSTRAINT FK_dbo_Title_dbo_ClientRequestToTitle FOREIGN KEY REFERENCES dbo.Title (TitleId),
	Experience TINYINT CONSTRAINT DF_dbo_ClientRequestToTitle_Experience DEFAULT (0),
	CONSTRAINT PK_dbo_ClientRequestToTitle PRIMARY KEY (ClientRequestToTitleId)
);

CREATE UNIQUE NONCLUSTERED INDEX UQ_dbo_ClientRequestToTitle_ClientRequestId_TitleId
ON dbo.ClientRequestToTitle (ClientRequestId, TitleId);
GO

CREATE TRIGGER TR_dbo_ClientRequestToTitle_DateUpdated
ON dbo.ClientRequestToTitle
AFTER UPDATE
AS
    UPDATE dbo.ClientRequestToTitle
    SET DateUpdated = GETDATE()
	FROM INSERTED I
	INNER JOIN dbo.ClientRequestToTitle CRTT ON I.ClientRequestToTitleId = CRTT.ClientRequestToTitleId
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Title requested by the client for a particular request.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequestToTitle'
GO  

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Client request.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequestToTitle',   
@level2type = N'Column',@level2name = 'ClientRequestId' 
GO 

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Job Title requested by the client.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequestToTitle',   
@level2type = N'Column',@level2name = 'TitleId' 
GO 

EXEC sp_addextendedproperty @name = N'MS_Description', @value = 'Years of experience for the requested job title.',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table', @level1name = 'ClientRequestToTitle',   
@level2type = N'Column',@level2name = 'Experience' 
GO 

GO
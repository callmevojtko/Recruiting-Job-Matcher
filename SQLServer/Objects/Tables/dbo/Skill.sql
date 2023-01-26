USE [Role_Finder];
GO

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
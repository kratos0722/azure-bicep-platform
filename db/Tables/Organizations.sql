CREATE TABLE [dbo].[Organizations]
(
    [Id]        UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_Organizations_Id] DEFAULT (NEWID()),
    [Name]      NVARCHAR(80)     NOT NULL,
    [CreatedAt] DATETIME2(3)     NOT NULL CONSTRAINT [DF_Organizations_CreatedAt] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_Organizations] PRIMARY KEY CLUSTERED ([Id] ASC)
);

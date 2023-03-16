CREATE TABLE [Administration].[Audit_Table] (
    [AuditID]      INT           IDENTITY (1, 1) NOT NULL,
    [Table_Name]   VARCHAR (100) NOT NULL,
    [Operation]    CHAR (1)      NOT NULL,
    [Record_Count] INT           NOT NULL,
    [Audit_Date]   DATETIME      NOT NULL,
    CONSTRAINT [PK__AuditTab__A17F23B8212086C5] PRIMARY KEY CLUSTERED ([AuditID] ASC)
);


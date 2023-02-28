CREATE TABLE [Administration].[AuditTable] (
    [AuditID]     INT           IDENTITY (1, 1) NOT NULL,
    [TableName]   VARCHAR (100) NOT NULL,
    [Operation]   CHAR (1)      NOT NULL,
    [RecordCount] INT           NOT NULL,
    [AuditDate]   DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([AuditID] ASC)
);


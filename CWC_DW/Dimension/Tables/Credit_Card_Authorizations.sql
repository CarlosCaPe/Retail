CREATE TABLE [Dimension].[Credit_Card_Authorizations] (
    [Credit_Card_Authorization_Key] TINYINT       IDENTITY (1, 1) NOT NULL,
    [Authorization_Status]          VARCHAR (10)  NOT NULL,
    [First_Decline_Message]         VARCHAR (250) NOT NULL,
    [Last_Decline_Message]          VARCHAR (250) NULL,
    [First_Success_Message]         VARCHAR (250) NULL,
    [Last_Success_Message]          VARCHAR (250) NULL,
    [is_Removed_From_Source]        BIT           NULL,
    [is_Excluded]                   BIT           NULL,
    [ETL_Created_Date]              DATETIME2 (5) NULL,
    [ETL_Modified_Date]             DATETIME2 (5) NULL,
    [ETL_Modified_Count]            TINYINT       NULL,
    CONSTRAINT [PK_Credit_Card_Authorization_Attributes] PRIMARY KEY CLUSTERED ([Credit_Card_Authorization_Key] ASC)
);




GO

CREATE TRIGGER [Dimension].[tr_Credit_Card_Authorizations_Audit] 
ON [Dimension].[Credit_Card_Authorizations] 
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Operation char(1)
    DECLARE @RecordCount int
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        IF EXISTS (SELECT * FROM deleted)
        BEGIN
            SET @Operation = 'U'
            SET @RecordCount = (SELECT COUNT(*) FROM inserted) -- use inserted table to count records
        END
        ELSE
        BEGIN
            SET @Operation = 'I'
            SET @RecordCount = @@ROWCOUNT -- use @@ROWCOUNT for insert operations
        END
    END
    ELSE
    BEGIN
        SET @Operation = 'D'
        SET @RecordCount = @@ROWCOUNT -- use @@ROWCOUNT for delete operations
    END
    EXEC [Administration].[usp_AuditTable_Insert] '[Dimension].[Credit_Card_Authorizations]', @Operation, @RecordCount
END
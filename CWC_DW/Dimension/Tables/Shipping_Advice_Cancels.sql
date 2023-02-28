CREATE TABLE [Dimension].[Shipping_Advice_Cancels] (
    [Shipping_Advice_Cancel_Key] TINYINT       IDENTITY (1, 1) NOT NULL,
    [is_Canceled]                INT           NOT NULL,
    [Cancel_Reason_CD]           VARCHAR (50)  NULL,
    [Cancel]                     VARCHAR (12)  NULL,
    [Cancel_Reason]              VARCHAR (50)  NULL,
    [is_Removed_From_Source]     BIT           NOT NULL,
    [ETL_Created_Date]           DATETIME2 (5) NOT NULL,
    [ETL_Modified_Date]          DATETIME2 (5) NOT NULL,
    [ETL_Modified_Count]         SMALLINT      NOT NULL,
    CONSTRAINT [PK_Shipping_Advice_Cancels] PRIMARY KEY CLUSTERED ([Shipping_Advice_Cancel_Key] ASC)
);




GO

CREATE TRIGGER [Dimension].[tr_Shipping_Advice_Cancels_Audit] 
ON [Dimension].[Shipping_Advice_Cancels] 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Dimension].[Shipping_Advice_Cancels]', @Operation, @RecordCount
END
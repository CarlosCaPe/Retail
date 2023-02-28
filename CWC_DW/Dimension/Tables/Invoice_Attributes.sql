CREATE TABLE [Dimension].[Invoice_Attributes] (
    [Invoice_Attribute_Key] TINYINT      IDENTITY (1, 1) NOT NULL,
    [Backorder_Fill]        VARCHAR (25) NOT NULL,
    [Baked]                 VARCHAR (10) NOT NULL,
    [Free_Shipping]         VARCHAR (20) NULL,
    [is_Backorder_Fill]     BIT          NOT NULL,
    [is_Baked]              BIT          NOT NULL,
    [is_Free_Shipping]      BIT          NULL,
    CONSTRAINT [PK_Invoice_Attributes] PRIMARY KEY CLUSTERED ([Invoice_Attribute_Key] ASC)
);




GO
CREATE TRIGGER [Dimension].[tr_Invoice_Attributes_Audit] 
ON [Dimension].[Invoice_Attributes] 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Dimension].[Invoice_Attributes]', @Operation, @RecordCount
END
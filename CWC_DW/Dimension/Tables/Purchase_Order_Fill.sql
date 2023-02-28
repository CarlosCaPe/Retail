CREATE TABLE [Dimension].[Purchase_Order_Fill] (
    [Purchase_Order_Fill_Key]         TINYINT      IDENTITY (1, 1) NOT NULL,
    [Purchase_Order_Line_Fill_CD]     TINYINT      NOT NULL,
    [Purchase_Order_Fill_CD]          TINYINT      NOT NULL,
    [Purchase_Order_Line_Fill]        VARCHAR (25) NOT NULL,
    [Purchase_Order_Fill]             VARCHAR (25) NOT NULL,
    [Purchase_Order_Line_Fill_Status] VARCHAR (25) NOT NULL,
    [Purchase_Order_Fill_Status]      VARCHAR (12) NOT NULL,
    CONSTRAINT [PK__Purchase__40C3905198B964D7] PRIMARY KEY CLUSTERED ([Purchase_Order_Fill_Key] ASC)
);




GO
CREATE TRIGGER [Dimension].[tr_Purchase_Order_Fill_Audit] 
ON [Dimension].[Purchase_Order_Fill] 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Dimension].[Purchase_Order_Fill]', @Operation, @RecordCount
END
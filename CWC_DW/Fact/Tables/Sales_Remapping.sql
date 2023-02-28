CREATE TABLE [Fact].[Sales_Remapping] (
    [Sales_Key]                     INT          NOT NULL,
    [Sales_Order_Number]            VARCHAR (50) NOT NULL,
    [Sales_Line_Number]             INT          NOT NULL,
    [Sales_Header_Property_Key]     SMALLINT     NOT NULL,
    [Sales_Header_Property_Key_NEW] SMALLINT     NOT NULL,
    CONSTRAINT [PK_Sales_Remapping] PRIMARY KEY CLUSTERED ([Sales_Key] ASC)
);




GO
CREATE TRIGGER [Fact].[tr_Sales_Remapping_Audit] 
ON [Fact].Sales_Remapping 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Fact].[Sales_Remapping]', @Operation, @RecordCount
END
CREATE TABLE [Fact].[Backorders_Remapping] (
    [Snapshot_Date_Key]             INT      NOT NULL,
    [Sales_Key]                     INT      NOT NULL,
    [Sales_Header_Property_Key]     SMALLINT NULL,
    [Sales_Header_Property_Key_New] SMALLINT NULL
);




GO
CREATE TRIGGER [Fact].[tr_Backorders_Remapping_Audit] 
ON [Fact].Backorders_Remapping 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Fact].[Backorders_Remapping]', @Operation, @RecordCount
END
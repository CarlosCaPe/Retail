CREATE TABLE [Fact].[Backorder_Summary] (
    [Backorder Date]             DATE            NOT NULL,
    [Backorder Amount]           NUMERIC (38, 6) NULL,
    [Backorder Units]            INT             NULL,
    [Backorder New Quantity]     INT             NULL,
    [Backorder New Amount]       NUMERIC (38, 6) NULL,
    [Backorder Shipped Amount]   NUMERIC (38, 6) NULL,
    [Backorder Shipped Quantity] INT             NULL,
    [Backorder Cancel Amount]    NUMERIC (38, 6) NULL,
    [Backorder Cancel Units]     INT             NULL
);




GO
CREATE TRIGGER [Fact].[tr_Backorder_Summary_Audit] 
ON [Fact].[Backorder_Summary] 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Fact].[Backorder_Summary]', @Operation, @RecordCount
END
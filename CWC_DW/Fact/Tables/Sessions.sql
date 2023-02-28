CREATE TABLE [Fact].[Sessions] (
    [Date_Key]               INT           NOT NULL,
    [Date]                   DATE          NOT NULL,
    [Sessions]               INT           NOT NULL,
    [Transactions]           INT           NOT NULL,
    [Revenue]                MONEY         NOT NULL,
    [is_Removed_From_Source] BIT           NOT NULL,
    [ETL_Created_Date]       DATETIME2 (5) NOT NULL,
    [ETL_Modified_Date]      DATETIME2 (5) NOT NULL,
    [ETL_Modified_Count]     TINYINT       NOT NULL,
    PRIMARY KEY CLUSTERED ([Date_Key] ASC)
);




GO

CREATE TRIGGER [Fact].[tr_Sessions_Audit] 
ON [Fact].Sessions 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Fact].[Sessions]', @Operation, @RecordCount
END
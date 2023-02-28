CREATE TABLE [Fact].[Catalog_Products] (
    [Catalog_Product_Key]    INT           IDENTITY (1, 1) NOT NULL,
    [Catalog_Key]            SMALLINT      NOT NULL,
    [Product_Key]            INT           NOT NULL,
    [is_Removed_From_Source] BIT           NULL,
    [is_Excluded]            BIT           NULL,
    [ETL_Created_Date]       DATETIME2 (5) NULL,
    [ETL_Modified_Date]      DATETIME2 (5) NULL,
    [ETL_Modified_Count]     SMALLINT      NULL,
    CONSTRAINT [PK_Catalog_Products] PRIMARY KEY CLUSTERED ([Catalog_Product_Key] ASC)
);




GO
CREATE TRIGGER [Fact].[tr_Catalog_Products_Audit] 
ON [Fact].Catalog_Products 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Fact].[Catalog_Products]', @Operation, @RecordCount
END
CREATE TABLE [Dimension].[Inventory_Warehouses] (
    [Inventory_Warehouse_Key] TINYINT      IDENTITY (1, 1) NOT NULL,
    [Inventory_Warehouse_ID]  VARCHAR (50) NOT NULL,
    [Inventory_Warehouse]     VARCHAR (60) NULL,
    [State_ID]                VARCHAR (50) NULL,
    [Zip_Code]                VARCHAR (50) NULL,
    [is_Active]               BIT          NOT NULL,
    CONSTRAINT [PK_Inventory_Warehouses_1] PRIMARY KEY CLUSTERED ([Inventory_Warehouse_Key] ASC)
);




GO
CREATE TRIGGER [Dimension].[tr_Inventory_Warehouses_Audit] 
ON [Dimension].[Inventory_Warehouses] 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Dimension].[Inventory_Warehouses]', @Operation, @RecordCount
END
CREATE TABLE [Fact].[Warehouse_Shipping_Advice] (
    [Warehouse_Shipping_Advice_Key] INT             IDENTITY (1, 1) NOT NULL,
    [Sales_Key]                     INT             NOT NULL,
    [Shipping_Advice_Cancel_Key]    TINYINT         NOT NULL,
    [Pick_ID]                       VARCHAR (20)    NULL,
    [TP_Part_ID]                    VARCHAR (25)    NULL,
    [Invent_Trans_ID]               VARCHAR (15)    NULL,
    [Sales_Order_Number]            VARCHAR (25)    NULL,
    [VP_ID]                         INT             NULL,
    [Created_Date]                  DATETIME2 (3)   NULL,
    [Exported_Date]                 DATETIME2 (3)   NULL,
    [Ship_Quantity]                 NUMERIC (18, 2) NULL,
    [UPC]                           VARCHAR (30)    NULL,
    [Tracking_Number]               VARCHAR (100)   NULL,
    [is_Removed_From_Source]        BIT             NULL,
    [ETL_Created_Date]              DATETIME2 (5)   NULL,
    [ETL_Modified_Date]             DATETIME2 (5)   NULL,
    [ETL_Modified_Count]            SMALLINT        NULL,
    CONSTRAINT [PK_Warehouse_Shipping_Advice] PRIMARY KEY CLUSTERED ([Warehouse_Shipping_Advice_Key] ASC)
);




GO
create  TRIGGER [Fact].[tr_Warehouse_Shipping_Advice_Audit] 
ON [Fact].Warehouse_Shipping_Advice
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Fact].[Warehouse_Shipping_Advice]', @Operation, @RecordCount
END
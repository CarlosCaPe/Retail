CREATE TABLE [Fact].[Inventory] (
    [Snapshot_Date_Key]                                INT             NOT NULL,
    [Product_Key]                                      INT             NOT NULL,
    [Inventory_Warehouse_Key]                          TINYINT         NOT NULL,
    [Available_On_Hand_Quantity]                       NUMERIC (32, 6) NOT NULL,
    [Available_Reserved_On_Hand_Quantity]              NUMERIC (32, 6) NOT NULL,
    [Available_Available_On_Hand_Quantity]             NUMERIC (32, 6) NOT NULL,
    [Available_Ordered_Quantiity]                      NUMERIC (32, 6) NOT NULL,
    [Available_Reserved_Ordered_Quantity]              NUMERIC (32, 6) NOT NULL,
    [Available_Available_Ordered_Quantity]             NUMERIC (32, 6) NOT NULL,
    [Available_On_Order_Quantity]                      NUMERIC (32, 6) NOT NULL,
    [Available_Total_Available_Quantity]               NUMERIC (32, 6) NOT NULL,
    [Available_Average_Cost]                           NUMERIC (32, 6) NOT NULL,
    [Returns_On_Hand_Quantity]                         NUMERIC (32, 6) NOT NULL,
    [Returns_Reserved_On_Hand_Quantity]                NUMERIC (32, 6) NOT NULL,
    [Returns_Available_On_Hand_Quantity]               NUMERIC (32, 6) NOT NULL,
    [Returns_Ordered_Quantiity]                        NUMERIC (32, 6) NOT NULL,
    [Returns_Reserved_Ordered_Quantity]                NUMERIC (32, 6) NOT NULL,
    [Returns_Available_Ordered_Quantity]               NUMERIC (32, 6) NOT NULL,
    [Returns_On_Order_Quantity]                        NUMERIC (32, 6) NOT NULL,
    [Returns_Total_Available_Quantity]                 NUMERIC (32, 6) NOT NULL,
    [Returns_Average_Cost]                             NUMERIC (32, 6) NOT NULL,
    [Damaged_On_Hand_Quantity]                         NUMERIC (32, 6) NOT NULL,
    [Damaged_Reserved_On_Hand_Quantity]                NUMERIC (32, 6) NOT NULL,
    [Damaged_Available_On_Hand_Quantity]               NUMERIC (32, 6) NOT NULL,
    [Damaged_Ordered_Quantiity]                        NUMERIC (32, 6) NOT NULL,
    [Damaged_Reserved_Ordered_Quantity]                NUMERIC (32, 6) NOT NULL,
    [Damaged_Available_Ordered_Quantity]               NUMERIC (32, 6) NOT NULL,
    [Damaged_On_Order_Quantity]                        NUMERIC (32, 6) NOT NULL,
    [Damaged_Total_Available_Quantity]                 NUMERIC (32, 6) NOT NULL,
    [Damaged_Average_Cost]                             NUMERIC (32, 6) NOT NULL,
    [Damaged_But_Available_On_Hand_Quantity]           NUMERIC (32, 6) NOT NULL,
    [Damaged_But_Available_Reserved_On_Hand_Quantity]  NUMERIC (32, 6) NOT NULL,
    [Damaged_But_Available_Available_On_Hand_Quantity] NUMERIC (32, 6) NOT NULL,
    [Damaged_But_Available_Ordered_Quantiity]          NUMERIC (32, 6) NOT NULL,
    [Damaged_But_Available_Reserved_Ordered_Quantity]  NUMERIC (32, 6) NOT NULL,
    [Damaged_But_Available_Available_Ordered_Quantity] NUMERIC (32, 6) NOT NULL,
    [Damaged_But_Available_On_Order_Quantity]          NUMERIC (32, 6) NOT NULL,
    [Damaged_But_Available_Total_Available_Quantity]   NUMERIC (32, 6) NOT NULL,
    [Damaged_But_Available_Average_Cost]               NUMERIC (32, 6) NOT NULL,
    [Receipt_Hold_On_Hand_Quantity]                    NUMERIC (32, 6) NOT NULL,
    [Receipt_Hold_Reserved_On_Hand_Quantity]           NUMERIC (32, 6) NOT NULL,
    [Receipt_Hold_Available_On_Hand_Quantity]          NUMERIC (32, 6) NOT NULL,
    [Receipt_Hold_Ordered_Quantiity]                   NUMERIC (32, 6) NOT NULL,
    [Receipt_Hold_Reserved_Ordered_Quantity]           NUMERIC (32, 6) NOT NULL,
    [Receipt_Hold_Available_Ordered_Quantity]          NUMERIC (32, 6) NOT NULL,
    [Receipt_Hold_On_Order_Quantity]                   NUMERIC (32, 6) NOT NULL,
    [Receipt_Hold_Total_Available_Quantity]            NUMERIC (32, 6) NOT NULL,
    [Receipt_Hold_Average_Cost]                        NUMERIC (32, 6) NOT NULL,
    [Temporary_On_Hand_Quantity]                       NUMERIC (32, 6) NOT NULL,
    [Temporary_Reserved_On_Hand_Quantity]              NUMERIC (32, 6) NOT NULL,
    [Temporary_Available_On_Hand_Quantity]             NUMERIC (32, 6) NOT NULL,
    [Temporary_Ordered_Quantiity]                      NUMERIC (32, 6) NOT NULL,
    [Temporary_Reserved_Ordered_Quantity]              NUMERIC (32, 6) NOT NULL,
    [Temporary_Available_Ordered_Quantity]             NUMERIC (32, 6) NOT NULL,
    [Temporary_On_Order_Quantity]                      NUMERIC (32, 6) NOT NULL,
    [Temporary_Total_Available_Quantity]               NUMERIC (32, 6) NOT NULL,
    [Temporary_Average_Cost]                           NUMERIC (32, 6) NOT NULL,
    [Warehouse_Damage_On_Hand_Quantity]                NUMERIC (32, 6) NOT NULL,
    [Warehouse_Damage_Reserved_On_Hand_Quantity]       NUMERIC (32, 6) NOT NULL,
    [Warehouse_Damage_Available_On_Hand_Quantity]      NUMERIC (32, 6) NOT NULL,
    [Warehouse_Damage_Ordered_Quantiity]               NUMERIC (32, 6) NOT NULL,
    [Warehouse_Damage_Reserved_Ordered_Quantity]       NUMERIC (32, 6) NOT NULL,
    [Warehouse_Damage_Available_Ordered_Quantity]      NUMERIC (32, 6) NOT NULL,
    [Warehouse_Damage_On_Order_Quantity]               NUMERIC (32, 6) NOT NULL,
    [Warehouse_Damage_Total_Available_Quantity]        NUMERIC (32, 6) NOT NULL,
    [Warehouse_Damage_Average_Cost]                    NUMERIC (32, 6) NOT NULL,
    [Blocking_On_Hand_Quantity]                        NUMERIC (32, 6) NOT NULL,
    [Blocking_Reserved_On_Hand_Quantity]               NUMERIC (32, 6) NOT NULL,
    [Blocking_Available_On_Hand_Quantity]              NUMERIC (32, 6) NOT NULL,
    [Blocking_Ordered_Quantiity]                       NUMERIC (32, 6) NOT NULL,
    [Blocking_Reserved_Ordered_Quantity]               NUMERIC (32, 6) NOT NULL,
    [Blocking_Available_Ordered_Quantity]              NUMERIC (32, 6) NOT NULL,
    [Blocking_On_Order_Quantity]                       NUMERIC (32, 6) NOT NULL,
    [Blocking_Total_Available_Quantity]                NUMERIC (32, 6) NOT NULL,
    [Blocking_Average_Cost]                            NUMERIC (32, 6) NOT NULL,
    [General_Quarantine_On_Hand_Quantity]              NUMERIC (32, 6) NOT NULL,
    [General_Quarantine_Reserved_On_Hand_Quantity]     NUMERIC (32, 6) NOT NULL,
    [General_Quarantine_Available_On_Hand_Quantity]    NUMERIC (32, 6) NOT NULL,
    [General_Quarantine_Ordered_Quantiity]             NUMERIC (32, 6) NOT NULL,
    [General_Quarantine_Reserved_Ordered_Quantity]     NUMERIC (32, 6) NOT NULL,
    [General_Quarantine_Available_Ordered_Quantity]    NUMERIC (32, 6) NOT NULL,
    [General_Quarantine_On_Order_Quantity]             NUMERIC (32, 6) NOT NULL,
    [General_Quarantine_Total_Available_Quantity]      NUMERIC (32, 6) NOT NULL,
    [General_Quarantine_Average_Cost]                  NUMERIC (32, 6) NOT NULL,
    [is_Removed_From_Source]                           BIT             NOT NULL,
    [is_Excluded]                                      BIT             NOT NULL,
    [ETL_Created_Date]                                 DATETIME2 (5)   NOT NULL,
    [ETL_Modified_Date]                                DATETIME2 (5)   NOT NULL,
    [ETL_Modified_Count]                               TINYINT         NOT NULL,
    [Extended_Cost_On_Hand]                            AS              ([Available_Average_Cost]*[Available_On_Hand_Quantity]),
    [Extended_Cost_On_Order]                           AS              ([Available_Average_Cost]*[Available_Ordered_Quantiity]),
    [Available_WMS_On_Hand_Quantity]                   NUMERIC (32, 6) NULL,
    [Returns_WMS_On_Hand_Quantity]                     NUMERIC (32, 6) NULL,
    [Damaged_WMS_On_Hand_Quantity]                     NUMERIC (32, 6) NULL,
    [Damaged_But_Available_WMS_On_Hand_Quantity]       NUMERIC (32, 6) NULL,
    [Receipt_Hold_Available_WMS_On_Hand_Quantity]      NUMERIC (32, 6) NULL,
    [Temporary_WMS_On_Hand_Quantity]                   NUMERIC (32, 6) NULL,
    [Warehouse_Damage_WMS_On_Hand_Quantity]            NUMERIC (32, 6) NULL,
    [Blocking_WMS_On_Hand_Quantity]                    NUMERIC (32, 6) NULL,
    [General_Quarantine_WMS_On_Hand_Quantity]          NUMERIC (32, 6) NULL,
    CONSTRAINT [PK_Inventory] PRIMARY KEY CLUSTERED ([Snapshot_Date_Key] ASC, [Product_Key] ASC, [Inventory_Warehouse_Key] ASC)
);






GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Inventory_1130_1129]
    ON [Fact].[Inventory]([ETL_Created_Date] ASC)
    INCLUDE([Available_On_Hand_Quantity]);


GO


CREATE TRIGGER [Fact].[tr_Inventory_Audit] 
ON [Fact].Inventory 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Fact].[Inventory]', @Operation, @RecordCount
END
CREATE TABLE [Dimension].[Inventory_Warehouses] (
    [Inventory_Warehouse_Key] TINYINT      IDENTITY (1, 1) NOT NULL,
    [Inventory_Warehouse_ID]  VARCHAR (50) NOT NULL,
    [Inventory_Warehouse]     VARCHAR (60) NULL,
    [State_ID]                VARCHAR (50) NULL,
    [Zip_Code]                VARCHAR (50) NULL,
    [is_Active]               BIT          NOT NULL,
    CONSTRAINT [PK_Inventory_Warehouses_1] PRIMARY KEY CLUSTERED ([Inventory_Warehouse_Key] ASC)
);


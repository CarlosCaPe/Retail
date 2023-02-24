CREATE TABLE [Reference].[Inventory_Warehouses] (
    [Inventory_Warehouse_ID] VARCHAR (50) NOT NULL,
    [Inventory_Warehouse]    VARCHAR (60) NULL,
    [State_ID]               VARCHAR (50) NULL,
    [Zip_Code]               VARCHAR (50) NULL,
    [is_Active]              BIT          NOT NULL,
    CONSTRAINT [PK_Inventory_Warehouses] PRIMARY KEY CLUSTERED ([Inventory_Warehouse_ID] ASC)
);


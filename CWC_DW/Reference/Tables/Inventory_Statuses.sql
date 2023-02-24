CREATE TABLE [Reference].[Inventory_Statuses] (
    [Inventory_Status_ID]     CHAR (2)     NOT NULL,
    [Inventory_Status]        VARCHAR (45) NULL,
    [is_Will_Block_Inventory] BIT          NULL,
    CONSTRAINT [PK_Inventory_Statuses] PRIMARY KEY CLUSTERED ([Inventory_Status_ID] ASC)
);


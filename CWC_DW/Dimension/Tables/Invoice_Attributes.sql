CREATE TABLE [Dimension].[Invoice_Attributes] (
    [Invoice_Attribute_Key] TINYINT      IDENTITY (1, 1) NOT NULL,
    [Backorder_Fill]        VARCHAR (25) NOT NULL,
    [Baked]                 VARCHAR (10) NOT NULL,
    [Free_Shipping]         VARCHAR (20) NULL,
    [is_Backorder_Fill]     BIT          NOT NULL,
    [is_Baked]              BIT          NOT NULL,
    [is_Free_Shipping]      BIT          NULL,
    CONSTRAINT [PK_Invoice_Attributes] PRIMARY KEY CLUSTERED ([Invoice_Attribute_Key] ASC)
);


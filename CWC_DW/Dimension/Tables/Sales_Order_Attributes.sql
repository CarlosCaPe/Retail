CREATE TABLE [Dimension].[Sales_Order_Attributes] (
    [Sales_Order_Attribute_Key] TINYINT      IDENTITY (1, 1) NOT NULL,
    [Order_Classification]      VARCHAR (15) NOT NULL,
    [Future_Return]             VARCHAR (75) NOT NULL,
    [On_Pick_List]              VARCHAR (25) NOT NULL,
    CONSTRAINT [PK_Sales_Order_Attributes] PRIMARY KEY CLUSTERED ([Sales_Order_Attribute_Key] ASC)
);


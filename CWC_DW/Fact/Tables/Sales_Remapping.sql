CREATE TABLE [Fact].[Sales_Remapping] (
    [Sales_Key]                     INT          NOT NULL,
    [Sales_Order_Number]            VARCHAR (50) NOT NULL,
    [Sales_Line_Number]             INT          NOT NULL,
    [Sales_Header_Property_Key]     SMALLINT     NOT NULL,
    [Sales_Header_Property_Key_NEW] SMALLINT     NOT NULL,
    CONSTRAINT [PK_Sales_Remapping] PRIMARY KEY CLUSTERED ([Sales_Key] ASC)
);


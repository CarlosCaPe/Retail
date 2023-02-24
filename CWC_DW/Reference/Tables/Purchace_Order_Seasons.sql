CREATE TABLE [Reference].[Purchace_Order_Seasons] (
    [Purchase_Order_Header_Season_CD] VARCHAR (10) NOT NULL,
    [Purchase_Order_Header_Season]    VARCHAR (25) NULL,
    CONSTRAINT [PK_Purchace_Order_Seasons] PRIMARY KEY CLUSTERED ([Purchase_Order_Header_Season_CD] ASC)
);


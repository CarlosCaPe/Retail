CREATE TABLE [Dimension].[Purchase_Order_Properties] (
    [Purchase_Order_Property_Key]                      SMALLINT      IDENTITY (1, 1) NOT NULL,
    [Purchase_Order_Header_Status]                     VARCHAR (15)  NULL,
    [Purchase_Order_Line_Status]                       VARCHAR (15)  NULL,
    [Purchase_Order_Header_Delivery_Mode_ID]           VARCHAR (50)  NULL,
    [Ship_Mode]                                        AS            (case when [Purchase_Order_Header_Delivery_Mode_ID] like '%Air%' then 'Air' when [Purchase_Order_Header_Delivery_Mode_ID] like '%Oce%' then 'Sea' when [Purchase_Order_Header_Delivery_Mode_ID] like '%Truck%' then 'Truck' when [Purchase_Order_Header_Delivery_Mode_ID] like '%OCN%' then 'Sea' when [Purchase_Order_Header_Delivery_Mode_ID]='SEA' then 'Sea' else [Purchase_Order_Header_Delivery_Mode_ID] end),
    [Purchase_Order_Header_Delivery_Terms_ID]          VARCHAR (65)  NULL,
    [Purchase_Order_Header_Document_Approval_Status]   SMALLINT      NULL,
    [Purchase_Order_Header_Buyer_Group_ID]             VARCHAR (50)  NULL,
    [Purchase_Order_Header_Payment_Terms_Name]         VARCHAR (50)  NULL,
    [Purchase_Order_Header_Vendor_Payment_Method_Name] VARCHAR (30)  NULL,
    [Purchase_Order_Header_Season_CD]                  VARCHAR (10)  NULL,
    [Purchase_Order_Header_Season]                     VARCHAR (25)  NULL,
    [is_Removed_From_Source]                           BIT           NOT NULL,
    [is_Excluded]                                      BIT           NOT NULL,
    [ETL_Created_Date]                                 DATETIME2 (5) NOT NULL,
    [ETL_Modified_Date]                                DATETIME2 (5) NOT NULL,
    [ETL_Modified_Count]                               TINYINT       NOT NULL,
    CONSTRAINT [PK_Purchase_Order_Properties] PRIMARY KEY CLUSTERED ([Purchase_Order_Property_Key] ASC),
    CONSTRAINT [UK_Purchase_Order_Properties] UNIQUE NONCLUSTERED ([Purchase_Order_Header_Status] ASC, [Purchase_Order_Line_Status] ASC, [Purchase_Order_Header_Delivery_Mode_ID] ASC, [Purchase_Order_Header_Delivery_Terms_ID] ASC, [Purchase_Order_Header_Document_Approval_Status] ASC, [Purchase_Order_Header_Buyer_Group_ID] ASC, [Purchase_Order_Header_Payment_Terms_Name] ASC, [Purchase_Order_Header_Vendor_Payment_Method_Name] ASC, [Purchase_Order_Header_Season_CD] ASC)
);


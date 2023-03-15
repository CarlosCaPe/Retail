CREATE TABLE [Dimension].[Products] (
    [Product_Key]                      INT             IDENTITY (1, 1) NOT NULL,
    [Product_Varient_Number]           VARCHAR (70)    NULL,
    [Department_Name]                  VARCHAR (254)   NULL,
    [Class_Name]                       VARCHAR (254)   NULL,
    [Product_Search_Name]              VARCHAR (50)    NULL,
    [Item_Name]                        VARCHAR (60)    NULL,
    [Item_Name_Standard]               VARCHAR (60)    NULL,
    [Item_Number_Name]                 AS              (([Item_ID]+' - ')+isnull([Item_Name_Standard],[Item_Name])),
    [Color_Name]                       VARCHAR (60)    NULL,
    [Size_Name]                        VARCHAR (60)    NULL,
    [Style_Name]                       VARCHAR (60)    NULL,
    [Sales_Price]                      NUMERIC (32, 6) NULL,
    [Sales_Price_Date]                 DATE            NULL,
    [Purchase_Price]                   NUMERIC (32, 6) NULL,
    [Purchase_Price_Date]              DATE            NULL,
    [Vendor_Name]                      VARCHAR (100)   NULL,
    [SKU]                              AS              (concat([Item_ID],[Color_ID],[Size_ID])),
    [Department_ID]                    VARCHAR (50)    NULL,
    [Class_ID]                         VARCHAR (50)    NULL,
    [Item_ID]                          VARCHAR (50)    NOT NULL,
    [Color_ID]                         VARCHAR (50)    NULL,
    [Size_ID]                          VARCHAR (50)    NULL,
    [Style_ID]                         VARCHAR (50)    NULL,
    [is_Active_Product]                BIT             NULL,
    [is_Currently_Backordered]         BIT             NULL,
    [is_Hard_Mark]                     BIT             NULL,
    [is_Soft_Mark]                     BIT             NULL,
    [is_Timed_Event]                   BIT             NULL,
    [Offer_Price_Hard_Mark]            NUMERIC (18, 6) NULL,
    [Offer_Price_Soft_Mark]            NUMERIC (18, 6) NULL,
    [Offer_Price_Timed_Event]          NUMERIC (18, 6) NULL,
    [Vendor_Account_Number]            VARCHAR (50)    NULL,
    [Active_Product]                   AS              (case [is_Active_Product] when (1) then 'Active Product' else 'Not Active Product' end),
    [Currently_Backordered]            AS              (case isnull([is_Currently_Backordered],(0)) when (0) then 'Not Backordered' else 'Backordered' end),
    [Trade_Agreement_Cost]             NUMERIC (18, 6) NULL,
    [Trade_Agreement_Price]            NUMERIC (18, 6) NULL,
    [Earliest_Open_Sales_Key]          INT             NULL,
    [Earliest_Open_Purchase_Order_Key] INT             NULL,
    [First_Catalog_Key]                SMALLINT        NULL,
    [Current_Catalog_Key]              SMALLINT        NULL,
    [Next_Catalog_Key]                 SMALLINT        NULL,
    [First_Vendor_Packing_Slip_Key]    INT             NULL,
    [Average_Unit_Retail]              NUMERIC (18, 6) NULL,
    [Average_Unit_Cost]                NUMERIC (18, 6) NULL,
    [PO_Weighted_Average_Unit_Cost]    NUMERIC (18, 6) NULL,
    [Risk]                             VARCHAR (25)    NULL,
    [Purchase_Order_Open_Quantity]     INT             NULL,
    [Sales_Order_Open_Quantity]        INT             NULL,
    [is_Removed_From_Source]           BIT             NOT NULL,
    [is_Excluded]                      BIT             NOT NULL,
    [ETL_Created_Date]                 DATETIME2 (5)   NOT NULL,
    [ETL_Modified_Date]                DATETIME2 (5)   NOT NULL,
    [ETL_Modified_Count]               SMALLINT        NOT NULL,
    CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED ([Product_Key] ASC),
    CONSTRAINT [UK_Item_Color_Size] UNIQUE NONCLUSTERED ([Item_ID] ASC, [Color_ID] ASC, [Size_ID] ASC)
);






GO
 CREATE TRIGGER [Dimension].[tr_Products_Audit] ON [Dimension].[Products]
AFTER INSERT
	,UPDATE
	,DELETE
AS
BEGIN
	DECLARE @Operation CHAR(1)
	DECLARE @RecordCount INT

	IF EXISTS (
			SELECT NULL
			FROM inserted
			)
	BEGIN
		IF EXISTS (
				SELECT NULL
				FROM deleted
				)
		BEGIN
			IF EXISTS (
					SELECT NULL
					FROM inserted i
					INNER JOIN deleted d ON i.Product_Key  = d.Product_Key 
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Product_Key  = d.Product_Key 
						WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
						)
			END
			ELSE
			BEGIN
				SET @Operation = 'U'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted
						)
			END
		END
		ELSE
		BEGIN
			SET @Operation = 'I'
			SET @RecordCount = @@ROWCOUNT
		END
	END
	ELSE
	BEGIN
		SET @Operation = 'D'
		SET @RecordCount = @@ROWCOUNT
	END

	EXEC [Administration].[usp_Audit_Table_Insert] '[Dimension].[Products]'
		,@Operation
		,@RecordCount
END
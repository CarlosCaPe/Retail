CREATE TABLE [Dimension].[Customers] (
    [Customer_Key]                       INT            IDENTITY (1, 1) NOT NULL,
    [Customer_Account]                   VARCHAR (50)   NOT NULL,
    [Employee_Key]                       SMALLINT       NULL,
    [Employee_Responsible_Number]        VARCHAR (50)   NULL,
    [Customer_Group]                     VARCHAR (50)   NOT NULL,
    [Organization_Name]                  NVARCHAR (100) NULL,
    [Name_Alias]                         NVARCHAR (50)  NULL,
    [Known_As]                           NVARCHAR (100) NULL,
    [Person_First_Name]                  NVARCHAR (50)  NULL,
    [Person_Last_Name]                   NVARCHAR (50)  NULL,
    [Full_Primary_Address]               NVARCHAR (250) NULL,
    [Address_Description]                NVARCHAR (60)  NULL,
    [Address_Zip_Code]                   VARCHAR (50)   NULL,
    [Address_City]                       NVARCHAR (60)  NULL,
    [Address_County]                     VARCHAR (50)   NULL,
    [Address_State]                      VARCHAR (50)   NULL,
    [Address_Country_Region_ID]          VARCHAR (50)   NULL,
    [Address_Valid_From]                 DATETIME2 (5)  NULL,
    [Address_Valid_To]                   DATETIME2 (5)  NULL,
    [Primary_Contact_Email]              VARCHAR (255)  NULL,
    [Primary_Contact_Phone]              VARCHAR (4000) NULL,
    [Sales_Currency_Code]                VARCHAR (50)   NULL,
    [Payment_Terms]                      VARCHAR (50)   NULL,
    [Payment_Method]                     VARCHAR (50)   NULL,
    [Delivery_Mode]                      VARCHAR (50)   NULL,
    [Receipt_Email]                      VARCHAR (80)   NULL,
    [Delivery_Address_Description]       NVARCHAR (60)  NULL,
    [Delivery_Address_Zip_Code]          VARCHAR (50)   NULL,
    [Delivery_Address_City]              NVARCHAR (60)  NULL,
    [Delivery_Address_Country_Region_ID] VARCHAR (50)   NULL,
    [Delivery_Address_County]            VARCHAR (50)   NULL,
    [Delivery_Address_State]             VARCHAR (50)   NULL,
    [Delivery_Address_Street]            NVARCHAR (250) NULL,
    [Delivery_Address_Street_Number]     VARCHAR (50)   NULL,
    [Delivery_Address_Valid_From]        DATETIME2 (5)  NULL,
    [Delivery_Address_Valid_To]          DATETIME2 (5)  NULL,
    [Email_Contact_Pref_ID]              VARCHAR (50)   NULL,
    [Phone_Contact_Pref_ID]              VARCHAR (50)   NULL,
    [Direct_Mail_Contact_Pref_ID]        VARCHAR (50)   NULL,
    [Rental_Contact_Pref_ID]             VARCHAR (50)   NULL,
    [Created_Date_Time]                  DATETIME2 (5)  NULL,
    [Modified_Date_Time]                 DATETIME2 (5)  NULL,
    [On_Hold_Status]                     INT            NOT NULL,
    [is_Business_Address]                BIT            NULL,
    [is_Delivery_Address]                BIT            NULL,
    [is_Removed_From_Source]             BIT            NULL,
    [is_Excluded]                        BIT            NULL,
    [ETL_Created_Date]                   DATETIME2 (5)  NULL,
    [ETL_Modified_Date]                  DATETIME2 (5)  NULL,
    [ETL_Modified_Count]                 SMALLINT       NULL,
    CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED ([Customer_Key] ASC),
    CONSTRAINT [UK_Customer_Account] UNIQUE NONCLUSTERED ([Customer_Account] ASC)
);




GO
CREATE TRIGGER [Dimension].[tr_Customers_Audit] 
ON [Dimension].[Customers] 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Dimension].[Customers]', @Operation, @RecordCount
END
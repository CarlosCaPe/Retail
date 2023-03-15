CREATE TABLE [Dimension].[Sales_Header_Properties] (
    [Sales_Header_Property_Key]        SMALLINT      IDENTITY (1, 1) NOT NULL,
    [Sales_Header_Type]                VARCHAR (15)  NOT NULL,
    [Sales_Header_Status]              VARCHAR (20)  NULL,
    [Sales_Header_Retail_Channel]      VARCHAR (100) NULL,
    [Sales_Header_Retail_Channel_Name] VARCHAR (50)  NULL,
    [Sales_Header_Return_Reason_Group] VARCHAR (25)  NULL,
    [Sales_Header_Return_Reason]       VARCHAR (25)  NULL,
    [Sales_Header_Delivery_Mode]       VARCHAR (25)  NULL,
    [Sales_Header_On_Hold]             BIT           NULL,
    [is_Removed_From_Source]           BIT           NULL,
    [is_Excluded]                      BIT           NULL,
    [ETL_Created_Date]                 DATETIME2 (5) NULL,
    [ETL_Modified_Date]                DATETIME2 (5) NULL,
    [ETL_Modified_Count]               TINYINT       NULL,
    CONSTRAINT [PK_Sales_Header_Properties] PRIMARY KEY CLUSTERED ([Sales_Header_Property_Key] ASC),
    CONSTRAINT [UK_Sales_Header_Mapping_Properties] UNIQUE NONCLUSTERED ([Sales_Header_Type] ASC, [Sales_Header_Status] ASC, [Sales_Header_Retail_Channel] ASC, [Sales_Header_Retail_Channel_Name] ASC, [Sales_Header_Return_Reason_Group] ASC, [Sales_Header_Return_Reason] ASC, [Sales_Header_Delivery_Mode] ASC, [Sales_Header_On_Hold] ASC)
);






GO
 CREATE TRIGGER [Dimension].[tr_Sales_Header_Properties_Audit] ON [Dimension].[Sales_Header_Properties]
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
					INNER JOIN deleted d ON i.Sales_Header_Property_Key = d.Sales_Header_Property_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Sales_Header_Property_Key = d.Sales_Header_Property_Key
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Dimension].[Sales_Header_Properties]'
		,@Operation
		,@RecordCount
END
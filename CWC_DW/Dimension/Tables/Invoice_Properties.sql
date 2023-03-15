CREATE TABLE [Dimension].[Invoice_Properties] (
    [Invoice_Property_Key]         SMALLINT      IDENTITY (1, 1) NOT NULL,
    [Payment_Term]                 VARCHAR (14)  NULL,
    [Invoice_Line_Unit]            VARCHAR (5)   NULL,
    [Invoice_Header_Delivery_Mode] VARCHAR (50)  NULL,
    [Expedited_Shipping]           AS            (case when [Invoice_Header_Delivery_Mode]='FedEx Overnight' OR [Invoice_Header_Delivery_Mode]='2-Day Air' then 'Expedited Shipping' else 'Not Expedited Shipping' end),
    [is_Removed_From_Source]       BIT           NULL,
    [is_Excluded]                  BIT           NULL,
    [ETL_Created_Date]             DATETIME2 (5) NULL,
    [ETL_Modified_Date]            DATETIME2 (5) NULL,
    [ETL_Modified_Count]           TINYINT       NULL,
    CONSTRAINT [PK_Invoice_Properties] PRIMARY KEY CLUSTERED ([Invoice_Property_Key] ASC)
);






GO
 CREATE TRIGGER [Dimension].[tr_Invoice_Properties_Audit] ON [Dimension].[Invoice_Properties]
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
					INNER JOIN deleted d ON i.Invoice_Property_Key = d.Invoice_Property_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Invoice_Property_Key = d.Invoice_Property_Key
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Dimension].[Invoice_Properties]'
		,@Operation
		,@RecordCount
END
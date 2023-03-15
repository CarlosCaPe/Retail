CREATE TABLE [Dimension].[Sales_Line_Properties] (
    [Sales_Line_Property_Key]                  SMALLINT      IDENTITY (1, 1) NOT NULL,
    [Sales_Line_Status]                        VARCHAR (9)   NULL,
    [Sales_Line_Type]                          VARCHAR (12)  NULL,
    [Sales_Line_Tax_Group]                     VARCHAR (25)  NULL,
    [Sales_Line_Unit]                          VARCHAR (25)  NULL,
    [Sales_Line_Return_Deposition_Action]      VARCHAR (18)  NULL,
    [Sales_Line_Return_Deposition_Description] VARCHAR (100) NULL,
    [is_Removed_From_Source]                   BIT           NULL,
    [is_Excluded]                              BIT           NULL,
    [ETL_Created_Date]                         DATETIME2 (5) NULL,
    [ETL_Modified_Date]                        DATETIME2 (5) NULL,
    [ETL_Modified_Count]                       TINYINT       NULL,
    CONSTRAINT [PK_Sales_Lines_Attributes] PRIMARY KEY CLUSTERED ([Sales_Line_Property_Key] ASC),
    CONSTRAINT [UK_Sales_Line_Mapping_Attributes] UNIQUE NONCLUSTERED ([Sales_Line_Status] ASC, [Sales_Line_Type] ASC, [Sales_Line_Tax_Group] ASC, [Sales_Line_Unit] ASC, [Sales_Line_Return_Deposition_Action] ASC, [Sales_Line_Return_Deposition_Description] ASC)
);






GO
 CREATE TRIGGER [Dimension].[tr_Sales_Line_Properties_Audit] ON [Dimension].[Sales_Line_Properties]
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
					INNER JOIN deleted d ON i.Sales_Line_Property_Key = d.Sales_Line_Property_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Sales_Line_Property_Key = d.Sales_Line_Property_Key
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Dimension].[Sales_Line_Properties]'
		,@Operation
		,@RecordCount
END
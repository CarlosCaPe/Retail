CREATE TABLE [Dimension].[Credit_Card_Authorizations] (
    [Credit_Card_Authorization_Key] TINYINT       IDENTITY (1, 1) NOT NULL,
    [Authorization_Status]          VARCHAR (10)  NOT NULL,
    [First_Decline_Message]         VARCHAR (250) NOT NULL,
    [Last_Decline_Message]          VARCHAR (250) NULL,
    [First_Success_Message]         VARCHAR (250) NULL,
    [Last_Success_Message]          VARCHAR (250) NULL,
    [is_Removed_From_Source]        BIT           NULL,
    [is_Excluded]                   BIT           NULL,
    [ETL_Created_Date]              DATETIME2 (5) NULL,
    [ETL_Modified_Date]             DATETIME2 (5) NULL,
    [ETL_Modified_Count]            TINYINT       NULL,
    CONSTRAINT [PK_Credit_Card_Authorization_Attributes] PRIMARY KEY CLUSTERED ([Credit_Card_Authorization_Key] ASC)
);






GO
 CREATE TRIGGER [Dimension].[tr_Credit_Card_Authorizations_Audit] ON [Dimension].[Credit_Card_Authorizations]
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
					INNER JOIN deleted d ON i.Credit_Card_Authorization_Key = d.Credit_Card_Authorization_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Credit_Card_Authorization_Key = d.Credit_Card_Authorization_Key
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Dimension].[Credit_Card_Authorizations]'
		,@Operation
		,@RecordCount
END
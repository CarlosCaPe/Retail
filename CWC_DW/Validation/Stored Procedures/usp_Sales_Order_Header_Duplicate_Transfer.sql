﻿
CREATE PROC [Validation].[usp_Sales_Order_Header_Duplicate_Transfer]
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY
	DECLARE @procedureUpdateKey_ AS INT = 0
		,@USER AS VARCHAR(20) = current_user
		,@date AS SMALLDATETIME = getdate()
		,@stored_procedure_name VARCHAR(50) = OBJECT_NAME(@@PROCID);

	EXEC Administration.usp_Procedure_Updates_Insert @procedureName = @stored_procedure_name
		,@procedureUpdateKey = @procedureUpdateKey_ OUTPUT;
		--Archive Error Records
		;

	WITH Duplicate_Orders
	AS (
		SELECT s.SalesOrderNumber
		FROM [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] s
		GROUP BY s.SalesOrderNumber
		HAVING COUNT(*) > 1
		)
		,Duplicate_Seq
	AS (
		SELECT Seq = ROW_NUMBER() OVER (
				PARTITION BY s.SalesOrderNumber ORDER BY CASE [SALESORDERSTATUS]
						WHEN 0
							THEN 4 --'None'
						WHEN 1
							THEN 3 --'Backorder'
						WHEN 2
							THEN 2 --'Delivered'
						WHEN 3
							THEN 1 --'Invoiced'
						WHEN 4
							THEN 5 --'Canceled'
						END
					,s.[SALESTABLEMODIFIEDDATETIME] DESC
				)
			,s.*
		FROM Duplicate_Orders do
		INNER JOIN [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] s ON do.SALESORDERNUMBER = s.SALESORDERNUMBER
		) --SELECT * FROM Duplicate_Seq
	INSERT INTO [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging_Errors]
	SELECT Error_Transfer_Date = CAST(SYSUTCDATETIME() AS DATETIME2(5))
		,Error_Reason = 'Duplicate'
		,[SALESORDERNUMBER]
		,[DEFAULTLEDGERDIMENSIONDISPLAYVALUE]
		,[ISDELIVERYADDRESSORDERSPECIFIC]
		,[DELIVERYADDRESSCOUNTRYREGIONISOCODE]
		,[ISEXPORTSALE]
		,[SALESORDERPROCESSINGSTATUS]
		,[ARETOTALSCALCULATED]
		,[TRANSPORTATIONDOCUMENTLINEID]
		,[SALESTABLEMODIFIEDDATETIME]
		,[SALESTABLECREATEDDATETIME]
		,[RETAILCHANNELTABLE]
		,[SALESTYPE]
		,[DEFINITIONGROUP]
		,[EXECUTIONID]
		,[ISSELECTED]
		,[TRANSFERSTATUS]
		,[SALESORDERSTATUS]
		,[ORDERINGCUSTOMERACCOUNTNUMBER]
		,[INVOICECUSTOMERACCOUNTNUMBER]
		,[LINEDISCOUNTCUSTOMERGROUPCODE]
		,[CASHDISCOUNTCODE]
		,[PAYMENTTERMSBASEDATE]
		,[COMMISSIONCUSTOMERGROUPID]
		,[CONTACTPERSONID]
		,[CURRENCYCODE]
		,[CUSTOMERSORDERREFERENCE]
		,[SALESORDERPROMISINGMETHOD]
		,[DELIVERYADDRESSNAME]
		,[TOTALDISCOUNTPERCENTAGE]
		,[DELIVERYMODECODE]
		,[DELIVERYREASONCODE]
		,[DELIVERYTERMSCODE]
		,[EMAIL]
		,[TOTALDISCOUNTCUSTOMERGROUPCODE]
		,[EXPORTREASON]
		,[FIXEDDUEDATE]
		,[FIXEDEXCHANGERATE]
		,[INVOICEPAYMENTATTACHMENTTYPE]
		,[AREPRICESINCLUDINGSALESTAX]
		,[DEFAULTSHIPPINGWAREHOUSEID]
		,[DEFAULTSHIPPINGSITEID]
		,[LANGUAGEID]
		,[EUSALESLISTCODE]
		,[CHARGECUSTOMERGROUPID]
		,[ISSALESPROCESSINGSTOPPED]
		,[MULTILINEDISCOUNTCUSTOMERGROUPCODE]
		,[NUMBERSEQUENCEGROUPID]
		,[ISONETIMECUSTOMER]
		,[PAYMENTTERMSNAME]
		,[PAYMENTSCHEDULENAME]
		,[CUSTOMERPAYMENTMETHODNAME]
		,[CUSTOMERPAYMENTMETHODSPECIFICATIONNAME]
		,[WILLAUTOMATICINVENTORYRESERVATIONCONSIDERBATCHATTRIBUTES]
		,[SALESREBATECUSTOMERGROUPID]
		,[TMACUSTOMERGROUPID]
		,[INTRASTATPORTID]
		,[CUSTOMERPOSTINGPROFILEID]
		,[PRICECUSTOMERGROUPCODE]
		,[CUSTOMERREQUISITIONNUMBER]
		,[QUOTATIONNUMBER]
		,[CONFIRMEDRECEIPTDATE]
		,[REQUESTEDRECEIPTDATE]
		,[INVENTORYRESERVATIONMETHOD]
		,[COMMISSIONSALESREPRESENTATIVEGROUPID]
		,[SALESORDERNAME]
		,[SALESORDERORIGINCODE]
		,[SALESORDERPOOLID]
		,[SALESUNITID]
		,[CUSTOMERTRANSACTIONSETTLEMENTTYPE]
		,[CONFIRMEDSHIPPINGDATE]
		,[REQUESTEDSHIPPINGDATE]
		,[CAMPAIGNID]
		,[INTRASTATSTATISTICSPROCEDURECODE]
		,[SALESTAXGROUPCODE]
		,[INTRASTATTRANSACTIONCODE]
		,[INTRASTATTRANSPORTMODECODE]
		,[URL]
		,[TAXEXEMPTNUMBER]
		,[DIRECTDEBITMANDATEID]
		,[ORDERRESPONSIBLEPERSONNELNUMBER]
		,[ORDERTAKERPERSONNELNUMBER]
		,[ISENTRYCERTIFICATEREQUIRED]
		,[ISOWNENTRYCERTIFICATEISSUED]
		,[INVOICETYPE]
		,[TRANSPORTATIONBROKERID]
		,[SHIPPINGCARRIERID]
		,[SHIPPINGCARRIERSERVICEGROUPID]
		,[SHIPPINGCARRIERSERVICEID]
		,[TRANSPORTATIONMODEID]
		,[TRANSPORTATIONROUTEPLANID]
		,[TRANSPORTATIONTEMPLATEID]
		,[FORMATTEDDELVERYADDRESS]
		,[DELIVERYBUILDINGCOMPLIMENT]
		,[DELIVERYADDRESSCITY]
		,[DELIVERYADDRESSCOUNTRYREGIONID]
		,[DELIVERYADDRESSCOUNTYID]
		,[DELIVERYADDRESSDESCRIPTION]
		,[DELIVERYADDRESSDISTRICTNAME]
		,[DELIVERYADDRESSDUNSNUMBER]
		,[ISDELIVERYADDRESSPRIVATE]
		,[DELIVERYADDRESSLATITUDE]
		,[DELIVERYADDRESSLOCATIONID]
		,[DELIVERYADDRESSLONGITUDE]
		,[DELIVERYADDRESSPOSTBOX]
		,[DELIVERYADDRESSSTATEID]
		,[DELIVERYADDRESSSTREET]
		,[DELIVERYADDRESSSTREETNUMBER]
		,[DELIVERYADDRESSTIMEZONE]
		,[DELIVERYADDRESSZIPCODE]
		,[ISCONSOLIDATEDINVOICETARGET]
		,[EINVOICEDIMENSIONACCOUNTCODE]
		,[ISEINVOICEDIMENSIONACCOUNTCODESPECIFIEDPERLINE]
		,[CREDITNOTEREASONCODE]
		,[BANKCONSTANTSYMBOL]
		,[BANKSPECIFICSYMBOL]
		,[CFPSCODE]
		,[ISFINALUSER]
		,[CUSTOMERPAYMENTFINECODE]
		,[CUSTOMERPAYMENTFINANCIALINTERESTCODE]
		,[FISCALOPERATIONPRESENCETYPE]
		,[ISSERVICEDELIVERYADDRESSBASED]
		,[SERVICEFISCALINFORMATIONCODE]
		,[FISCALDOCUMENTOPERATIONTYPEID]
		,[FISCALDOCUMENTTYPEID]
		,[INVOICEADDRESSSTREET]
		,[FORMATTEDINVOICEADDRESS]
		,[INVOICEBUILDINGCOMPLIMENT]
		,[INVOICEADDRESSCITY]
		,[INVOICEADDRESSCOUNTRYREGIONID]
		,[INVOICEADDRESSCOUNTYID]
		,[INVOICEADDRESSDISTRICTNAME]
		,[ISINVOICEADDRESSPRIVATE]
		,[INVOICEADDRESSLATITUDE]
		,[INVOICEADDRESSLONGITUDE]
		,[INVOICEADDRESSPOSTBOX]
		,[INVOICEADDRESSSTATEID]
		,[INVOICEADDRESSSTREETNUMBER]
		,[INVOICEADDRESSTIMEZONE]
		,[INVOICEADDRESSZIPCODE]
		,[ORDERTOTALAMOUNT]
		,[ORDERTOTALCHARGESAMOUNT]
		,[ORDERTOTALDISCOUNTAMOUNT]
		,[ORDERTOTALTAXAMOUNT]
		,[TOTALDISCOUNTAMOUNT]
		,[RETURNREASONCODEID]
		,[PARTITION]
		,[SALESCREATEDDATETIME]
		,[DATAAREAID]
		,[SYNCSTARTDATETIME]
	FROM Duplicate_Seq
	WHERE seq > 1;

	--Sales Order Header Duplicate
	WITH Duplicate_Orders
	AS (
		SELECT s.SalesOrderNumber
		FROM [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] s
		GROUP BY s.SalesOrderNumber
		HAVING COUNT(*) > 1
		)
		,Duplicate_Seq
	AS (
		SELECT Seq = ROW_NUMBER() OVER (
				PARTITION BY s.SalesOrderNumber ORDER BY CASE [SALESORDERSTATUS]
						WHEN 0
							THEN 4 --'None'
						WHEN 1
							THEN 3 --'Backorder'
						WHEN 2
							THEN 2 --'Delivered'
						WHEN 3
							THEN 1 --'Invoiced'
						WHEN 4
							THEN 5 --'Canceled'
						END
					,s.[SALESTABLEMODIFIEDDATETIME] DESC
				)
			,s.*
		FROM [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] s
		WHERE SalesOrderNumber IN (
				SELECT SalesOrderNumber
				FROM Duplicate_Orders
				)
		)
	DELETE Duplicate_Seq
	WHERE seq > 1;

	UPDATE Administration.Procedure_Updates
	SET [Status] = 'SUCCESS'
		,Affected_Rows = @@ROWCOUNT
		,End_Date = getdate()
	WHERE Procedure_Update_Key = @procedureUpdateKey_
END TRY

BEGIN CATCH
	IF @procedureUpdateKey_ <> 0
		UPDATE [Administration].Procedure_Updates
		SET [Status] = 'FAILED'
			,Error = ERROR_MESSAGE()
			,End_Date = getdate()
		WHERE Procedure_Update_Key = @procedureUpdateKey_

	DECLARE @InputParameters NVARCHAR(MAX)

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SELECT @InputParameters = '';

	EXEC Administration.usp_Error_Logger_Insert @InputParameters;
END CATCH  

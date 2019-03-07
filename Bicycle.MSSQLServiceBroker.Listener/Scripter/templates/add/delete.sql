SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET NUMERIC_ROUNDABORT OFF
SET ARITHABORT ON
GO

CREATE TRIGGER [%Scheme%].[%Table%_ServiceBrokerListenerForDelete] ON [%Scheme%].[%Table%] FOR DELETE
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @ch UNIQUEIDENTIFIER
    DECLARE @messageBody NVARCHAR(MAX) = (SELECT * FROM deleted FOR XML RAW, ELEMENTS);

    IF ISNULL(@messageBody,'') = ''
        RETURN

    BEGIN DIALOG CONVERSATION @ch
        FROM SERVICE [%Scheme%_%Table%_ServiceBrokerListenerServiceForDelete]
        TO SERVICE '%Scheme%_%Table%_ServiceBrokerListenerServiceForDelete'
        ON CONTRACT [%Scheme%_%Table%_ServiceBrokerListenerContractForDelete]
        WITH ENCRYPTION = OFF;


    SEND ON CONVERSATION @ch MESSAGE TYPE [%Scheme%_%Table%_ServiceBrokerListenerMessageTypeForDelete] (@messageBody);
    COMMIT;
END	
GO
--=========================================
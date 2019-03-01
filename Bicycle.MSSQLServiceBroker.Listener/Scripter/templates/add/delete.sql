CREATE TRIGGER [%Table%_ServiceBrokerListenerForDelete] ON [%Table%] FOR DELETE
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @ch UNIQUEIDENTIFIER
    DECLARE @messageBody NVARCHAR(MAX);

    BEGIN DIALOG CONVERSATION @ch
        FROM SERVICE [%Table%_ServiceBrokerListenerServiceNameForDelete]
        TO SERVICE '%Table%_ServiceBrokerListenerServiceNameForDelete'
        ON CONTRACT [%Table%_ServiceBrokerListenerContractForDelete]
        WITH ENCRYPTION = OFF;

    SET @messageBody = (SELECT *
    FROM deleted
    FOR XML RAW, ELEMENTS);

    SEND ON CONVERSATION @ch MESSAGE TYPE [%Table%_ServiceBrokerListenerMessageTypeForDelete] (@messageBody);
    COMMIT;
END	
GO
--=========================================
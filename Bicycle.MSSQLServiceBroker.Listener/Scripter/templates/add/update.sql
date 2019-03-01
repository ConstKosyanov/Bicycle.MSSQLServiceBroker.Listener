CREATE TRIGGER [%Table%_ServiceBrokerListenerForUpdate] ON [%Table%] FOR UPDATE
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @ch UNIQUEIDENTIFIER
    DECLARE @messageBody NVARCHAR(MAX);

    BEGIN DIALOG CONVERSATION @ch
        FROM SERVICE [%Table%_ServiceBrokerListenerServiceNameForUpdate]
        TO SERVICE '%Table%_ServiceBrokerListenerServiceNameForUpdate'
        ON CONTRACT [%Table%_ServiceBrokerListenerContractForUpdate]
        WITH ENCRYPTION = OFF;

    SET @messageBody = (SELECT *
    FROM inserted
    FOR XML RAW, ELEMENTS);

    SEND ON CONVERSATION @ch MESSAGE TYPE [%Table%_ServiceBrokerListenerMessageTypeForUpdate] (@messageBody);
    COMMIT;
END	
GO
--=========================================
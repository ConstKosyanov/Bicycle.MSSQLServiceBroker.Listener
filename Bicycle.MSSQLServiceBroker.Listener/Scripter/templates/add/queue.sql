CREATE MESSAGE TYPE [%Table%_ServiceBrokerListenerMessageTypeFor%Operation%]
VALIDATION = WELL_FORMED_XML
GO
--=========================================
CREATE CONTRACT [%Table%_ServiceBrokerListenerContractFor%Operation%]([%Table%_ServiceBrokerListenerMessageTypeFor%Operation%] SENT BY INITIATOR)
GO
--=========================================
CREATE QUEUE [%Table%_ServiceBrokerListenerQueueFor%Operation%]
GO
--=========================================
CREATE SERVICE [%Table%_ServiceBrokerListenerServiceFor%Operation%]
ON QUEUE [%Table%_ServiceBrokerListenerQueueFor%Operation%]([%Table%_ServiceBrokerListenerContractFor%Operation%])
GO
--=========================================
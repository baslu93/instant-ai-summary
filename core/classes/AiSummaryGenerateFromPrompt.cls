public with sharing class AiSummaryGenerateFromPrompt {

    @TestVisible
    private static EinsteinLLMService service = new EinsteinLLMServiceImpl();

    @AuraEnabled
    public static String generate(String promptTemplateDeveloperName, String recordId) {
        validate(promptTemplateDeveloperName, recordId);

        ConnectApi.EinsteinPromptTemplateGenerationsInput input = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        input.isPreview = false;

        Schema.SObjectType sObjectType = ((Id) recordId).getSObjectType();
        String objectName = sObjectType.getDescribe().getName();

        ConnectApi.WrappedValue recordValue = new ConnectApi.WrappedValue();
        recordValue.value = new Map<String, Object>{ 'id' => recordId };

        input.inputParams = new Map<String, ConnectApi.WrappedValue>{
            'Input:' + objectName => recordValue
        };

        input.additionalConfig = new ConnectApi.EinsteinLLMAdditionalConfigInput();
        input.additionalConfig.numGenerations = 1;

        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation result;
        try {
            result = service.generateMessagesForPromptTemplate(promptTemplateDeveloperName, input);
        } catch (Exception e) {
            throw handledException(e.getMessage());
        }   
        if (result?.generations == null || result.generations.isEmpty()) {
            throw handledException('No response generated.');
        }
        return result.generations[0]?.text;
    }

    private static void validate(String promptTemplateDeveloperName, String recordId) {
        if (String.isBlank(promptTemplateDeveloperName)) {
            throw handledException('Prompt template is required.');
        }
        if (String.isBlank(recordId)) {
            throw handledException('Record ID is required.');
        }
    }

    private static AuraHandledException handledException(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }
}

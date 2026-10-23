public interface EinsteinLLMService {
    ConnectApi.EinsteinPromptRecordCollectionOutputRepresentation getPromptTemplates(
        String networkId, String language, Integer page, Integer pageSize,
        List<String> additionalFields, String promptTemplateType, String status, Boolean requireActive
    );
    ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generateMessagesForPromptTemplate(
        String promptTemplateDeveloperName,
        ConnectApi.EinsteinPromptTemplateGenerationsInput input
    );
}

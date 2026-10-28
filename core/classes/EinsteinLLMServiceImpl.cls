/** @description Concrete implementation of EinsteinLLMServiceInterface that delegates to ConnectApi.EinsteinLLM static methods. */
public class EinsteinLLMServiceImpl implements EinsteinLLMServiceInterface {
    /**
     * @description {@inheritDoc}
     * @param query Search query string
     * @param sortBy Field to sort results by
     * @param offset Pagination offset
     * @param pageLimit Maximum number of results per page
     * @param fields List of fields to include
     * @param type Prompt template type filter
     * @param relatedEntity Related entity API name
     * @param isActive Filter by active status
     * @return Collection of matching prompt template records
     */
    @SuppressWarnings('PMD.ExcessiveParameterList, PMD.AvoidBooleanMethodParameters') // mirrors ConnectApi.EinsteinLLM.getPromptTemplates signature
    public ConnectApi.EinsteinPromptRecordCollectionOutputRepresentation getPromptTemplates(
        String query, String sortBy, Integer offset, Integer pageLimit,
        List<String> fields, String type, String relatedEntity, Boolean isActive
    ) {
        return ConnectApi.EinsteinLLM.getPromptTemplates(query, sortBy, offset, pageLimit, fields, type, relatedEntity, isActive);
    }

    /**
     * @description {@inheritDoc}
     * @param promptTemplateDeveloperName Developer name of the prompt template to use
     * @param input Input representation containing merge field values
     * @return Generated message representations from the prompt template
     */
    public ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generateMessagesForPromptTemplate(
        String promptTemplateDeveloperName,
        ConnectApi.EinsteinPromptTemplateGenerationsInput input
    ) {
        return ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(promptTemplateDeveloperName, input);
    }
}

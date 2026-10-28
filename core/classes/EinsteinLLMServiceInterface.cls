@SuppressWarnings('PMD.ExcessiveParameterList, PMD.AvoidBooleanMethodParameters') // mirrors ConnectApi.EinsteinLLM.getPromptTemplates signature
/**
 * @description Interface for the Einstein LLM service, introduced to allow stubbing in test classes.
 */
public interface EinsteinLLMServiceInterface {
    /**
     * @description Retrieves a filtered list of Prompt Template records.
     * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_ConnectAPI_EinsteinLLM_static_methods.htm
     * @param query Search string; if null, all records are returned.
     * @param sortBy Field to sort results by; if null, records are returned in retrieval order.
     * @param offset Rows to skip for pagination; defaults to 0.
     * @param pageLimit Max records per page; defaults to 50.
     * @param fields Additional field names to return on top of the defaults; if null, only default fields are returned.
     * @param type Filters by template type; if null, all types are returned.
     * @param relatedEntity Filters by related entity; if null, all entities are returned.
     * @param isActive When true, only active templates are returned.
     * @return A collection of matching Prompt Template records.
     */
    ConnectApi.EinsteinPromptRecordCollectionOutputRepresentation getPromptTemplates(
        String query,
        String sortBy,
        Integer offset,
        Integer pageLimit,
        List<String> fields,
        String type,
        String relatedEntity,
        Boolean isActive
    );
    /**
     * @description Generates an LLM response using a specified Prompt Template and input parameters.
     * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_ConnectAPI_EinsteinLLM_static_methods.htm
     * @param promptTemplateDeveloperName Developer name or ID of the Prompt Template record.
     * @param input Input for generating a response using the specified Prompt Template.
     * @return The generated LLM response and resolved prompt template text.
     */
    ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generateMessagesForPromptTemplate(
        String promptTemplateDeveloperName,
        ConnectApi.EinsteinPromptTemplateGenerationsInput input
    );
}

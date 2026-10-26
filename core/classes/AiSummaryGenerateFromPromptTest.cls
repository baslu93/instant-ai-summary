@IsTest
private class AiSummaryGenerateFromPromptTest {

    private static final String TEMPLATE_DEV_NAME = 'AccountSummary';
    private static final Id RECORD_ID = '001000000000001AAA';
    private static final String GENERATED_TEXT = 'This is an AI-generated summary.';

    private class ThrowingEinsteinLLMService implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
            List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            throw new CalloutException('Service unavailable');
        }
    }

    private class MockEinsteinLLMService implements StubProvider {
        private ConnectApi.EinsteinPromptTemplateGenerationsRepresentation result;

        MockEinsteinLLMService(ConnectApi.EinsteinPromptTemplateGenerationsRepresentation result) {
            this.result = result;
        }

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
            List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'generateMessagesForPromptTemplate') return result;
            return null;
        }
    }

    private static ConnectApi.EinsteinPromptTemplateGenerationsRepresentation buildMock(String text) {
        ConnectApi.EinsteinLLMGenerationItemOutput generation = new ConnectApi.EinsteinLLMGenerationItemOutput();
        generation.text = text;

        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation result =
            new ConnectApi.EinsteinPromptTemplateGenerationsRepresentation();
        result.generations = new List<ConnectApi.EinsteinLLMGenerationItemOutput>{ generation };
        return result;
    }

    private static void setMock(ConnectApi.EinsteinPromptTemplateGenerationsRepresentation mock) {
        AiSummaryGenerateFromPrompt.service = (EinsteinLLMService) Test.createStub(
            EinsteinLLMService.class, new MockEinsteinLLMService(mock)
        );
    }

    @IsTest
    static void generate_returnsGeneratedText() {
        setMock(buildMock(GENERATED_TEXT));

        Test.startTest();
        String result = AiSummaryGenerateFromPrompt.generate(TEMPLATE_DEV_NAME, RECORD_ID);
        Test.stopTest();

        Assert.areEqual(GENERATED_TEXT, result);
    }

    @IsTest
    static void generate_throwsAuraHandledException_whenNoGenerations() {
        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation empty =
            new ConnectApi.EinsteinPromptTemplateGenerationsRepresentation();
        empty.generations = new List<ConnectApi.EinsteinLLMGenerationItemOutput>();
        setMock(empty);

        Test.startTest();
        try {
            AiSummaryGenerateFromPrompt.generate(TEMPLATE_DEV_NAME, RECORD_ID);
            Assert.fail('Expected AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.areEqual('No response generated.', e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void generate_throwsAuraHandledException_whenPromptTemplateIsBlank() {
        Test.startTest();
        try {
            AiSummaryGenerateFromPrompt.generate('', RECORD_ID);
            Assert.fail('Expected AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.areEqual('Prompt template is required.', e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void generate_throwsAuraHandledException_whenRecordIdIsBlank() {
        Test.startTest();
        try {
            AiSummaryGenerateFromPrompt.generate(TEMPLATE_DEV_NAME, '');
            Assert.fail('Expected AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.areEqual('Record ID is required.', e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void generate_throwsAuraHandledException_whenServiceThrows() {
        AiSummaryGenerateFromPrompt.service = (EinsteinLLMService) Test.createStub(
            EinsteinLLMService.class, new ThrowingEinsteinLLMService()
        );

        Test.startTest();
        try {
            AiSummaryGenerateFromPrompt.generate(TEMPLATE_DEV_NAME, RECORD_ID);
            Assert.fail('Expected AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.areEqual('Service unavailable', e.getMessage());
        }
        Test.stopTest();
    }
}

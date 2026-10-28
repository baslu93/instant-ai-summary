@IsTest
private class AiSummaryGenerateFromPromptTest {

    private static final String TEMPLATE_DEV_NAME = 'AccountSummary';
    @SuppressWarnings('PMD.AvoidHardcodingId') // fake placeholder ID for unit tests, not tied to any real environment
    private static final String RECORD_ID = '001000000000001AAA';
    private static final String GENERATED_TEXT = 'This is an AI-generated summary.';

    @TestSetup
    static void setup() {
        UserFactory.create();
    }

    /** @description Stub that always throws a CalloutException to simulate an LLM service failure. */
    private class ThrowingEinsteinLLMService implements StubProvider {
        /**
         * @description Throws a CalloutException regardless of which method is invoked on the stub.
         *   Implements System.StubProvider.handleMethodCall.
         *   @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_interface_System_StubProvider.htm
         * @param stubbedObject The stubbed object.
         * @param stubbedMethodName The name of the invoked method.
         * @param returnType The return type of the invoked method.
         * @param listOfParamTypes A list of the parameter types of the invoked method.
         * @param listOfParamNames A list of the parameter names of the invoked method.
         * @param listOfArgs The actual argument values passed into this method at runtime.
         * @return Nothing — always throws before returning.
         */
        @SuppressWarnings('PMD.ExcessiveParameterList') // signature mandated by StubProvider interface
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
            List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            throw new CalloutException('Service unavailable');
        }
    }

    /** @description Stub that returns a pre-configured LLM response to simulate a successful service call. */
    private class MockEinsteinLLMService implements StubProvider {
        private ConnectApi.EinsteinPromptTemplateGenerationsRepresentation result;

        MockEinsteinLLMService(ConnectApi.EinsteinPromptTemplateGenerationsRepresentation result) {
            this.result = result;
        }

        /**
         * @description Returns the pre-configured result when generateMessagesForPromptTemplate is invoked.
         *   Implements System.StubProvider.handleMethodCall.
         *   @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_interface_System_StubProvider.htm
         * @param stubbedObject The stubbed object.
         * @param stubbedMethodName The name of the invoked method.
         * @param returnType The return type of the invoked method.
         * @param listOfParamTypes A list of the parameter types of the invoked method.
         * @param listOfParamNames A list of the parameter names of the invoked method.
         * @param listOfArgs The actual argument values passed into this method at runtime.
         * @return The pre-configured EinsteinPromptTemplateGenerationsRepresentation, or null for other methods.
         */
        @SuppressWarnings('PMD.ExcessiveParameterList') // signature mandated by StubProvider interface
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
            List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'generateMessagesForPromptTemplate'){
                return result;
            }
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
        AiSummaryGenerateFromPrompt.service = (EinsteinLLMServiceInterface) Test.createStub(
            EinsteinLLMServiceInterface.class, new MockEinsteinLLMService(mock)
        );
    }

    @IsTest
    static void shouldGenerateResponse() {
        setMock(buildMock(GENERATED_TEXT));
        User testUser = UserFactory.getMinAccessInstantAiSummaryUser();

        System.runAs(testUser) {
            Test.startTest();
            String result = AiSummaryGenerateFromPrompt.generate(TEMPLATE_DEV_NAME, testUser.Id);
            Test.stopTest();

            Assert.areEqual(GENERATED_TEXT, result);
        }
    }

    @IsTest
    static void shouldThrowExceptionWhenNoResponseGenerated() {
        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation empty =
            new ConnectApi.EinsteinPromptTemplateGenerationsRepresentation();
        empty.generations = new List<ConnectApi.EinsteinLLMGenerationItemOutput>();
        setMock(empty);
        User testUser = UserFactory.getMinAccessInstantAiSummaryUser();

        System.runAs(testUser) {
            Test.startTest();
            try {
                AiSummaryGenerateFromPrompt.generate(TEMPLATE_DEV_NAME, testUser.Id);
                Assert.fail('Expected AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.areEqual('No response generated.', e.getMessage());
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void shouldThrowExceptionWhenPromptTemplateIsNotProvided() {
        System.runAs(UserFactory.getMinAccessInstantAiSummaryUser()) {
            Test.startTest();
            try {
                AiSummaryGenerateFromPrompt.generate('', RECORD_ID);
                Assert.fail('Expected AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.areEqual('Prompt template is required.', e.getMessage());
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void shouldThrowExceptionWhenRecordIdIsNotProvided() {
        System.runAs(UserFactory.getMinAccessInstantAiSummaryUser()) {
            Test.startTest();
            try {
                AiSummaryGenerateFromPrompt.generate(TEMPLATE_DEV_NAME, '');
                Assert.fail('Expected AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.areEqual('Record ID is required.', e.getMessage());
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void shouldThrowExceptionWhenServiceThrows() {
        AiSummaryGenerateFromPrompt.service = (EinsteinLLMServiceInterface) Test.createStub(
            EinsteinLLMServiceInterface.class, new ThrowingEinsteinLLMService()
        );
        User testUser = UserFactory.getMinAccessInstantAiSummaryUser();

        System.runAs(testUser) {
            Test.startTest();
            try {
                AiSummaryGenerateFromPrompt.generate(TEMPLATE_DEV_NAME, testUser.Id);
                Assert.fail('Expected AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.areEqual('Service unavailable', e.getMessage());
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void shouldThrowExceptionWhenRecordIsNotAccessible() {
        System.runAs(UserFactory.getMinAccessInstantAiSummaryUser()) {
            Test.startTest();
            try {
                AiSummaryGenerateFromPrompt.generate(TEMPLATE_DEV_NAME, RECORD_ID);
                Assert.fail('Expected AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.areEqual('Unable to access the specified record.', e.getMessage());
            }
            Test.stopTest();
        }
    }
}
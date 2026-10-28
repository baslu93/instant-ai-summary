public class UserFactory {

    private static final String MINIMUM_ACCESS_PROFILE = 'Minimum Access - Salesforce';
    private static final String PERMISSION_SET_NAME = 'InstantAiSummaryUser';
    private static final String EINSTEIN_GPT_PERMISSION_SET = 'EinsteinGPTPromptTemplateUser';

    /** @description Creates a test user with Minimum Access profile, EinsteinGPTPromptTemplateUser and InstantAiSummaryUser permission sets. */
    public static User create() {
        Profile p = [
            SELECT Id FROM Profile
            WHERE Name = :MINIMUM_ACCESS_PROFILE
            WITH USER_MODE
            LIMIT 1
        ];

        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'instant.ai.summary.test@example.com',
            Username = 'instant.ai.summary.test.' + System.currentTimeMillis() + '@example.com',
            Alias = 'iasuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert u;

        List<PermissionSet> permissionSets = [
            SELECT Id FROM PermissionSet
            WHERE Name IN (:PERMISSION_SET_NAME, :EINSTEIN_GPT_PERMISSION_SET)
            WITH USER_MODE
        ];

        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (PermissionSet ps : permissionSets) {
            assignments.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id));
        }
        insert assignments;

        return u;
    }

    /** @description Retrieves the test user created by the create method. */
    public static User getMinAccessInstantAiSummaryUser() {
        return [
            SELECT Id FROM User
            WHERE Alias = 'iasuser'
            WITH USER_MODE
            LIMIT 1
        ];
    }
}

@IsTest
private class CaseMilestonesTest {
    @IsTest
    static void createNoCriteriaMilestones() {
        Account testAccount = new Account(
            Name = 'test');
        insert testAccount;

        Entitlement testEntitlement = new Entitlement(
            AccountId = testAccount.Id,
            Name = 'test');
        insert testEntitlement;

        Case testCase = new Case(
            Priority = 'Medium',
            Origin = 'Email',
            EntitlementId = testEntitlement.Id,
            AccountId = testAccount.Id);

        Test.startTest();
        insert testCase;
        Test.stopTest();

        // Doing this with the UI, some milestones get created, namely 'Resolution' and 'Close Case'
        List<CaseMilestone> milestones = [SELECT Id FROM CaseMilestone WHERE CaseId = :testCase.Id];
        System.assertNotEquals(0, milestones.size(), 'size of milestones');
    }
    @IsTest
    static void createMilestonesWithCriteria() {
        Account testAccount = new Account(
            Name = 'test');
        insert testAccount;

        Entitlement testEntitlement = new Entitlement(
            AccountId = testAccount.Id,
            Name = 'test');
        insert testEntitlement;

        Case testCase = new Case(
            Priority = 'Medium',
            Origin = 'Email',
            EntitlementId = testEntitlement.Id,
            AccountId = testAccount.Id);
        insert testCase;
        Test.setCreatedDate(testCase.Id, System.now().addHours(-1));

        Test.startTest();
        insert new Case_Interaction__c(
            Case__c = testCase.Id,
            Trackable__c = true,
            Interaction_Datetime__c = System.now().addMinutes(-5),
            Sender__c = 'CUSTOMER',
            Recipient__c = 'AGENT');
        Test.stopTest();

        Case checkCase = [SELECT OwnerId, Is_Awaiting_Customer__c, Is_Customer_Waiting__c, Last_Customer2Agent__c, Last_Agent2Customer__c FROM Case WHERE Id = :testCase.Id];
        System.assert(checkCase.Is_Customer_Waiting__c, 'customer should be waiting'); // when this is true, the SLA process should create a milestone called 'Respond to Customer'. This works as expected through UI.

        List<CaseMilestone> milestones = [SELECT Id FROM CaseMilestone WHERE CaseId = :testCase.Id AND MilestoneType.Name = 'Respond to Customer'];
        System.assertNotEquals(0, milestones.size(), 'size of milestones');
    }
}
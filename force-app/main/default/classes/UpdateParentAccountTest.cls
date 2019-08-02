/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class UpdateParentAccountTest {

    @TestSetup
    static void setup() {
        List<Account> accounts = new List<Account>();

        //add a parent account
        accounts.add(new Account(Name='Parent'));

        //add 100 other child accounts
        for (Integer i=0; i<100; i++) {
            accounts.add(new Account(Name='Child Account '+i));
        }
        insert accounts;
    }

    @isTest
    static void myUnitTest() {
        Id parentId = [SELECT Id FROM Account WHERE Name = 'Parent'][0].Id;
        List<Account> childAccounts = [SELECT Id, Name FROM Account WHERE Name LIKE 'Child Account%'];

        //create the queuable instance
        UpdateParentAccount updater = new UpdateParentAccount(childAccounts, parentId);

        //start and stop the test
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest();

        //validation and verification of results
        System.assertEquals(100, [SELECT count() FROM Account WHERE ParentId = :parentId]);
    }
}
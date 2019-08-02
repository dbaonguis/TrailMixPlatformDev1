global class UpdateContactAddresses implements Database.Batchable<SObject>, Database.Stateful {
    
    //instance member to retain state accross transactions
    global Integer recordsProcessed = 0;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return  Database.getQueryLocator(
            'SELECT Id, BillingStreet, BillingCity, BillingState, ' +
            'BillingPostalCode, (SELECT Id, MailingStreet, MailingCity, ' +
            'MailingState, MailingPostalCode FROM Contacts) FROM Account ' +
            'WHERE BillingCountry = \'USA\''
        );
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        //process each batch of records
        List<Contact> contacts = new List<Contact>();
        for (Account account : scope) {
            for (Contact contact : account.contacts) {
                contact.MailingStreet = account.BillingStreet;
                contact.MailingCity = account.BillingCity;
                contact.MailingState = account.BillingState;
                contact.MailingPostalCode = account.BillingPostalCode;

                // add contact to list to be updated
                contacts.add(contact);

                // increment the instance member counter
                recordsProcessed = recordsProcessed + 1;
            }
        }
        update contacts;
    }

    global void finish(Database.BatchableContext bc) {
        System.debug(recordsProcessed + ' records processed. Shazam!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];

        //Call some utility to send email
        EmailUtils.sendMessage(job, recordsProcessed);
    }
}

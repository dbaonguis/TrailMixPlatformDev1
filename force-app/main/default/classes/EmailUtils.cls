public with sharing class EmailUtils {
    public EmailUtils() {}

    public static void sendMessage(AsyncApexJob job, Integer recordsProcessed) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('AsyncApexJob Id:' + job.Id);
        email.setToAddresses(new List<String> {job.CreatedBy.Email});
        email.setPlainTextBody(recordsProcessed + ' records processed!');

        Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[]{};
        emails.add(email);

        Messaging.sendEmail(emails);
    }
}

global class RemindOpptyOwners implements Schedulable {
    public RemindOpptyOwners() {}

    global void execute(SchedulableContext ctx) {
        List<Opportunity> opptys = [SELECT Id, Name, OwnerId, CloseDate FROM Opportunity WHERE IsClosed = False AND CloseDate < Today];

        //Create a 'Task' for each opportunity in the list
        List<Task> tasks = new List<Task>();
        for (Opportunity opp : opptys) {
            tasks.add(new Task(Subject='Expired Opportunity!', ActivityDate=Date.today()+5, WhatId=opp.Id, OwnerId=opp.OwnerId));
        }
        if (tasks.size() > 0) insert tasks;
    }
}

global class CloseCasesInWorkforceScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        CloseCasesInWorkForce batch = new CloseCasesInWorkForce();
        database.executebatch(batch);
    }
}
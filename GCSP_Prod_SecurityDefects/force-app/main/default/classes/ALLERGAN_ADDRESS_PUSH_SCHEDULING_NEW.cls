// EMH 29/7/2015 - Version for ALLERGAN.
// This is a sample class for scheduling Child Account Push
// We recommend to keep the batch sizes small becuase there is a lot processing that goes into addresses in the triggers.
// 10 is a good batch size. DO NOT EDIT IN PLACE.  COPY AND CREATE YOUR OWN VERSION.

global class ALLERGAN_ADDRESS_PUSH_SCHEDULING_NEW implements Schedulable{
   global void execute(SchedulableContext sc) {
        VEEVA_BATCH_CHILD_ACCOUNT_PUSH b = new VEEVA_BATCH_CHILD_ACCOUNT_PUSH();
        database.executebatch(b,1);
    
        VEEVA_BATCH_CHILD_ACCOUNT_DELETE c = new VEEVA_BATCH_CHILD_ACCOUNT_DELETE();
        database.executebatch(c,1);
   

   }
}
global class AGN_MtngAtch_Link_Scheduler implements Schedulable{
    AGN_MtngAtch_Link obj = new AGN_MtngAtch_Link();
    global void execute(SchedulableContext sc){
        System.debug('## Inside execute() method of AGN_MtngAtch_Link_Scheduler class');
        obj.updateAttachmentLink(); 
        System.debug('## After updateAttachmentLink() method fire inside AGN_MtngAtch_Link_Scheduler class');   
    }
}
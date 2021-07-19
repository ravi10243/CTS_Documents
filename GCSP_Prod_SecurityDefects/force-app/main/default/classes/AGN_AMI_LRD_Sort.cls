global Class AGN_AMI_LRD_Sort implements Comparable
{
    public AMI_Lrn_Rel_Dtl_AGN__c ALRD;
    String sortType;
    public AGN_AMI_LRD_Sort(AMI_Lrn_Rel_Dtl_AGN__c ALRD, String sortType)
    {
        this.ALRD=ALRD;
        this.sortType=sortType;
    }
    global Integer compareTo(Object compareTo) {
        AGN_AMI_LRD_Sort compareToObj = (AGN_AMI_LRD_Sort)compareTo;
        Integer returnValue = 0;
        if(sortType=='Recommended')
        {
            
            if (compareToObj.ALRD.Module_AGN__r.AMI_Recommended_AGN__c == false)
            {
                returnValue = -1;
            }
            if (compareToObj.ALRD.Module_AGN__r.AMI_Recommended_AGN__c == true)
            {
                returnValue = 1;
            }
        }
        else if(sortType=='Recently Added')
        {
            if (this.ALRD.Module_AGN__r.LastModifiedDate < compareToObj.ALRD.Module_AGN__r.LastModifiedDate)
        	{
                returnValue = 1;
            } 
            else if (this.ALRD.Module_AGN__r.LastModifiedDate > compareToObj.ALRD.Module_AGN__r.LastModifiedDate)
            {
                returnValue = -1;
            } 
            return returnValue;  
        }
        return returnValue;       
    }
}
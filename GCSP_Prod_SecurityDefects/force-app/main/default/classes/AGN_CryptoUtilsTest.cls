@isTest
public class AGN_CryptoUtilsTest {


    @isTest
    public static void AGN_CryptoUtisTestMethod(){
        
      OAM_User_Settings__c oamUser = AGN_CustReg_TestUtilityClass.createOAMUser();            
      AGN_GCSP_Settings__c gcspSettings = AGN_CustReg_TestUtilityClass.createGCSPSettings();        
     
          Blob key = Crypto.generateAesKey(128);
        
         String method = 'AES256'; 
         String privateKey = AGN_OAMConstant.PRIVATEKEY; 
         String datastring = '';
         Integer intsize = 128;
        
        
        AGN_CryptoUtils cryptcl = new AGN_CryptoUtils();            
        	string encrypted = cryptcl.Encrypt(method, privateKey,datastring);                   
            string decrypted =  cryptcl.Decrypt(method, privateKey, encrypted); 
            system.assertEquals(datastring, decrypted); 
            cryptcl.GenerateAESKey(intsize);
            cryptcl.keyToString(key);
            cryptcl.keyFromString('');
        	cryptcl.getRandomKey();
    }
}
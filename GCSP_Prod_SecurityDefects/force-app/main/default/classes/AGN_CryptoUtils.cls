public class AGN_CryptoUtils {
    public String Encrypt(String method, String privateKey, String data) {
        Blob bKey = EncodingUtil.base64Decode(privateKey);
        System.debug('Encrypting: ' + Data);
        Blob bData = Blob.valueOf(data);
        Blob bEncrypted = Crypto.encryptWithManagedIV(method, bKey, bData);
        String output = EncodingUtil.base64Encode(bEncrypted);
        System.debug('Encrypted: ' + output);
        return output;
    }
    
    public String Decrypt(String method, String privateKey, String secureData) {
        Blob bKey = EncodingUtil.base64Decode(privateKey);
        System.debug('Decrypting: ' + secureData);
        Blob bSecureData = EncodingUtil.base64Decode(secureData);
        Blob bData = Crypto.decryptWithManagedIV(method, bKey, bSecureData);
        String output = bData.toString();
        System.debug('Decrypted: ' + output);
        return output;
    }
    
    public Blob GenerateAESKey(Integer size) {
        // Size values are 128, 192, 256
        return Crypto.generateAesKey(size);
    }
    
    public String keyToString(Blob bKey) {
        return EncodingUtil.base64Encode(bKey);
    }
    
    public Blob keyFromString(String sKey) {
        return EncodingUtil.base64Decode(sKey);
    }
    
    public String getRandomKey() {
        return String.valueOf(Crypto.getRandomInteger());
    }
}
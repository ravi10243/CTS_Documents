public class F3_FileUploadControler {
@AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
 
        return Id.valueOf(fileId);
    }
 
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
 
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
 
        insert oAttachment;
 
        return oAttachment.Id;
    }
 
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
 
        String existingBody = EncodingUtil.base64Encode(a.Body);
 
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
 
        update a;
    }
    
    @AuraEnabled
public static List<ContentDocument> getAllFiles(String recId) {
    

    /*List<Attachment> lAtt = [Select Id, Name, ContentType, LastModifiedDate, BodyLength
                            from Attachment 
                            where ParentID=:recId];*/
    Set<Id> documentIds = new Set<Id>(); 
    List<ContentDocumentLink> cdl=[SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:recId];  
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  
        }
		return [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds];

    /*for(Attachment att : lAtt){
        Doc vDoc = new Doc();
        vDoc.fileId = att.Id;
        vDoc.name = att.Name;
        vDoc.fileType = att.ContentType;
        vDoc.fileDate = att.LastModifiedDate;

        vDocs.add(vDoc);
    }*/

    

    //return lAtt;
}
}
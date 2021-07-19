global class AGN_AMI_Vidyard_Services_Class 
{
    public static AGN_AMI_Vidyard_Player_Wrapper player; 
    public static AGN_AMI_Vidyard_Stream_Wrapper stream; 
    public static vPlayer reqBody;
    public static vStream reqStreamBody;
    public static AMI_Vidyard_Credentials_AGN__c vCreds = AMI_Vidyard_Credentials_AGN__c.getInstance();
    webservice static String setupLiveStream(Id meetingId)
    {
        Medical_event_vod__c meeting = [Select id,Name,Event_Broadcast_Link_AGN__c,CreatedDate,Start_Time_vod__c from Medical_Event_vod__c where id =: meetingId limit 1];
        reqStreamBody = new vStream(Meeting.Name, Meeting.Start_Time_vod__c);
        reqBody = new vPlayer(meeting.Name);
        AGN_AMI_Vidyard_Services_Class.createPlayer();
        AGN_AMI_Vidyard_Services_Class.createStream();
        return player.uuid;
    }
    webservice static void createPlayer()
    {
        String endPoint = vCreds.CreatePlayer_Endpoint_AGN__c.replace('AUTH_TOKEN', vCreds.Authentication_Token_AGN__c);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        req.setBody(JSON.serialize(reqBody));
        System.debug(req);
        Http http = new Http();
        HTTPResponse res = http.send(req);            
        String retBody=  res.getBody(); 
        system.debug(res);
        System.debug(retBody);
        player = AGN_AMI_Vidyard_Player_Wrapper.parse(retBody);
        system.debug(player.uuid);
    }
    webservice static void createStream()
    {
        
        String endPoint = vCreds.CreateStream_Endpoint_AGN__c.replace('PLAYER_UUID', player.uuid).replace('AUTH_TOKEN', vCreds.Authentication_Token_AGN__c);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        req.setBody(JSON.serialize(reqStreamBody));
        System.debug(req);
        Http http = new Http();
        HTTPResponse res = http.send(req);            
        String retBody=  res.getBody(); 
        system.debug(res);
        System.debug(retBody);
        stream = AGN_AMI_Vidyard_Stream_Wrapper.parse(retBody);
        system.debug(player.uuid);
    }
    webservice static void getStreamInfo(Id meetingId,String uuid)
    {
        String endPoint = vCreds.GetStream_Endpoint_AGN__c.replace('PLAYER_UUID', uuid).replace('AUTH_TOKEN', vCreds.Authentication_Token_AGN__c);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        System.debug(req);
        Http http = new Http();
        HTTPResponse res = http.send(req);            
        String retBody=  res.getBody(); 
        system.debug(res);
        System.debug(retBody);
        stream = AGN_AMI_Vidyard_Stream_Wrapper.parse(retBody);
        Medical_event_vod__c meeting = new Medical_Event_vod__c(id = meetingId);
        meeting.Event_Broadcast_Link_AGN__c = vCreds.Player_Link_AGN__c + uuid;
        meeting.AMI_Vidyard_Stream_Key_AGN__c = stream.stream_key;
        meeting.AMI_Vidyard_Ingestion_URL_AGN__c = stream.ingest_url;
        meeting.AMI_Vidyard_Backup_Stream_Key_AGN__c = stream.backup_key;
        meeting.AMI_Vidyard_Backup_Ingestion_URL_AGN__c = stream.backup_url;
        update meeting;
    }
    public class vPlayer
    {
        String name; 
        public vPlayer(String name)
        {
            this.name = name;
        }
    }
    public class vStream
    {
        public String video_name; 
        public String air_date;
        public integer segment_length;
        public boolean has_redundant_streams;
        public vStream(String video_name, DateTime air_date)
        {
            this.video_name = video_name;
            this.air_date = JSON.serialize(air_date).remove('Z');
            system.debug(this.air_date);
            this.segment_length = 4;
            this.has_redundant_streams = true;
        }
    }   
}
public class AGN_AMI_Vidyard_Stream_Wrapper
{
    public String region;
    public Integer air_date;
    public String ingest_url;
    public String stream_key;
    public String email;
    public Integer segment_length;
    public Integer start_time;
    public Integer end_time;
    public Boolean has_redundant_streams;
    public String backup_url;
    public String backup_key;
    public Boolean channel_style;
    public Boolean trim_black_start;
    public Boolean disable_notifications;
    public Integer id;
    public Integer video_id;
    public String status;
    public static AGN_AMI_Vidyard_Stream_Wrapper parse(String json) {
        try
        {
            return (AGN_AMI_Vidyard_Stream_Wrapper) System.JSON.deserialize(json, AGN_AMI_Vidyard_Stream_Wrapper.class);
        }
        catch(Exception ex)
        {
            try 
            {
                List<AGN_AMI_Vidyard_Stream_Wrapper> streamList = (List<AGN_AMI_Vidyard_Stream_Wrapper>) System.JSON.deserialize(json, List<AGN_AMI_Vidyard_Stream_Wrapper>.class);
                system.debug(streamList);
                for(AGN_AMI_Vidyard_Stream_Wrapper vsw : streamList)
                    system.debug(vsw);
                return streamList[0];
            }
            catch(Exception ex2)
            {
                //Do Nothing
            }
        }
        return new AGN_AMI_Vidyard_Stream_Wrapper();
    }
}
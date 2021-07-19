public class AGN_AMI_Vidyard_Player_Wrapper
{
    public Object redirect_url;
    public Boolean redirect_whole_page;
    public List<Chapters_attributes> chapters_attributes;
    public String on_complete;
    public List<Chapters_attributes> tags_attributes;
    public Object description;
    public Integer release_date;
    public String name;
    public Boolean autoplay;
    public Boolean viral_sharing;
    public String viral_sharing_message;
    public String custom_sharing_link;
    public Boolean embed_button;
    public Integer width;
    public Integer height;
    public String color;
    public String playlist_color;
    public Boolean default_hd;
    public Boolean play_button;
    public Boolean splash_screen_fade;
    public Boolean hd_button;
    public Boolean sharing_page_comments;
    public Boolean playlist_always_open;
    public Boolean mute_onload;
    public Object name_overlay;
    public Boolean chatter_only;
    public String authorized_by;
    public Boolean sharing_page;
    public Object ignore_organization_ip_whitelist;
    public String caption_display;
    public String whitelisted_embed_domain;
    public String cta_position;
    public Boolean cta_closeable;
    public String cta_border_style;
    public Boolean pause_disabled;
    public String caption_color;
    public Object yt_live_stream;
    public String playlist_style;
    public Object custom_css;
    public Boolean context_menu;
    public Boolean disable_legacy;
    public String play_button_color;
    public Boolean hidden_controls;
    public String audio_player_visuals;
    public String background_style;
    public Integer id;
    public String uuid;
    public Integer organization_id;
    public Integer created_at;
    public Integer updated_at;
    public Object status;
    public Integer length_in_seconds;
    public Boolean is_secure;
    public Viral_sharing_options viral_sharing_options;
    public Boolean end_chapter_pause;
    public Boolean disable_playlist;
    public Boolean up_next;
    public Boolean disable_default_events;
    public Boolean disable_live_dvr;
    public Object source_player_uuid;
    public String created_by_client_id;
    public Object owner_id;
    public Boolean show_playback_speed;
    public String player_type;
    public class Chapters_attributes 
    {
        
    }
    public class Viral_sharing_options {
        public Integer id;
        public Boolean twitter;
        public Boolean facebook;
        public Boolean linkedin;
        public Boolean email;
        public String created_at;
        public String updated_at;
        public Integer player_options_id;
    }
    public static AGN_AMI_Vidyard_Player_Wrapper parse(String json) {
        return (AGN_AMI_Vidyard_Player_Wrapper) System.JSON.deserialize(json, AGN_AMI_Vidyard_Player_Wrapper.class);
    }
}
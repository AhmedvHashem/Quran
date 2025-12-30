using Newtonsoft.Json;

namespace QuranWindows.Models;

public class AudioFile
{
    [JsonProperty("id")]
    public int Id { get; set; }

    [JsonProperty("audio_url")]
    public string AudioUrl { get; set; } = string.Empty;
}

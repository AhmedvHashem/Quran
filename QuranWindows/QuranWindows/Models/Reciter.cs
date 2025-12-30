using Newtonsoft.Json;

namespace QuranWindows.Models;

public class Reciter
{
    [JsonProperty("id")]
    public int Id { get; set; }

    [JsonProperty("reciter_name")]
    public string ReciterName { get; set; } = string.Empty;

    [JsonProperty("style")]
    public string? Style { get; set; }
}

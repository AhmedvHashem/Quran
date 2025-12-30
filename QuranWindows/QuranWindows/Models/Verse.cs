using Newtonsoft.Json;

namespace QuranWindows.Models;

public class Verse
{
    [JsonProperty("id")]
    public int Id { get; set; }

    [JsonProperty("verse_number")]
    public int VerseNumber { get; set; }

    [JsonProperty("verse_key")]
    public string VerseKey { get; set; } = string.Empty;

    [JsonProperty("text_uthmani")]
    public string TextUthmani { get; set; } = string.Empty;
}

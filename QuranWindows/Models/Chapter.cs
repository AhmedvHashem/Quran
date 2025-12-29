using Newtonsoft.Json;

namespace QuranWindows.Models;

public class Chapter
{
    [JsonProperty("id")]
    public int Id { get; set; }

    [JsonProperty("name_simple")]
    public string NameSimple { get; set; } = string.Empty;

    [JsonProperty("name_arabic")]
    public string NameArabic { get; set; } = string.Empty;

    [JsonProperty("verses_count")]
    public int VersesCount { get; set; }

    [JsonProperty("translated_name")]
    public TranslatedName? TranslatedName { get; set; }
}

public class TranslatedName
{
    [JsonProperty("name")]
    public string Name { get; set; } = string.Empty;

    [JsonProperty("language_name")]
    public string LanguageName { get; set; } = string.Empty;
}

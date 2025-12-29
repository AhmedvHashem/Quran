using Newtonsoft.Json;
using System.Collections.Generic;

namespace QuranWindows.Models;

public class ChaptersResponse
{
    [JsonProperty("chapters")]
    public List<Chapter> Chapters { get; set; } = new();
}

public class VersesResponse
{
    [JsonProperty("verses")]
    public List<Verse> Verses { get; set; } = new();
    
    [JsonProperty("pagination")]
    public Pagination? Pagination { get; set; }
}

public class Pagination
{
    [JsonProperty("total_records")]
    public int TotalRecords { get; set; }
}

public class RecitationsResponse
{
    [JsonProperty("recitations")]
    public List<Reciter> Recitations { get; set; } = new();
}

public class ChapterRecitationResponse
{
    [JsonProperty("audio_file")]
    public AudioFile AudioFile { get; set; } = new();
}

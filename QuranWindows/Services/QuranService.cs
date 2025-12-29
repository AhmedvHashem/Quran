using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;
using QuranWindows.Models;

namespace QuranWindows.Services;

public class QuranService
{
    private static QuranService? _shared;
    public static QuranService Shared => _shared ??= new QuranService();

    private readonly HttpClient _httpClient;
    private const string BaseUrl = "https://api.quran.com/api/v4";

    private QuranService()
    {
        _httpClient = new HttpClient();
    }

    public async Task<List<Chapter>> FetchChaptersAsync()
    {
        var url = $"{BaseUrl}/chapters?language=en";
        var json = await _httpClient.GetStringAsync(url);
        var response = JsonConvert.DeserializeObject<ChaptersResponse>(json);
        return response?.Chapters ?? new List<Chapter>();
    }

    public async Task<List<Verse>> FetchVersesAsync(int chapterId)
    {
        // Using per_page=300 to match Swift implementation
        var url = $"{BaseUrl}/verses/by_chapter/{chapterId}?language=en&fields=text_uthmani&per_page=300";
        var json = await _httpClient.GetStringAsync(url);
        var response = JsonConvert.DeserializeObject<VersesResponse>(json);
        return response?.Verses ?? new List<Verse>();
    }

    public async Task<List<Reciter>> FetchRecitersAsync()
    {
        var url = $"{BaseUrl}/resources/recitations?language=en";
        var json = await _httpClient.GetStringAsync(url);
        var response = JsonConvert.DeserializeObject<RecitationsResponse>(json);
        return response?.Recitations ?? new List<Reciter>();
    }

    public async Task<string> FetchChapterAudioAsync(int reciterId, int chapterId)
    {
        var url = $"{BaseUrl}/chapter_recitations/{reciterId}/{chapterId}";
        var json = await _httpClient.GetStringAsync(url);
        var response = JsonConvert.DeserializeObject<ChapterRecitationResponse>(json);
        return response?.AudioFile?.AudioUrl ?? string.Empty;
    }
}

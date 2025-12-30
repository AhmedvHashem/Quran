using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using QuranWindows.Models;
using QuranWindows.Services;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading.Tasks;

namespace QuranWindows.ViewModels;

public partial class MainViewModel : ObservableObject
{
    private readonly QuranService _quranService;
    
    [ObservableProperty]
    private AudioPlayer _audioPlayer;

    [ObservableProperty]
    private ObservableCollection<Chapter> _chapters = new();

    [ObservableProperty]
    private ObservableCollection<Verse> _verses = new();

    [ObservableProperty]
    private ObservableCollection<Reciter> _reciters = new();

    [ObservableProperty]
    private Chapter? _selectedChapter;

    [ObservableProperty]
    private Reciter? _selectedReciter;

    [ObservableProperty]
    private bool _isLoading;

    [ObservableProperty]
    private string? _errorMessage;

    public MainViewModel()
    {
        _quranService = QuranService.Shared;
        _audioPlayer = new AudioPlayer();
        InitializeAsync();
    }

    private async void InitializeAsync()
    {
        await LoadChaptersAsync();
        await LoadRecitersAsync();
    }

    private async Task LoadChaptersAsync()
    {
        try
        {
            var chapters = await _quranService.FetchChaptersAsync();
            Chapters = new ObservableCollection<Chapter>(chapters);
            
            if (Chapters.Any())
            {
                SelectedChapter = Chapters.First();
            }
        }
        catch (System.Exception ex)
        {
            ErrorMessage = $"Failed to load chapters: {ex.Message}";
        }
    }

    private async Task LoadRecitersAsync()
    {
        try
        {
            var reciters = await _quranService.FetchRecitersAsync();
            Reciters = new ObservableCollection<Reciter>(reciters);
            
            // Default to Mishari (id 7) or first
            SelectedReciter = Reciters.FirstOrDefault(r => r.Id == 7) ?? Reciters.FirstOrDefault();
        }
        catch (System.Exception ex)
        {
            ErrorMessage = $"Failed to load reciters: {ex.Message}";
        }
    }

    partial void OnSelectedChapterChanged(Chapter? value)
    {
        if (value != null)
        {
            LoadVerses(value);
        }
    }

    private async void LoadVerses(Chapter chapter)
    {
        IsLoading = true;
        try
        {
            var verses = await _quranService.FetchVersesAsync(chapter.Id);
            Verses = new ObservableCollection<Verse>(verses);
        }
        catch (System.Exception ex)
        {
            ErrorMessage = $"Failed to load verses: {ex.Message}";
        }
        finally
        {
            IsLoading = false;
        }
    }

    [RelayCommand]
    private async Task PlayAudioAsync()
    {
        if (SelectedChapter == null || SelectedReciter == null) return;

        try
        {
            var url = await _quranService.FetchChapterAudioAsync(SelectedReciter.Id, SelectedChapter.Id);
            if (!string.IsNullOrEmpty(url))
            {
                // We need to run this on the UI thread? AudioPlayer methods are not async but might trigger UI updates.
                // Since this is invoked from a command, we are likely on UI thread.
                AudioPlayer.Play(url, SelectedReciter.ReciterName, SelectedChapter.NameSimple);
            }
        }
        catch (System.Exception ex)
        {
            ErrorMessage = $"Failed to play audio: {ex.Message}";
        }
    }

    [RelayCommand]
    private void TogglePlayPause()
    {
        AudioPlayer.TogglePlayPause();
    }
}

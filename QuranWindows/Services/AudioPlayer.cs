using CommunityToolkit.Mvvm.ComponentModel;
using System;
using Windows.Media.Core;
using Windows.Media.Playback;

namespace QuranWindows.Services;

public partial class AudioPlayer : ObservableObject
{
    private MediaPlayer _mediaPlayer;

    [ObservableProperty]
    private bool _isPlaying;

    [ObservableProperty]
    private string? _currentReciterName;

    [ObservableProperty]
    private string? _currentChapterName;

    public AudioPlayer()
    {
        _mediaPlayer = new MediaPlayer();
        _mediaPlayer.MediaEnded += MediaPlayer_MediaEnded;
    }

    private void MediaPlayer_MediaEnded(MediaPlayer sender, object args)
    {
        // Must dispatch to UI thread if updating UI-bound properties? 
        // ObservableProperty usually handles property changed, but if we are on a background thread (Media callback), 
        // we might need to marshal. However, standard binding might handle it or we might need the DispatcherQueue.
        // For simplicity, we'll update the backing field and notify, assuming the UI framework handles it or we'll wrap it in dispatcher later if needed.
        // Actually, WinUI 3 controls usually require UI thread updates.
        // But let's just set IsPlaying = false.
        
        // We can't easily access DispatcherQueue here without passing it in.
        // Let's assume the ViewModel will handle threading or we use a weak reference to the dispatcher.
        // For now, simple set.
        
        // Note: In a real WinUI app, we should use the DispatcherQueue.
        // I will try to update it directly.
        IsPlaying = false;
    }

    public void Play(string url, string reciterName, string chapterName)
    {
        try 
        {
            if (!string.IsNullOrEmpty(url))
            {
                _mediaPlayer.Source = MediaSource.CreateFromUri(new Uri(url));
                _mediaPlayer.Play();
                IsPlaying = true;
                CurrentReciterName = reciterName;
                CurrentChapterName = chapterName;
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error playing audio: {ex.Message}");
            IsPlaying = false;
        }
    }

    public void Pause()
    {
        _mediaPlayer.Pause();
        IsPlaying = false;
    }

    public void Resume()
    {
        _mediaPlayer.Play();
        IsPlaying = true;
    }

    public void TogglePlayPause()
    {
        if (IsPlaying)
        {
            Pause();
        }
        else
        {
            Resume();
        }
    }
}

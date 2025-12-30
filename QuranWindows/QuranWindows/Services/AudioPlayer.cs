using CommunityToolkit.Mvvm.ComponentModel;
using System;
using Windows.Media.Playback;
using Windows.Media.Core;

namespace QuranWindows.Services;

public partial class AudioPlayer : ObservableObject
{
    private MediaPlayer? _mediaPlayer;

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
        _mediaPlayer.MediaFailed += MediaPlayer_MediaFailed;
    }

    private void MediaPlayer_MediaEnded(MediaPlayer sender, object args)
    {
        IsPlaying = false;
    }

    private void MediaPlayer_MediaFailed(MediaPlayer sender, MediaPlayerFailedEventArgs args)
    {
        System.Diagnostics.Debug.WriteLine($"Media playback failed: {args.ErrorMessage}");
        IsPlaying = false;
    }

    public void Play(string url, string reciterName, string chapterName)
    {
        try 
        {
            if (!string.IsNullOrEmpty(url) && _mediaPlayer != null)
            {
                var mediaSource = MediaSource.CreateFromUri(new Uri(url));
                _mediaPlayer.Source = mediaSource;
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
        if (_mediaPlayer != null)
        {
            _mediaPlayer.Pause();
            IsPlaying = false;
        }
    }

    public void Resume()
    {
        if (_mediaPlayer != null)
        {
            _mediaPlayer.Play();
            IsPlaying = true;
        }
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

    public void Stop()
    {
        if (_mediaPlayer != null)
        {
            _mediaPlayer.Pause();
            _mediaPlayer.Source = null;
            IsPlaying = false;
        }
    }

    public void Dispose()
    {
        if (_mediaPlayer != null)
        {
            _mediaPlayer.MediaEnded -= MediaPlayer_MediaEnded;
            _mediaPlayer.MediaFailed -= MediaPlayer_MediaFailed;
            _mediaPlayer.Dispose();
            _mediaPlayer = null;
        }
    }
}

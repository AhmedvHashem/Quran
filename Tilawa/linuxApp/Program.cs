using Tilawa.Core.Api;

using var closed = new CancellationTokenSource();
var application = Adw.Application.New("com.hashem.Tilawa", Gio.ApplicationFlags.FlagsNone);

application.OnShutdown += (_, _) => closed.Cancel();
application.OnActivate += async (sender, _) =>
{
    var window = Adw.ApplicationWindow.New((Adw.Application)sender);
    var status = Gtk.Label.New("Loading reciters…");
    window.Title = "Tilawa";
    window.SetDefaultSize(960, 640);
    window.Content = status;
    window.Show();

    await using var library = new QuranLibrary();
    try
    {
        var reciters = await library.RecitersAsync(closed.Token);
        status.Label_ = $"{reciters.Count} reciters available";
    }
    catch (OperationCanceledException)
    {
        // Application shutdown cancels the shared coroutine.
    }
    catch (Exception error)
    {
        status.Label_ = $"Could not load reciters: {error.Message}";
    }
};

return application.RunWithSynchronizationContext(args);

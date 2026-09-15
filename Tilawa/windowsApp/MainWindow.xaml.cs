using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.UI.Xaml;
using Tilawa.Core.Api;

namespace TilawaWindows
{
    public sealed partial class MainWindow : Window
    {
        private readonly CancellationTokenSource _closed = new();
        private readonly QuranLibrary _library = new();

        public MainWindow()
        {
            InitializeComponent();
            Closed += OnClosed;
            _ = LoadRecitersAsync();
        }

        private async Task LoadRecitersAsync()
        {
            try
            {
                using var result = await _library.RecitersAsync(_closed.Token);
                using var failure = result.Failure;
                var reciters = result.Reciters;
                try
                {
                    GreetingText.Text = failure?.Message ?? $"{reciters.Count} reciters available";
                }
                finally
                {
                    foreach (var reciter in reciters) reciter.Dispose();
                }
            }
            catch (OperationCanceledException)
            {
                // Closing the window cancels the shared coroutine.
            }
            catch (Exception error)
            {
                GreetingText.Text = $"Could not load reciters: {error.Message}";
            }
        }

        private async void OnClosed(object sender, WindowEventArgs args)
        {
            _closed.Cancel();
            _closed.Dispose();
            await _library.DisposeAsync();
        }
    }
}

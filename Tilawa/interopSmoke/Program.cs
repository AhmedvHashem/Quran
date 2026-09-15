using Tilawa.Core.Api;

// Run on each real RID; compilation alone cannot prove native loading or disposal.
await using (var library = new QuranLibrary())
{
    using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(30));
    using var result = await library.RecitersAsync(timeout.Token);
    using var failure = result.Failure;
    if (failure != null) throw new Exception(failure.Message);
    var reciters = result.Reciters;
    try
    {
        if (reciters.Count == 0 || reciters.Any(r => string.IsNullOrWhiteSpace(r.Name)))
            throw new Exception("The live catalog did not return reciter models.");
        Console.WriteLine($"Loaded {reciters.Count} reciters through generated bindings.");
    }
    finally
    {
        foreach (var reciter in reciters) reciter.Dispose();
    }
}

await using (var library = new QuranLibrary())
{
    using var cancelled = new CancellationTokenSource();
    var pending = library.RecitersAsync(cancelled.Token);
    cancelled.Cancel();
    try
    {
        using var unexpected = await pending.WaitAsync(TimeSpan.FromSeconds(10));
        foreach (var reciter in unexpected.Reciters) reciter.Dispose();
        throw new Exception("Cancellation did not reach the shared operation.");
    }
    catch (OperationCanceledException) when (cancelled.IsCancellationRequested)
    {
        Console.WriteLine("Cancellation propagated; disposing the native coroutine scope.");
    }
}
await using (var library = new QuranLibrary())
{
    using var result = await library.SurahAsync(115, 123);
    using var failure = result.Failure;
    if (failure == null || failure.Retryable || failure.Code != QuranErrorCode.SurahUnavailable)
        throw new Exception("Structured domain failure did not survive the native bridge.");
}
Console.WriteLine("Native loading, models, cancellation, disposal and structured failures passed.");

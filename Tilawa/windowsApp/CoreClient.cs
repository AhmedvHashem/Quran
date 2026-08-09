using System;
using System.Runtime.InteropServices;

namespace TilawaWindows
{
    /// <summary>
    /// Idiomatic C# façade over the Shared.dll C ABI (see .opencode/skills/winui-bridge).
    /// P/Invoke stays in NativeMethods; WinUI code touches only this class.
    /// </summary>
    public static class CoreClient
    {
        public static int AbiVersion => NativeMethods.tilawa_abi_version();

        public static string Greet()
        {
            var ptr = NativeMethods.tilawa_greet();
            try
            {
                return Marshal.PtrToStringUTF8(ptr) ?? string.Empty;
            }
            finally
            {
                NativeMethods.tilawa_string_free(ptr);
            }
        }
    }

    internal static partial class NativeMethods
    {
        [LibraryImport("Shared.dll")]
        internal static partial int tilawa_abi_version();

        [LibraryImport("Shared.dll")]
        internal static partial IntPtr tilawa_greet();

        [LibraryImport("Shared.dll")]
        internal static partial void tilawa_string_free(IntPtr value);
    }
}

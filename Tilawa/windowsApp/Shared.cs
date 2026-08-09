using System;
using System.Runtime.InteropServices;

namespace TilawaWindows
{
    /// <summary>
    /// Idiomatic C# façade over the Shared.dll C ABI (see .agents/skills/kmp-windows-bridge).
    /// P/Invoke stays in NativeMethods; WinUI code touches only this class.
    /// </summary>
    public static class Shared
    {
        public static int AbiVersion => NativeMethods.shared_abi_version();

        public static string Greet()
        {
            var ptr = NativeMethods.shared_greet();
            try
            {
                return Marshal.PtrToStringUTF8(ptr) ?? string.Empty;
            }
            finally
            {
                NativeMethods.shared_string_free(ptr);
            }
        }
    }

    internal static partial class NativeMethods
    {
        [LibraryImport("Shared.dll")]
        internal static partial int shared_abi_version();

        [LibraryImport("Shared.dll")]
        internal static partial IntPtr shared_greet();

        [LibraryImport("Shared.dll")]
        internal static partial void shared_string_free(IntPtr value);
    }
}

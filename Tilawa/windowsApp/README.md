# Tilawa Windows App

The Windows native shell for Tilawa, built with **WinUI 3** and **C#** (.NET 8). Consumes the Kotlin/Native `:shared` core via C ABI (`Shared.dll`) wrapped by `Shared.cs`.

## Prerequisites

- **OS**: Windows 10 (version 1809 or higher) or Windows 11
- **SDK**: .NET 8.0 SDK (`net8.0-windows10.0.19041.0`)
- **JDK**: Java 17 or higher (for building `Shared.dll`)
- **WinUI 3**: Windows App SDK dependencies

---

## Building and Running

### 1. Build the Shared Core (`Shared.dll`)
The `TilawaWindows.csproj` file automatically builds `Shared.dll` via Gradle if missing. To manually build or refresh the dynamic library:
```cmd
..\gradlew.bat :shared:linkReleaseSharedMingwX64
```

### 2. Build the WinUI 3 App
```cmd
cd windowsApp
dotnet build TilawaWindows.csproj
```

### 3. Run the App
```cmd
cd windowsApp
dotnet run --project TilawaWindows.csproj
```

---

## Architecture Note

`windowsApp` uses a P/Invoke bridge in `Shared.cs` to communicate with `Shared.dll` exported C ABI symbols (`shared_greet`, `shared_abi_version`, `shared_string_free`).

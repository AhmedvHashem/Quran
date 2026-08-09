#ifndef KONAN_LIBSHARED_H
#define KONAN_LIBSHARED_H
#ifdef __cplusplus
extern "C" {
#endif
#ifdef __cplusplus
typedef bool            libShared_KBoolean;
#else
typedef _Bool           libShared_KBoolean;
#endif
typedef unsigned short     libShared_KChar;
typedef signed char        libShared_KByte;
typedef short              libShared_KShort;
typedef int                libShared_KInt;
typedef long long          libShared_KLong;
typedef unsigned char      libShared_KUByte;
typedef unsigned short     libShared_KUShort;
typedef unsigned int       libShared_KUInt;
typedef unsigned long long libShared_KULong;
typedef float              libShared_KFloat;
typedef double             libShared_KDouble;
typedef float __attribute__ ((__vector_size__ (16))) libShared_KVector128;
typedef void*              libShared_KNativePtr;
struct libShared_KType;
typedef struct libShared_KType libShared_KType;

typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_Byte;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_Short;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_Int;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_Long;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_Float;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_Double;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_Char;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_Boolean;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_Unit;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_UByte;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_UShort;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_UInt;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_ULong;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_Platform;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_Greeting;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_LinuxPlatform;

extern libShared_KInt shared_abi_version();
extern void* shared_greet();
extern void shared_string_free(void* value);

typedef struct {
  /* Service functions. */
  void (*DisposeStablePointer)(libShared_KNativePtr ptr);
  void (*DisposeString)(const char* string);
  libShared_KBoolean (*IsInstance)(libShared_KNativePtr ref, const libShared_KType* type);
  libShared_kref_kotlin_Byte (*createNullableByte)(libShared_KByte);
  libShared_KByte (*getNonNullValueOfByte)(libShared_kref_kotlin_Byte);
  libShared_kref_kotlin_Short (*createNullableShort)(libShared_KShort);
  libShared_KShort (*getNonNullValueOfShort)(libShared_kref_kotlin_Short);
  libShared_kref_kotlin_Int (*createNullableInt)(libShared_KInt);
  libShared_KInt (*getNonNullValueOfInt)(libShared_kref_kotlin_Int);
  libShared_kref_kotlin_Long (*createNullableLong)(libShared_KLong);
  libShared_KLong (*getNonNullValueOfLong)(libShared_kref_kotlin_Long);
  libShared_kref_kotlin_Float (*createNullableFloat)(libShared_KFloat);
  libShared_KFloat (*getNonNullValueOfFloat)(libShared_kref_kotlin_Float);
  libShared_kref_kotlin_Double (*createNullableDouble)(libShared_KDouble);
  libShared_KDouble (*getNonNullValueOfDouble)(libShared_kref_kotlin_Double);
  libShared_kref_kotlin_Char (*createNullableChar)(libShared_KChar);
  libShared_KChar (*getNonNullValueOfChar)(libShared_kref_kotlin_Char);
  libShared_kref_kotlin_Boolean (*createNullableBoolean)(libShared_KBoolean);
  libShared_KBoolean (*getNonNullValueOfBoolean)(libShared_kref_kotlin_Boolean);
  libShared_kref_kotlin_Unit (*createNullableUnit)(void);
  libShared_kref_kotlin_UByte (*createNullableUByte)(libShared_KUByte);
  libShared_KUByte (*getNonNullValueOfUByte)(libShared_kref_kotlin_UByte);
  libShared_kref_kotlin_UShort (*createNullableUShort)(libShared_KUShort);
  libShared_KUShort (*getNonNullValueOfUShort)(libShared_kref_kotlin_UShort);
  libShared_kref_kotlin_UInt (*createNullableUInt)(libShared_KUInt);
  libShared_KUInt (*getNonNullValueOfUInt)(libShared_kref_kotlin_UInt);
  libShared_kref_kotlin_ULong (*createNullableULong)(libShared_KULong);
  libShared_KULong (*getNonNullValueOfULong)(libShared_kref_kotlin_ULong);

  /* User functions. */
  struct {
    struct {
      struct {
        struct {
          struct {
            struct {
              libShared_KType* (*_type)(void);
              libShared_kref_com_hashem_tilawa_Greeting (*Greeting)();
              const char* (*greet)(libShared_kref_com_hashem_tilawa_Greeting thiz);
            } Greeting;
            struct {
              libShared_KType* (*_type)(void);
              const char* (*get_name)(libShared_kref_com_hashem_tilawa_Platform thiz);
            } Platform;
            struct {
              libShared_KType* (*_type)(void);
              libShared_kref_com_hashem_tilawa_LinuxPlatform (*LinuxPlatform)();
              const char* (*get_name)(libShared_kref_com_hashem_tilawa_LinuxPlatform thiz);
            } LinuxPlatform;
            libShared_KInt (*sharedAbiVersion)();
            void* (*sharedGreet)();
            void (*sharedStringFree)(void* value);
            libShared_kref_com_hashem_tilawa_Platform (*getPlatform)();
          } tilawa;
        } hashem;
      } com;
    } root;
  } kotlin;
} libShared_ExportedSymbols;
extern libShared_ExportedSymbols* libShared_symbols(void);
#ifdef __cplusplus
}  /* extern "C" */
#endif
#endif  /* KONAN_LIBSHARED_H */

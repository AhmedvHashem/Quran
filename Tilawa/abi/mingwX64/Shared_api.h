#ifndef KONAN_SHARED_H
#define KONAN_SHARED_H
#ifdef __cplusplus
extern "C" {
#endif
#ifdef __cplusplus
typedef bool            Shared_KBoolean;
#else
typedef _Bool           Shared_KBoolean;
#endif
typedef unsigned short     Shared_KChar;
typedef signed char        Shared_KByte;
typedef short              Shared_KShort;
typedef int                Shared_KInt;
typedef long long          Shared_KLong;
typedef unsigned char      Shared_KUByte;
typedef unsigned short     Shared_KUShort;
typedef unsigned int       Shared_KUInt;
typedef unsigned long long Shared_KULong;
typedef float              Shared_KFloat;
typedef double             Shared_KDouble;
#ifndef _MSC_VER
typedef float __attribute__ ((__vector_size__ (16))) Shared_KVector128;
#else
#include <xmmintrin.h>
typedef __m128 Shared_KVector128;
#endif
typedef void*              Shared_KNativePtr;
struct Shared_KType;
typedef struct Shared_KType Shared_KType;

typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_Byte;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_Short;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_Int;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_Long;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_Float;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_Double;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_Char;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_Boolean;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_Unit;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_UByte;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_UShort;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_UInt;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_ULong;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_Platform;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_Greeting;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_WindowsPlatform;

extern Shared_KInt shared_abi_version();
extern void* shared_greet();
extern void shared_string_free(void* value);

typedef struct {
  /* Service functions. */
  void (*DisposeStablePointer)(Shared_KNativePtr ptr);
  void (*DisposeString)(const char* string);
  Shared_KBoolean (*IsInstance)(Shared_KNativePtr ref, const Shared_KType* type);
  Shared_kref_kotlin_Byte (*createNullableByte)(Shared_KByte);
  Shared_KByte (*getNonNullValueOfByte)(Shared_kref_kotlin_Byte);
  Shared_kref_kotlin_Short (*createNullableShort)(Shared_KShort);
  Shared_KShort (*getNonNullValueOfShort)(Shared_kref_kotlin_Short);
  Shared_kref_kotlin_Int (*createNullableInt)(Shared_KInt);
  Shared_KInt (*getNonNullValueOfInt)(Shared_kref_kotlin_Int);
  Shared_kref_kotlin_Long (*createNullableLong)(Shared_KLong);
  Shared_KLong (*getNonNullValueOfLong)(Shared_kref_kotlin_Long);
  Shared_kref_kotlin_Float (*createNullableFloat)(Shared_KFloat);
  Shared_KFloat (*getNonNullValueOfFloat)(Shared_kref_kotlin_Float);
  Shared_kref_kotlin_Double (*createNullableDouble)(Shared_KDouble);
  Shared_KDouble (*getNonNullValueOfDouble)(Shared_kref_kotlin_Double);
  Shared_kref_kotlin_Char (*createNullableChar)(Shared_KChar);
  Shared_KChar (*getNonNullValueOfChar)(Shared_kref_kotlin_Char);
  Shared_kref_kotlin_Boolean (*createNullableBoolean)(Shared_KBoolean);
  Shared_KBoolean (*getNonNullValueOfBoolean)(Shared_kref_kotlin_Boolean);
  Shared_kref_kotlin_Unit (*createNullableUnit)(void);
  Shared_kref_kotlin_UByte (*createNullableUByte)(Shared_KUByte);
  Shared_KUByte (*getNonNullValueOfUByte)(Shared_kref_kotlin_UByte);
  Shared_kref_kotlin_UShort (*createNullableUShort)(Shared_KUShort);
  Shared_KUShort (*getNonNullValueOfUShort)(Shared_kref_kotlin_UShort);
  Shared_kref_kotlin_UInt (*createNullableUInt)(Shared_KUInt);
  Shared_KUInt (*getNonNullValueOfUInt)(Shared_kref_kotlin_UInt);
  Shared_kref_kotlin_ULong (*createNullableULong)(Shared_KULong);
  Shared_KULong (*getNonNullValueOfULong)(Shared_kref_kotlin_ULong);

  /* User functions. */
  struct {
    struct {
      struct {
        struct {
          struct {
            struct {
              Shared_KType* (*_type)(void);
              Shared_kref_com_hashem_tilawa_Greeting (*Greeting)();
              const char* (*greet)(Shared_kref_com_hashem_tilawa_Greeting thiz);
            } Greeting;
            struct {
              Shared_KType* (*_type)(void);
              const char* (*get_name)(Shared_kref_com_hashem_tilawa_Platform thiz);
            } Platform;
            struct {
              Shared_KType* (*_type)(void);
              Shared_kref_com_hashem_tilawa_WindowsPlatform (*WindowsPlatform)();
              const char* (*get_name)(Shared_kref_com_hashem_tilawa_WindowsPlatform thiz);
            } WindowsPlatform;
            Shared_KInt (*sharedAbiVersion)();
            void* (*sharedGreet)();
            void (*sharedStringFree)(void* value);
            Shared_kref_com_hashem_tilawa_Platform (*getPlatform)();
          } tilawa;
        } hashem;
      } com;
    } root;
  } kotlin;
} Shared_ExportedSymbols;
extern Shared_ExportedSymbols* Shared_symbols(void);
#ifdef __cplusplus
}  /* extern "C" */
#endif
#endif  /* KONAN_SHARED_H */

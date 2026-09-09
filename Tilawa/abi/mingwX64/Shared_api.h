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
} Shared_kref_com_hashem_tilawa_data_DownloadStatus;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_data_DownloadStatus_NOT_DOWNLOADED;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_data_DownloadStatus_DOWNLOADING;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_data_DownloadStatus_DOWNLOADED;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_data_DownloadStatus_Companion;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_Array;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlinx_serialization_KSerializer;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_data_DownloadStore;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_data_InMemoryDownloadStore;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_data_SettingsDownloadStore;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_russhwolf_settings_Settings;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_QuranRepository;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_Reciter;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_Any;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_Reciter_$serializer;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlinx_serialization_descriptors_SerialDescriptor;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlinx_serialization_encoding_Decoder;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlinx_serialization_encoding_Encoder;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_Reciter_Companion;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_Riwayah;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_Riwayah_$serializer;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_Riwayah_Companion;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_collections_Set;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition_$serializer;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition_Companion;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_Chapter;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_RevelationPlace;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_Chapter_$serializer;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_Chapter_Companion;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_RevelationPlace_MAKKAH;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_RevelationPlace_MADINAH;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_Verse;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_Verse_$serializer;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_Verse_Companion;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_VerseTiming;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_VerseTiming_$serializer;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_VerseTiming_Companion;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_kotlin_collections_List;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_$serializer;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_Companion;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_usecase_GetReciters;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_usecase_GetRecitationEditions;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_usecase_GetChapters;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_usecase_GetVerses;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_domain_usecase_GetSurah;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_Greeting;
typedef struct {
  Shared_KNativePtr pinned;
} Shared_kref_com_hashem_tilawa_QuranLibrary;
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
              struct {
                struct {
                  Shared_kref_com_hashem_tilawa_data_DownloadStatus (*get)(); /* enum entry for NOT_DOWNLOADED. */
                } NOT_DOWNLOADED;
                struct {
                  Shared_kref_com_hashem_tilawa_data_DownloadStatus (*get)(); /* enum entry for DOWNLOADING. */
                } DOWNLOADING;
                struct {
                  Shared_kref_com_hashem_tilawa_data_DownloadStatus (*get)(); /* enum entry for DOWNLOADED. */
                } DOWNLOADED;
                struct {
                  Shared_KType* (*_type)(void);
                  Shared_kref_com_hashem_tilawa_data_DownloadStatus_Companion (*_instance)();
                  Shared_kref_kotlinx_serialization_KSerializer (*serializer)(Shared_kref_com_hashem_tilawa_data_DownloadStatus_Companion thiz, Shared_kref_kotlin_Array typeParamsSerializers);
                  Shared_kref_kotlinx_serialization_KSerializer (*serializer_)(Shared_kref_com_hashem_tilawa_data_DownloadStatus_Companion thiz);
                } Companion;
                Shared_KType* (*_type)(void);
              } DownloadStatus;
              struct {
                Shared_KType* (*_type)(void);
                const char* (*localPath)(Shared_kref_com_hashem_tilawa_data_DownloadStore thiz, Shared_KInt editionId, Shared_KInt chapterId);
                void (*remove)(Shared_kref_com_hashem_tilawa_data_DownloadStore thiz, Shared_KInt editionId, Shared_KInt chapterId);
                void (*setStatus)(Shared_kref_com_hashem_tilawa_data_DownloadStore thiz, Shared_KInt editionId, Shared_KInt chapterId, Shared_kref_com_hashem_tilawa_data_DownloadStatus status, const char* localPath);
                Shared_kref_com_hashem_tilawa_data_DownloadStatus (*status)(Shared_kref_com_hashem_tilawa_data_DownloadStore thiz, Shared_KInt editionId, Shared_KInt chapterId);
              } DownloadStore;
              struct {
                Shared_KType* (*_type)(void);
                Shared_kref_com_hashem_tilawa_data_InMemoryDownloadStore (*InMemoryDownloadStore)();
                const char* (*localPath)(Shared_kref_com_hashem_tilawa_data_InMemoryDownloadStore thiz, Shared_KInt editionId, Shared_KInt chapterId);
                void (*remove)(Shared_kref_com_hashem_tilawa_data_InMemoryDownloadStore thiz, Shared_KInt editionId, Shared_KInt chapterId);
                void (*setStatus)(Shared_kref_com_hashem_tilawa_data_InMemoryDownloadStore thiz, Shared_KInt editionId, Shared_KInt chapterId, Shared_kref_com_hashem_tilawa_data_DownloadStatus status, const char* localPath);
                Shared_kref_com_hashem_tilawa_data_DownloadStatus (*status)(Shared_kref_com_hashem_tilawa_data_InMemoryDownloadStore thiz, Shared_KInt editionId, Shared_KInt chapterId);
              } InMemoryDownloadStore;
              struct {
                Shared_KType* (*_type)(void);
                Shared_kref_com_hashem_tilawa_data_SettingsDownloadStore (*SettingsDownloadStore)(Shared_kref_com_russhwolf_settings_Settings settings);
                const char* (*localPath)(Shared_kref_com_hashem_tilawa_data_SettingsDownloadStore thiz, Shared_KInt editionId, Shared_KInt chapterId);
                void (*remove)(Shared_kref_com_hashem_tilawa_data_SettingsDownloadStore thiz, Shared_KInt editionId, Shared_KInt chapterId);
                void (*setStatus)(Shared_kref_com_hashem_tilawa_data_SettingsDownloadStore thiz, Shared_KInt editionId, Shared_KInt chapterId, Shared_kref_com_hashem_tilawa_data_DownloadStatus status, const char* localPath);
                Shared_kref_com_hashem_tilawa_data_DownloadStatus (*status)(Shared_kref_com_hashem_tilawa_data_SettingsDownloadStore thiz, Shared_KInt editionId, Shared_KInt chapterId);
              } SettingsDownloadStore;
            } data;
            struct {
              struct {
                Shared_KType* (*_type)(void);
              } QuranRepository;
              struct {
                struct {
                  struct {
                    Shared_KType* (*_type)(void);
                    Shared_kref_com_hashem_tilawa_domain_model_Reciter_$serializer (*_instance)();
                    Shared_kref_kotlinx_serialization_descriptors_SerialDescriptor (*get_descriptor)(Shared_kref_com_hashem_tilawa_domain_model_Reciter_$serializer thiz);
                    Shared_kref_kotlin_Array (*childSerializers)(Shared_kref_com_hashem_tilawa_domain_model_Reciter_$serializer thiz);
                    Shared_kref_com_hashem_tilawa_domain_model_Reciter (*deserialize)(Shared_kref_com_hashem_tilawa_domain_model_Reciter_$serializer thiz, Shared_kref_kotlinx_serialization_encoding_Decoder decoder);
                    void (*serialize)(Shared_kref_com_hashem_tilawa_domain_model_Reciter_$serializer thiz, Shared_kref_kotlinx_serialization_encoding_Encoder encoder, Shared_kref_com_hashem_tilawa_domain_model_Reciter value);
                  } $serializer;
                  struct {
                    Shared_KType* (*_type)(void);
                    Shared_kref_com_hashem_tilawa_domain_model_Reciter_Companion (*_instance)();
                    Shared_kref_kotlinx_serialization_KSerializer (*serializer)(Shared_kref_com_hashem_tilawa_domain_model_Reciter_Companion thiz);
                  } Companion;
                  Shared_KType* (*_type)(void);
                  Shared_kref_com_hashem_tilawa_domain_model_Reciter (*Reciter)(Shared_KInt id, const char* name, const char* arabicName);
                  const char* (*get_arabicName)(Shared_kref_com_hashem_tilawa_domain_model_Reciter thiz);
                  Shared_KInt (*get_id)(Shared_kref_com_hashem_tilawa_domain_model_Reciter thiz);
                  const char* (*get_name)(Shared_kref_com_hashem_tilawa_domain_model_Reciter thiz);
                  Shared_KInt (*component1)(Shared_kref_com_hashem_tilawa_domain_model_Reciter thiz);
                  const char* (*component2)(Shared_kref_com_hashem_tilawa_domain_model_Reciter thiz);
                  const char* (*component3)(Shared_kref_com_hashem_tilawa_domain_model_Reciter thiz);
                  Shared_kref_com_hashem_tilawa_domain_model_Reciter (*copy)(Shared_kref_com_hashem_tilawa_domain_model_Reciter thiz, Shared_KInt id, const char* name, const char* arabicName);
                  Shared_KBoolean (*equals)(Shared_kref_com_hashem_tilawa_domain_model_Reciter thiz, Shared_kref_kotlin_Any other);
                  Shared_KInt (*hashCode)(Shared_kref_com_hashem_tilawa_domain_model_Reciter thiz);
                  const char* (*toString)(Shared_kref_com_hashem_tilawa_domain_model_Reciter thiz);
                } Reciter;
                struct {
                  struct {
                    Shared_KType* (*_type)(void);
                    Shared_kref_com_hashem_tilawa_domain_model_Riwayah_$serializer (*_instance)();
                    Shared_kref_kotlinx_serialization_descriptors_SerialDescriptor (*get_descriptor)(Shared_kref_com_hashem_tilawa_domain_model_Riwayah_$serializer thiz);
                    Shared_kref_kotlin_Array (*childSerializers)(Shared_kref_com_hashem_tilawa_domain_model_Riwayah_$serializer thiz);
                    Shared_kref_com_hashem_tilawa_domain_model_Riwayah (*deserialize)(Shared_kref_com_hashem_tilawa_domain_model_Riwayah_$serializer thiz, Shared_kref_kotlinx_serialization_encoding_Decoder decoder);
                    void (*serialize)(Shared_kref_com_hashem_tilawa_domain_model_Riwayah_$serializer thiz, Shared_kref_kotlinx_serialization_encoding_Encoder encoder, Shared_kref_com_hashem_tilawa_domain_model_Riwayah value);
                  } $serializer;
                  struct {
                    Shared_KType* (*_type)(void);
                    Shared_kref_com_hashem_tilawa_domain_model_Riwayah_Companion (*_instance)();
                    Shared_kref_kotlinx_serialization_KSerializer (*serializer)(Shared_kref_com_hashem_tilawa_domain_model_Riwayah_Companion thiz);
                  } Companion;
                  Shared_KType* (*_type)(void);
                  Shared_kref_com_hashem_tilawa_domain_model_Riwayah (*Riwayah)(Shared_kref_kotlin_Int id, const char* name);
                  Shared_kref_kotlin_Int (*get_id)(Shared_kref_com_hashem_tilawa_domain_model_Riwayah thiz);
                  const char* (*get_name)(Shared_kref_com_hashem_tilawa_domain_model_Riwayah thiz);
                  Shared_kref_kotlin_Int (*component1)(Shared_kref_com_hashem_tilawa_domain_model_Riwayah thiz);
                  const char* (*component2)(Shared_kref_com_hashem_tilawa_domain_model_Riwayah thiz);
                  Shared_kref_com_hashem_tilawa_domain_model_Riwayah (*copy)(Shared_kref_com_hashem_tilawa_domain_model_Riwayah thiz, Shared_kref_kotlin_Int id, const char* name);
                  Shared_KBoolean (*equals)(Shared_kref_com_hashem_tilawa_domain_model_Riwayah thiz, Shared_kref_kotlin_Any other);
                  Shared_KInt (*hashCode)(Shared_kref_com_hashem_tilawa_domain_model_Riwayah thiz);
                  const char* (*toString)(Shared_kref_com_hashem_tilawa_domain_model_Riwayah thiz);
                } Riwayah;
                struct {
                  struct {
                    Shared_KType* (*_type)(void);
                    Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition_$serializer (*_instance)();
                    Shared_kref_kotlinx_serialization_descriptors_SerialDescriptor (*get_descriptor)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition_$serializer thiz);
                    Shared_kref_kotlin_Array (*childSerializers)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition_$serializer thiz);
                    Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition (*deserialize)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition_$serializer thiz, Shared_kref_kotlinx_serialization_encoding_Decoder decoder);
                    void (*serialize)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition_$serializer thiz, Shared_kref_kotlinx_serialization_encoding_Encoder encoder, Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition value);
                  } $serializer;
                  struct {
                    Shared_KType* (*_type)(void);
                    Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition_Companion (*_instance)();
                    Shared_kref_kotlinx_serialization_KSerializer (*serializer)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition_Companion thiz);
                  } Companion;
                  Shared_KType* (*_type)(void);
                  Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition (*RecitationEdition)(Shared_KInt id, Shared_KInt reciterId, Shared_kref_com_hashem_tilawa_domain_model_Riwayah riwayah, const char* style, const char* serverBaseUrl, Shared_kref_kotlin_collections_Set availableSurahs, Shared_KBoolean hasTiming, Shared_KBoolean isFeatured);
                  Shared_kref_kotlin_collections_Set (*get_availableSurahs)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  Shared_KBoolean (*get_hasTiming)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  Shared_KInt (*get_id)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  Shared_KBoolean (*get_isFeatured)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  Shared_KInt (*get_reciterId)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  Shared_kref_com_hashem_tilawa_domain_model_Riwayah (*get_riwayah)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  const char* (*get_serverBaseUrl)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  const char* (*get_style)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  Shared_KInt (*component1)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  Shared_KInt (*component2)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  Shared_kref_com_hashem_tilawa_domain_model_Riwayah (*component3)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  const char* (*component4)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  const char* (*component5)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  Shared_kref_kotlin_collections_Set (*component6)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  Shared_KBoolean (*component7)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  Shared_KBoolean (*component8)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition (*copy)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz, Shared_KInt id, Shared_KInt reciterId, Shared_kref_com_hashem_tilawa_domain_model_Riwayah riwayah, const char* style, const char* serverBaseUrl, Shared_kref_kotlin_collections_Set availableSurahs, Shared_KBoolean hasTiming, Shared_KBoolean isFeatured);
                  Shared_KBoolean (*equals)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz, Shared_kref_kotlin_Any other);
                  Shared_KInt (*hashCode)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  const char* (*toString)(Shared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                } RecitationEdition;
                struct {
                  struct {
                    Shared_KType* (*_type)(void);
                    Shared_kref_com_hashem_tilawa_domain_model_Chapter_$serializer (*_instance)();
                    Shared_kref_kotlinx_serialization_descriptors_SerialDescriptor (*get_descriptor)(Shared_kref_com_hashem_tilawa_domain_model_Chapter_$serializer thiz);
                    Shared_kref_kotlin_Array (*childSerializers)(Shared_kref_com_hashem_tilawa_domain_model_Chapter_$serializer thiz);
                    Shared_kref_com_hashem_tilawa_domain_model_Chapter (*deserialize)(Shared_kref_com_hashem_tilawa_domain_model_Chapter_$serializer thiz, Shared_kref_kotlinx_serialization_encoding_Decoder decoder);
                    void (*serialize)(Shared_kref_com_hashem_tilawa_domain_model_Chapter_$serializer thiz, Shared_kref_kotlinx_serialization_encoding_Encoder encoder, Shared_kref_com_hashem_tilawa_domain_model_Chapter value);
                  } $serializer;
                  struct {
                    Shared_KType* (*_type)(void);
                    Shared_kref_com_hashem_tilawa_domain_model_Chapter_Companion (*_instance)();
                    Shared_kref_kotlinx_serialization_KSerializer (*serializer)(Shared_kref_com_hashem_tilawa_domain_model_Chapter_Companion thiz);
                  } Companion;
                  Shared_KType* (*_type)(void);
                  Shared_kref_com_hashem_tilawa_domain_model_Chapter (*Chapter)(Shared_KInt id, const char* name, const char* translatedName, const char* arabicName, Shared_KInt versesCount, Shared_kref_com_hashem_tilawa_domain_model_RevelationPlace revelationPlace);
                  const char* (*get_arabicName)(Shared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  Shared_KInt (*get_id)(Shared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  const char* (*get_name)(Shared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  Shared_kref_com_hashem_tilawa_domain_model_RevelationPlace (*get_revelationPlace)(Shared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  const char* (*get_translatedName)(Shared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  Shared_KInt (*get_versesCount)(Shared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  Shared_KInt (*component1)(Shared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  const char* (*component2)(Shared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  const char* (*component3)(Shared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  const char* (*component4)(Shared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  Shared_KInt (*component5)(Shared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  Shared_kref_com_hashem_tilawa_domain_model_RevelationPlace (*component6)(Shared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  Shared_kref_com_hashem_tilawa_domain_model_Chapter (*copy)(Shared_kref_com_hashem_tilawa_domain_model_Chapter thiz, Shared_KInt id, const char* name, const char* translatedName, const char* arabicName, Shared_KInt versesCount, Shared_kref_com_hashem_tilawa_domain_model_RevelationPlace revelationPlace);
                  Shared_KBoolean (*equals)(Shared_kref_com_hashem_tilawa_domain_model_Chapter thiz, Shared_kref_kotlin_Any other);
                  Shared_KInt (*hashCode)(Shared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  const char* (*toString)(Shared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                } Chapter;
                struct {
                  struct {
                    Shared_kref_com_hashem_tilawa_domain_model_RevelationPlace (*get)(); /* enum entry for MAKKAH. */
                  } MAKKAH;
                  struct {
                    Shared_kref_com_hashem_tilawa_domain_model_RevelationPlace (*get)(); /* enum entry for MADINAH. */
                  } MADINAH;
                  Shared_KType* (*_type)(void);
                } RevelationPlace;
                struct {
                  struct {
                    Shared_KType* (*_type)(void);
                    Shared_kref_com_hashem_tilawa_domain_model_Verse_$serializer (*_instance)();
                    Shared_kref_kotlinx_serialization_descriptors_SerialDescriptor (*get_descriptor)(Shared_kref_com_hashem_tilawa_domain_model_Verse_$serializer thiz);
                    Shared_kref_kotlin_Array (*childSerializers)(Shared_kref_com_hashem_tilawa_domain_model_Verse_$serializer thiz);
                    Shared_kref_com_hashem_tilawa_domain_model_Verse (*deserialize)(Shared_kref_com_hashem_tilawa_domain_model_Verse_$serializer thiz, Shared_kref_kotlinx_serialization_encoding_Decoder decoder);
                    void (*serialize)(Shared_kref_com_hashem_tilawa_domain_model_Verse_$serializer thiz, Shared_kref_kotlinx_serialization_encoding_Encoder encoder, Shared_kref_com_hashem_tilawa_domain_model_Verse value);
                  } $serializer;
                  struct {
                    Shared_KType* (*_type)(void);
                    Shared_kref_com_hashem_tilawa_domain_model_Verse_Companion (*_instance)();
                    Shared_kref_kotlinx_serialization_KSerializer (*serializer)(Shared_kref_com_hashem_tilawa_domain_model_Verse_Companion thiz);
                  } Companion;
                  Shared_KType* (*_type)(void);
                  Shared_kref_com_hashem_tilawa_domain_model_Verse (*Verse)(Shared_KInt number, const char* text);
                  Shared_KInt (*get_number)(Shared_kref_com_hashem_tilawa_domain_model_Verse thiz);
                  const char* (*get_text)(Shared_kref_com_hashem_tilawa_domain_model_Verse thiz);
                  Shared_KInt (*component1)(Shared_kref_com_hashem_tilawa_domain_model_Verse thiz);
                  const char* (*component2)(Shared_kref_com_hashem_tilawa_domain_model_Verse thiz);
                  Shared_kref_com_hashem_tilawa_domain_model_Verse (*copy)(Shared_kref_com_hashem_tilawa_domain_model_Verse thiz, Shared_KInt number, const char* text);
                  Shared_KBoolean (*equals)(Shared_kref_com_hashem_tilawa_domain_model_Verse thiz, Shared_kref_kotlin_Any other);
                  Shared_KInt (*hashCode)(Shared_kref_com_hashem_tilawa_domain_model_Verse thiz);
                  const char* (*toString)(Shared_kref_com_hashem_tilawa_domain_model_Verse thiz);
                } Verse;
                struct {
                  struct {
                    Shared_KType* (*_type)(void);
                    Shared_kref_com_hashem_tilawa_domain_model_VerseTiming_$serializer (*_instance)();
                    Shared_kref_kotlinx_serialization_descriptors_SerialDescriptor (*get_descriptor)(Shared_kref_com_hashem_tilawa_domain_model_VerseTiming_$serializer thiz);
                    Shared_kref_kotlin_Array (*childSerializers)(Shared_kref_com_hashem_tilawa_domain_model_VerseTiming_$serializer thiz);
                    Shared_kref_com_hashem_tilawa_domain_model_VerseTiming (*deserialize)(Shared_kref_com_hashem_tilawa_domain_model_VerseTiming_$serializer thiz, Shared_kref_kotlinx_serialization_encoding_Decoder decoder);
                    void (*serialize)(Shared_kref_com_hashem_tilawa_domain_model_VerseTiming_$serializer thiz, Shared_kref_kotlinx_serialization_encoding_Encoder encoder, Shared_kref_com_hashem_tilawa_domain_model_VerseTiming value);
                  } $serializer;
                  struct {
                    Shared_KType* (*_type)(void);
                    Shared_kref_com_hashem_tilawa_domain_model_VerseTiming_Companion (*_instance)();
                    Shared_kref_kotlinx_serialization_KSerializer (*serializer)(Shared_kref_com_hashem_tilawa_domain_model_VerseTiming_Companion thiz);
                  } Companion;
                  Shared_KType* (*_type)(void);
                  Shared_kref_com_hashem_tilawa_domain_model_VerseTiming (*VerseTiming)(Shared_KInt verseNumber, Shared_KLong startMs, Shared_KLong endMs);
                  Shared_KLong (*get_endMs)(Shared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz);
                  Shared_KLong (*get_startMs)(Shared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz);
                  Shared_KInt (*get_verseNumber)(Shared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz);
                  Shared_KInt (*component1)(Shared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz);
                  Shared_KLong (*component2)(Shared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz);
                  Shared_KLong (*component3)(Shared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz);
                  Shared_kref_com_hashem_tilawa_domain_model_VerseTiming (*copy)(Shared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz, Shared_KInt verseNumber, Shared_KLong startMs, Shared_KLong endMs);
                  Shared_KBoolean (*equals)(Shared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz, Shared_kref_kotlin_Any other);
                  Shared_KInt (*hashCode)(Shared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz);
                  const char* (*toString)(Shared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz);
                } VerseTiming;
                struct {
                  struct {
                    Shared_KType* (*_type)(void);
                    Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_$serializer (*_instance)();
                    Shared_kref_kotlinx_serialization_descriptors_SerialDescriptor (*get_descriptor)(Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_$serializer thiz);
                    Shared_kref_kotlin_Array (*childSerializers)(Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_$serializer thiz);
                    Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack (*deserialize)(Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_$serializer thiz, Shared_kref_kotlinx_serialization_encoding_Decoder decoder);
                    void (*serialize)(Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_$serializer thiz, Shared_kref_kotlinx_serialization_encoding_Encoder encoder, Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack value);
                  } $serializer;
                  struct {
                    Shared_KType* (*_type)(void);
                    Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_Companion (*_instance)();
                    Shared_kref_kotlinx_serialization_KSerializer (*serializer)(Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_Companion thiz);
                  } Companion;
                  Shared_KType* (*_type)(void);
                  Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack (*PlaybackTrack)(const char* trackUrl, Shared_kref_kotlin_collections_List verses, Shared_kref_kotlin_collections_List timing);
                  Shared_kref_kotlin_collections_List (*get_timing)(Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz);
                  const char* (*get_trackUrl)(Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz);
                  Shared_kref_kotlin_collections_List (*get_verses)(Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz);
                  const char* (*component1)(Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz);
                  Shared_kref_kotlin_collections_List (*component2)(Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz);
                  Shared_kref_kotlin_collections_List (*component3)(Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz);
                  Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack (*copy)(Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz, const char* trackUrl, Shared_kref_kotlin_collections_List verses, Shared_kref_kotlin_collections_List timing);
                  Shared_KBoolean (*equals)(Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz, Shared_kref_kotlin_Any other);
                  Shared_KInt (*hashCode)(Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz);
                  const char* (*toString)(Shared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz);
                } PlaybackTrack;
              } model;
              struct {
                struct {
                  Shared_KType* (*_type)(void);
                  Shared_kref_com_hashem_tilawa_domain_usecase_GetReciters (*GetReciters)(Shared_kref_com_hashem_tilawa_domain_QuranRepository repository);
                } GetReciters;
                struct {
                  Shared_KType* (*_type)(void);
                  Shared_kref_com_hashem_tilawa_domain_usecase_GetRecitationEditions (*GetRecitationEditions)(Shared_kref_com_hashem_tilawa_domain_QuranRepository repository);
                } GetRecitationEditions;
                struct {
                  Shared_KType* (*_type)(void);
                  Shared_kref_com_hashem_tilawa_domain_usecase_GetChapters (*GetChapters)(Shared_kref_com_hashem_tilawa_domain_QuranRepository repository);
                } GetChapters;
                struct {
                  Shared_KType* (*_type)(void);
                  Shared_kref_com_hashem_tilawa_domain_usecase_GetVerses (*GetVerses)(Shared_kref_com_hashem_tilawa_domain_QuranRepository repository);
                } GetVerses;
                struct {
                  Shared_KType* (*_type)(void);
                  Shared_kref_com_hashem_tilawa_domain_usecase_GetSurah (*GetSurah)(Shared_kref_com_hashem_tilawa_domain_QuranRepository repository);
                } GetSurah;
              } usecase;
            } domain;
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
              Shared_kref_com_hashem_tilawa_QuranLibrary (*QuranLibrary)(Shared_kref_com_hashem_tilawa_data_DownloadStore downloadStore);
              Shared_kref_com_hashem_tilawa_QuranLibrary (*QuranLibrary_)();
              Shared_kref_com_hashem_tilawa_data_DownloadStatus (*downloadStatus)(Shared_kref_com_hashem_tilawa_QuranLibrary thiz, Shared_KInt editionId, Shared_KInt chapterId);
              void (*markDownloaded)(Shared_kref_com_hashem_tilawa_QuranLibrary thiz, Shared_KInt editionId, Shared_KInt chapterId, const char* localPath);
              void (*removeDownload)(Shared_kref_com_hashem_tilawa_QuranLibrary thiz, Shared_KInt editionId, Shared_KInt chapterId);
              void (*setDownloadStatus)(Shared_kref_com_hashem_tilawa_QuranLibrary thiz, Shared_KInt editionId, Shared_KInt chapterId, Shared_kref_com_hashem_tilawa_data_DownloadStatus status);
            } QuranLibrary;
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

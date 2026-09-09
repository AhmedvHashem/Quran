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
} libShared_kref_com_hashem_tilawa_data_DownloadStatus;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_data_DownloadStatus_NOT_DOWNLOADED;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_data_DownloadStatus_DOWNLOADING;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_data_DownloadStatus_DOWNLOADED;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_data_DownloadStatus_Companion;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_Array;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlinx_serialization_KSerializer;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_data_DownloadStore;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_data_InMemoryDownloadStore;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_data_SettingsDownloadStore;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_russhwolf_settings_Settings;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_QuranRepository;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_Reciter;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_Any;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_Reciter_$serializer;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlinx_serialization_descriptors_SerialDescriptor;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlinx_serialization_encoding_Decoder;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlinx_serialization_encoding_Encoder;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_Reciter_Companion;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_Riwayah;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_Riwayah_$serializer;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_Riwayah_Companion;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_collections_Set;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition_$serializer;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition_Companion;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_Chapter;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_RevelationPlace;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_Chapter_$serializer;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_Chapter_Companion;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_RevelationPlace_MAKKAH;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_RevelationPlace_MADINAH;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_Verse;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_Verse_$serializer;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_Verse_Companion;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_VerseTiming;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_VerseTiming_$serializer;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_VerseTiming_Companion;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_kotlin_collections_List;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_$serializer;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_Companion;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_usecase_GetReciters;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_usecase_GetRecitationEditions;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_usecase_GetChapters;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_usecase_GetVerses;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_domain_usecase_GetSurah;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_Greeting;
typedef struct {
  libShared_KNativePtr pinned;
} libShared_kref_com_hashem_tilawa_QuranLibrary;
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
              struct {
                struct {
                  libShared_kref_com_hashem_tilawa_data_DownloadStatus (*get)(); /* enum entry for NOT_DOWNLOADED. */
                } NOT_DOWNLOADED;
                struct {
                  libShared_kref_com_hashem_tilawa_data_DownloadStatus (*get)(); /* enum entry for DOWNLOADING. */
                } DOWNLOADING;
                struct {
                  libShared_kref_com_hashem_tilawa_data_DownloadStatus (*get)(); /* enum entry for DOWNLOADED. */
                } DOWNLOADED;
                struct {
                  libShared_KType* (*_type)(void);
                  libShared_kref_com_hashem_tilawa_data_DownloadStatus_Companion (*_instance)();
                  libShared_kref_kotlinx_serialization_KSerializer (*serializer)(libShared_kref_com_hashem_tilawa_data_DownloadStatus_Companion thiz, libShared_kref_kotlin_Array typeParamsSerializers);
                  libShared_kref_kotlinx_serialization_KSerializer (*serializer_)(libShared_kref_com_hashem_tilawa_data_DownloadStatus_Companion thiz);
                } Companion;
                libShared_KType* (*_type)(void);
              } DownloadStatus;
              struct {
                libShared_KType* (*_type)(void);
                const char* (*localPath)(libShared_kref_com_hashem_tilawa_data_DownloadStore thiz, libShared_KInt editionId, libShared_KInt chapterId);
                void (*remove)(libShared_kref_com_hashem_tilawa_data_DownloadStore thiz, libShared_KInt editionId, libShared_KInt chapterId);
                void (*setStatus)(libShared_kref_com_hashem_tilawa_data_DownloadStore thiz, libShared_KInt editionId, libShared_KInt chapterId, libShared_kref_com_hashem_tilawa_data_DownloadStatus status, const char* localPath);
                libShared_kref_com_hashem_tilawa_data_DownloadStatus (*status)(libShared_kref_com_hashem_tilawa_data_DownloadStore thiz, libShared_KInt editionId, libShared_KInt chapterId);
              } DownloadStore;
              struct {
                libShared_KType* (*_type)(void);
                libShared_kref_com_hashem_tilawa_data_InMemoryDownloadStore (*InMemoryDownloadStore)();
                const char* (*localPath)(libShared_kref_com_hashem_tilawa_data_InMemoryDownloadStore thiz, libShared_KInt editionId, libShared_KInt chapterId);
                void (*remove)(libShared_kref_com_hashem_tilawa_data_InMemoryDownloadStore thiz, libShared_KInt editionId, libShared_KInt chapterId);
                void (*setStatus)(libShared_kref_com_hashem_tilawa_data_InMemoryDownloadStore thiz, libShared_KInt editionId, libShared_KInt chapterId, libShared_kref_com_hashem_tilawa_data_DownloadStatus status, const char* localPath);
                libShared_kref_com_hashem_tilawa_data_DownloadStatus (*status)(libShared_kref_com_hashem_tilawa_data_InMemoryDownloadStore thiz, libShared_KInt editionId, libShared_KInt chapterId);
              } InMemoryDownloadStore;
              struct {
                libShared_KType* (*_type)(void);
                libShared_kref_com_hashem_tilawa_data_SettingsDownloadStore (*SettingsDownloadStore)(libShared_kref_com_russhwolf_settings_Settings settings);
                const char* (*localPath)(libShared_kref_com_hashem_tilawa_data_SettingsDownloadStore thiz, libShared_KInt editionId, libShared_KInt chapterId);
                void (*remove)(libShared_kref_com_hashem_tilawa_data_SettingsDownloadStore thiz, libShared_KInt editionId, libShared_KInt chapterId);
                void (*setStatus)(libShared_kref_com_hashem_tilawa_data_SettingsDownloadStore thiz, libShared_KInt editionId, libShared_KInt chapterId, libShared_kref_com_hashem_tilawa_data_DownloadStatus status, const char* localPath);
                libShared_kref_com_hashem_tilawa_data_DownloadStatus (*status)(libShared_kref_com_hashem_tilawa_data_SettingsDownloadStore thiz, libShared_KInt editionId, libShared_KInt chapterId);
              } SettingsDownloadStore;
            } data;
            struct {
              struct {
                libShared_KType* (*_type)(void);
              } QuranRepository;
              struct {
                struct {
                  struct {
                    libShared_KType* (*_type)(void);
                    libShared_kref_com_hashem_tilawa_domain_model_Reciter_$serializer (*_instance)();
                    libShared_kref_kotlinx_serialization_descriptors_SerialDescriptor (*get_descriptor)(libShared_kref_com_hashem_tilawa_domain_model_Reciter_$serializer thiz);
                    libShared_kref_kotlin_Array (*childSerializers)(libShared_kref_com_hashem_tilawa_domain_model_Reciter_$serializer thiz);
                    libShared_kref_com_hashem_tilawa_domain_model_Reciter (*deserialize)(libShared_kref_com_hashem_tilawa_domain_model_Reciter_$serializer thiz, libShared_kref_kotlinx_serialization_encoding_Decoder decoder);
                    void (*serialize)(libShared_kref_com_hashem_tilawa_domain_model_Reciter_$serializer thiz, libShared_kref_kotlinx_serialization_encoding_Encoder encoder, libShared_kref_com_hashem_tilawa_domain_model_Reciter value);
                  } $serializer;
                  struct {
                    libShared_KType* (*_type)(void);
                    libShared_kref_com_hashem_tilawa_domain_model_Reciter_Companion (*_instance)();
                    libShared_kref_kotlinx_serialization_KSerializer (*serializer)(libShared_kref_com_hashem_tilawa_domain_model_Reciter_Companion thiz);
                  } Companion;
                  libShared_KType* (*_type)(void);
                  libShared_kref_com_hashem_tilawa_domain_model_Reciter (*Reciter)(libShared_KInt id, const char* name, const char* arabicName);
                  const char* (*get_arabicName)(libShared_kref_com_hashem_tilawa_domain_model_Reciter thiz);
                  libShared_KInt (*get_id)(libShared_kref_com_hashem_tilawa_domain_model_Reciter thiz);
                  const char* (*get_name)(libShared_kref_com_hashem_tilawa_domain_model_Reciter thiz);
                  libShared_KInt (*component1)(libShared_kref_com_hashem_tilawa_domain_model_Reciter thiz);
                  const char* (*component2)(libShared_kref_com_hashem_tilawa_domain_model_Reciter thiz);
                  const char* (*component3)(libShared_kref_com_hashem_tilawa_domain_model_Reciter thiz);
                  libShared_kref_com_hashem_tilawa_domain_model_Reciter (*copy)(libShared_kref_com_hashem_tilawa_domain_model_Reciter thiz, libShared_KInt id, const char* name, const char* arabicName);
                  libShared_KBoolean (*equals)(libShared_kref_com_hashem_tilawa_domain_model_Reciter thiz, libShared_kref_kotlin_Any other);
                  libShared_KInt (*hashCode)(libShared_kref_com_hashem_tilawa_domain_model_Reciter thiz);
                  const char* (*toString)(libShared_kref_com_hashem_tilawa_domain_model_Reciter thiz);
                } Reciter;
                struct {
                  struct {
                    libShared_KType* (*_type)(void);
                    libShared_kref_com_hashem_tilawa_domain_model_Riwayah_$serializer (*_instance)();
                    libShared_kref_kotlinx_serialization_descriptors_SerialDescriptor (*get_descriptor)(libShared_kref_com_hashem_tilawa_domain_model_Riwayah_$serializer thiz);
                    libShared_kref_kotlin_Array (*childSerializers)(libShared_kref_com_hashem_tilawa_domain_model_Riwayah_$serializer thiz);
                    libShared_kref_com_hashem_tilawa_domain_model_Riwayah (*deserialize)(libShared_kref_com_hashem_tilawa_domain_model_Riwayah_$serializer thiz, libShared_kref_kotlinx_serialization_encoding_Decoder decoder);
                    void (*serialize)(libShared_kref_com_hashem_tilawa_domain_model_Riwayah_$serializer thiz, libShared_kref_kotlinx_serialization_encoding_Encoder encoder, libShared_kref_com_hashem_tilawa_domain_model_Riwayah value);
                  } $serializer;
                  struct {
                    libShared_KType* (*_type)(void);
                    libShared_kref_com_hashem_tilawa_domain_model_Riwayah_Companion (*_instance)();
                    libShared_kref_kotlinx_serialization_KSerializer (*serializer)(libShared_kref_com_hashem_tilawa_domain_model_Riwayah_Companion thiz);
                  } Companion;
                  libShared_KType* (*_type)(void);
                  libShared_kref_com_hashem_tilawa_domain_model_Riwayah (*Riwayah)(libShared_kref_kotlin_Int id, const char* name);
                  libShared_kref_kotlin_Int (*get_id)(libShared_kref_com_hashem_tilawa_domain_model_Riwayah thiz);
                  const char* (*get_name)(libShared_kref_com_hashem_tilawa_domain_model_Riwayah thiz);
                  libShared_kref_kotlin_Int (*component1)(libShared_kref_com_hashem_tilawa_domain_model_Riwayah thiz);
                  const char* (*component2)(libShared_kref_com_hashem_tilawa_domain_model_Riwayah thiz);
                  libShared_kref_com_hashem_tilawa_domain_model_Riwayah (*copy)(libShared_kref_com_hashem_tilawa_domain_model_Riwayah thiz, libShared_kref_kotlin_Int id, const char* name);
                  libShared_KBoolean (*equals)(libShared_kref_com_hashem_tilawa_domain_model_Riwayah thiz, libShared_kref_kotlin_Any other);
                  libShared_KInt (*hashCode)(libShared_kref_com_hashem_tilawa_domain_model_Riwayah thiz);
                  const char* (*toString)(libShared_kref_com_hashem_tilawa_domain_model_Riwayah thiz);
                } Riwayah;
                struct {
                  struct {
                    libShared_KType* (*_type)(void);
                    libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition_$serializer (*_instance)();
                    libShared_kref_kotlinx_serialization_descriptors_SerialDescriptor (*get_descriptor)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition_$serializer thiz);
                    libShared_kref_kotlin_Array (*childSerializers)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition_$serializer thiz);
                    libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition (*deserialize)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition_$serializer thiz, libShared_kref_kotlinx_serialization_encoding_Decoder decoder);
                    void (*serialize)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition_$serializer thiz, libShared_kref_kotlinx_serialization_encoding_Encoder encoder, libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition value);
                  } $serializer;
                  struct {
                    libShared_KType* (*_type)(void);
                    libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition_Companion (*_instance)();
                    libShared_kref_kotlinx_serialization_KSerializer (*serializer)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition_Companion thiz);
                  } Companion;
                  libShared_KType* (*_type)(void);
                  libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition (*RecitationEdition)(libShared_KInt id, libShared_KInt reciterId, libShared_kref_com_hashem_tilawa_domain_model_Riwayah riwayah, const char* style, const char* serverBaseUrl, libShared_kref_kotlin_collections_Set availableSurahs, libShared_KBoolean hasTiming, libShared_KBoolean isFeatured);
                  libShared_kref_kotlin_collections_Set (*get_availableSurahs)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  libShared_KBoolean (*get_hasTiming)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  libShared_KInt (*get_id)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  libShared_KBoolean (*get_isFeatured)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  libShared_KInt (*get_reciterId)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  libShared_kref_com_hashem_tilawa_domain_model_Riwayah (*get_riwayah)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  const char* (*get_serverBaseUrl)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  const char* (*get_style)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  libShared_KInt (*component1)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  libShared_KInt (*component2)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  libShared_kref_com_hashem_tilawa_domain_model_Riwayah (*component3)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  const char* (*component4)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  const char* (*component5)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  libShared_kref_kotlin_collections_Set (*component6)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  libShared_KBoolean (*component7)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  libShared_KBoolean (*component8)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition (*copy)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz, libShared_KInt id, libShared_KInt reciterId, libShared_kref_com_hashem_tilawa_domain_model_Riwayah riwayah, const char* style, const char* serverBaseUrl, libShared_kref_kotlin_collections_Set availableSurahs, libShared_KBoolean hasTiming, libShared_KBoolean isFeatured);
                  libShared_KBoolean (*equals)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz, libShared_kref_kotlin_Any other);
                  libShared_KInt (*hashCode)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                  const char* (*toString)(libShared_kref_com_hashem_tilawa_domain_model_RecitationEdition thiz);
                } RecitationEdition;
                struct {
                  struct {
                    libShared_KType* (*_type)(void);
                    libShared_kref_com_hashem_tilawa_domain_model_Chapter_$serializer (*_instance)();
                    libShared_kref_kotlinx_serialization_descriptors_SerialDescriptor (*get_descriptor)(libShared_kref_com_hashem_tilawa_domain_model_Chapter_$serializer thiz);
                    libShared_kref_kotlin_Array (*childSerializers)(libShared_kref_com_hashem_tilawa_domain_model_Chapter_$serializer thiz);
                    libShared_kref_com_hashem_tilawa_domain_model_Chapter (*deserialize)(libShared_kref_com_hashem_tilawa_domain_model_Chapter_$serializer thiz, libShared_kref_kotlinx_serialization_encoding_Decoder decoder);
                    void (*serialize)(libShared_kref_com_hashem_tilawa_domain_model_Chapter_$serializer thiz, libShared_kref_kotlinx_serialization_encoding_Encoder encoder, libShared_kref_com_hashem_tilawa_domain_model_Chapter value);
                  } $serializer;
                  struct {
                    libShared_KType* (*_type)(void);
                    libShared_kref_com_hashem_tilawa_domain_model_Chapter_Companion (*_instance)();
                    libShared_kref_kotlinx_serialization_KSerializer (*serializer)(libShared_kref_com_hashem_tilawa_domain_model_Chapter_Companion thiz);
                  } Companion;
                  libShared_KType* (*_type)(void);
                  libShared_kref_com_hashem_tilawa_domain_model_Chapter (*Chapter)(libShared_KInt id, const char* name, const char* translatedName, const char* arabicName, libShared_KInt versesCount, libShared_kref_com_hashem_tilawa_domain_model_RevelationPlace revelationPlace);
                  const char* (*get_arabicName)(libShared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  libShared_KInt (*get_id)(libShared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  const char* (*get_name)(libShared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  libShared_kref_com_hashem_tilawa_domain_model_RevelationPlace (*get_revelationPlace)(libShared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  const char* (*get_translatedName)(libShared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  libShared_KInt (*get_versesCount)(libShared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  libShared_KInt (*component1)(libShared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  const char* (*component2)(libShared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  const char* (*component3)(libShared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  const char* (*component4)(libShared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  libShared_KInt (*component5)(libShared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  libShared_kref_com_hashem_tilawa_domain_model_RevelationPlace (*component6)(libShared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  libShared_kref_com_hashem_tilawa_domain_model_Chapter (*copy)(libShared_kref_com_hashem_tilawa_domain_model_Chapter thiz, libShared_KInt id, const char* name, const char* translatedName, const char* arabicName, libShared_KInt versesCount, libShared_kref_com_hashem_tilawa_domain_model_RevelationPlace revelationPlace);
                  libShared_KBoolean (*equals)(libShared_kref_com_hashem_tilawa_domain_model_Chapter thiz, libShared_kref_kotlin_Any other);
                  libShared_KInt (*hashCode)(libShared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                  const char* (*toString)(libShared_kref_com_hashem_tilawa_domain_model_Chapter thiz);
                } Chapter;
                struct {
                  struct {
                    libShared_kref_com_hashem_tilawa_domain_model_RevelationPlace (*get)(); /* enum entry for MAKKAH. */
                  } MAKKAH;
                  struct {
                    libShared_kref_com_hashem_tilawa_domain_model_RevelationPlace (*get)(); /* enum entry for MADINAH. */
                  } MADINAH;
                  libShared_KType* (*_type)(void);
                } RevelationPlace;
                struct {
                  struct {
                    libShared_KType* (*_type)(void);
                    libShared_kref_com_hashem_tilawa_domain_model_Verse_$serializer (*_instance)();
                    libShared_kref_kotlinx_serialization_descriptors_SerialDescriptor (*get_descriptor)(libShared_kref_com_hashem_tilawa_domain_model_Verse_$serializer thiz);
                    libShared_kref_kotlin_Array (*childSerializers)(libShared_kref_com_hashem_tilawa_domain_model_Verse_$serializer thiz);
                    libShared_kref_com_hashem_tilawa_domain_model_Verse (*deserialize)(libShared_kref_com_hashem_tilawa_domain_model_Verse_$serializer thiz, libShared_kref_kotlinx_serialization_encoding_Decoder decoder);
                    void (*serialize)(libShared_kref_com_hashem_tilawa_domain_model_Verse_$serializer thiz, libShared_kref_kotlinx_serialization_encoding_Encoder encoder, libShared_kref_com_hashem_tilawa_domain_model_Verse value);
                  } $serializer;
                  struct {
                    libShared_KType* (*_type)(void);
                    libShared_kref_com_hashem_tilawa_domain_model_Verse_Companion (*_instance)();
                    libShared_kref_kotlinx_serialization_KSerializer (*serializer)(libShared_kref_com_hashem_tilawa_domain_model_Verse_Companion thiz);
                  } Companion;
                  libShared_KType* (*_type)(void);
                  libShared_kref_com_hashem_tilawa_domain_model_Verse (*Verse)(libShared_KInt number, const char* text);
                  libShared_KInt (*get_number)(libShared_kref_com_hashem_tilawa_domain_model_Verse thiz);
                  const char* (*get_text)(libShared_kref_com_hashem_tilawa_domain_model_Verse thiz);
                  libShared_KInt (*component1)(libShared_kref_com_hashem_tilawa_domain_model_Verse thiz);
                  const char* (*component2)(libShared_kref_com_hashem_tilawa_domain_model_Verse thiz);
                  libShared_kref_com_hashem_tilawa_domain_model_Verse (*copy)(libShared_kref_com_hashem_tilawa_domain_model_Verse thiz, libShared_KInt number, const char* text);
                  libShared_KBoolean (*equals)(libShared_kref_com_hashem_tilawa_domain_model_Verse thiz, libShared_kref_kotlin_Any other);
                  libShared_KInt (*hashCode)(libShared_kref_com_hashem_tilawa_domain_model_Verse thiz);
                  const char* (*toString)(libShared_kref_com_hashem_tilawa_domain_model_Verse thiz);
                } Verse;
                struct {
                  struct {
                    libShared_KType* (*_type)(void);
                    libShared_kref_com_hashem_tilawa_domain_model_VerseTiming_$serializer (*_instance)();
                    libShared_kref_kotlinx_serialization_descriptors_SerialDescriptor (*get_descriptor)(libShared_kref_com_hashem_tilawa_domain_model_VerseTiming_$serializer thiz);
                    libShared_kref_kotlin_Array (*childSerializers)(libShared_kref_com_hashem_tilawa_domain_model_VerseTiming_$serializer thiz);
                    libShared_kref_com_hashem_tilawa_domain_model_VerseTiming (*deserialize)(libShared_kref_com_hashem_tilawa_domain_model_VerseTiming_$serializer thiz, libShared_kref_kotlinx_serialization_encoding_Decoder decoder);
                    void (*serialize)(libShared_kref_com_hashem_tilawa_domain_model_VerseTiming_$serializer thiz, libShared_kref_kotlinx_serialization_encoding_Encoder encoder, libShared_kref_com_hashem_tilawa_domain_model_VerseTiming value);
                  } $serializer;
                  struct {
                    libShared_KType* (*_type)(void);
                    libShared_kref_com_hashem_tilawa_domain_model_VerseTiming_Companion (*_instance)();
                    libShared_kref_kotlinx_serialization_KSerializer (*serializer)(libShared_kref_com_hashem_tilawa_domain_model_VerseTiming_Companion thiz);
                  } Companion;
                  libShared_KType* (*_type)(void);
                  libShared_kref_com_hashem_tilawa_domain_model_VerseTiming (*VerseTiming)(libShared_KInt verseNumber, libShared_KLong startMs, libShared_KLong endMs);
                  libShared_KLong (*get_endMs)(libShared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz);
                  libShared_KLong (*get_startMs)(libShared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz);
                  libShared_KInt (*get_verseNumber)(libShared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz);
                  libShared_KInt (*component1)(libShared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz);
                  libShared_KLong (*component2)(libShared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz);
                  libShared_KLong (*component3)(libShared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz);
                  libShared_kref_com_hashem_tilawa_domain_model_VerseTiming (*copy)(libShared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz, libShared_KInt verseNumber, libShared_KLong startMs, libShared_KLong endMs);
                  libShared_KBoolean (*equals)(libShared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz, libShared_kref_kotlin_Any other);
                  libShared_KInt (*hashCode)(libShared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz);
                  const char* (*toString)(libShared_kref_com_hashem_tilawa_domain_model_VerseTiming thiz);
                } VerseTiming;
                struct {
                  struct {
                    libShared_KType* (*_type)(void);
                    libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_$serializer (*_instance)();
                    libShared_kref_kotlinx_serialization_descriptors_SerialDescriptor (*get_descriptor)(libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_$serializer thiz);
                    libShared_kref_kotlin_Array (*childSerializers)(libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_$serializer thiz);
                    libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack (*deserialize)(libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_$serializer thiz, libShared_kref_kotlinx_serialization_encoding_Decoder decoder);
                    void (*serialize)(libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_$serializer thiz, libShared_kref_kotlinx_serialization_encoding_Encoder encoder, libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack value);
                  } $serializer;
                  struct {
                    libShared_KType* (*_type)(void);
                    libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_Companion (*_instance)();
                    libShared_kref_kotlinx_serialization_KSerializer (*serializer)(libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack_Companion thiz);
                  } Companion;
                  libShared_KType* (*_type)(void);
                  libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack (*PlaybackTrack)(const char* trackUrl, libShared_kref_kotlin_collections_List verses, libShared_kref_kotlin_collections_List timing);
                  libShared_kref_kotlin_collections_List (*get_timing)(libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz);
                  const char* (*get_trackUrl)(libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz);
                  libShared_kref_kotlin_collections_List (*get_verses)(libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz);
                  const char* (*component1)(libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz);
                  libShared_kref_kotlin_collections_List (*component2)(libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz);
                  libShared_kref_kotlin_collections_List (*component3)(libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz);
                  libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack (*copy)(libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz, const char* trackUrl, libShared_kref_kotlin_collections_List verses, libShared_kref_kotlin_collections_List timing);
                  libShared_KBoolean (*equals)(libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz, libShared_kref_kotlin_Any other);
                  libShared_KInt (*hashCode)(libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz);
                  const char* (*toString)(libShared_kref_com_hashem_tilawa_domain_model_PlaybackTrack thiz);
                } PlaybackTrack;
              } model;
              struct {
                struct {
                  libShared_KType* (*_type)(void);
                  libShared_kref_com_hashem_tilawa_domain_usecase_GetReciters (*GetReciters)(libShared_kref_com_hashem_tilawa_domain_QuranRepository repository);
                } GetReciters;
                struct {
                  libShared_KType* (*_type)(void);
                  libShared_kref_com_hashem_tilawa_domain_usecase_GetRecitationEditions (*GetRecitationEditions)(libShared_kref_com_hashem_tilawa_domain_QuranRepository repository);
                } GetRecitationEditions;
                struct {
                  libShared_KType* (*_type)(void);
                  libShared_kref_com_hashem_tilawa_domain_usecase_GetChapters (*GetChapters)(libShared_kref_com_hashem_tilawa_domain_QuranRepository repository);
                } GetChapters;
                struct {
                  libShared_KType* (*_type)(void);
                  libShared_kref_com_hashem_tilawa_domain_usecase_GetVerses (*GetVerses)(libShared_kref_com_hashem_tilawa_domain_QuranRepository repository);
                } GetVerses;
                struct {
                  libShared_KType* (*_type)(void);
                  libShared_kref_com_hashem_tilawa_domain_usecase_GetSurah (*GetSurah)(libShared_kref_com_hashem_tilawa_domain_QuranRepository repository);
                } GetSurah;
              } usecase;
            } domain;
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
              libShared_kref_com_hashem_tilawa_QuranLibrary (*QuranLibrary)(libShared_kref_com_hashem_tilawa_data_DownloadStore downloadStore);
              libShared_kref_com_hashem_tilawa_QuranLibrary (*QuranLibrary_)();
              libShared_kref_com_hashem_tilawa_data_DownloadStatus (*downloadStatus)(libShared_kref_com_hashem_tilawa_QuranLibrary thiz, libShared_KInt editionId, libShared_KInt chapterId);
              void (*markDownloaded)(libShared_kref_com_hashem_tilawa_QuranLibrary thiz, libShared_KInt editionId, libShared_KInt chapterId, const char* localPath);
              void (*removeDownload)(libShared_kref_com_hashem_tilawa_QuranLibrary thiz, libShared_KInt editionId, libShared_KInt chapterId);
              void (*setDownloadStatus)(libShared_kref_com_hashem_tilawa_QuranLibrary thiz, libShared_KInt editionId, libShared_KInt chapterId, libShared_kref_com_hashem_tilawa_data_DownloadStatus status);
            } QuranLibrary;
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

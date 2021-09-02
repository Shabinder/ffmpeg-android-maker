#!/usr/bin/env bash

case $ANDROID_ABI in
  x86)
    # Disabling assembler optimizations, because they have text relocations
    EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --disable-asm"
    ;;
  x86_64)
    EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --x86asmexe=${FAM_YASM}"
    ;;
esac

if [ "$FFMPEG_GPL_ENABLED" = true ] ; then
    EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --enable-gpl"
fi

# Preparing flags for enabling requested libraries
ADDITIONAL_COMPONENTS=
for LIBARY_NAME in ${FFMPEG_EXTERNAL_LIBRARIES[@]}
do
  ADDITIONAL_COMPONENTS+=" --enable-$LIBARY_NAME"
done

# Referencing dependencies without pkgconfig
DEP_CFLAGS="-I${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/include"
DEP_LD_FLAGS="-L${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}/lib $FFMPEG_EXTRA_LD_FLAGS"

./configure \
  --disable-doc \
  --disable-network \
  --disable-autodetect \
  --disable-swscale \
  --disable-muxers \
  --disable-demuxers \
  --disable-zlib \
  --disable-bzlib \
  --disable-iconv \
  --disable-bsfs \
  --disable-filters \
  --disable-parsers \
  --disable-indevs \
  --disable-outdevs \
  --disable-decoders \
  --disable-encoders \
  --disable-hwaccels \
  --disable-protocols \
  --disable-nvenc \
  --disable-xvmc \
  --disable-videotoolbox \
  --disable-audiotoolbox \
  --disable-filters \
  --enable-small \
  --enable-pthreads \
  --enable-gpl \
  --enable-pic \
  --prefix=${BUILD_DIR_FFMPEG}/${ANDROID_ABI} \
  --enable-cross-compile \
  --target-os=android \
  --arch=${TARGET_TRIPLE_MACHINE_ARCH} \
  --sysroot=${SYSROOT_PATH} \
  --cc=${FAM_CC} \
  --cxx=${FAM_CXX} \
  --ld=${FAM_LD} \
  --ar=${FAM_AR} \
  --as=${FAM_CC} \
  --nm=${FAM_NM} \
  --ranlib=${FAM_RANLIB} \
  --strip=${FAM_STRIP} \
  --extra-cflags="-O3 -fPIC $DEP_CFLAGS" \
  --extra-ldflags="$DEP_LD_FLAGS" \
  --enable-parser=aac*,mpegaudio \
  --enable-filter=aresample \
  --enable-bsf=aac_adtstoasc \
  --enable-decoder=aac*,ac3* \
  --enable-encoder=libmp3lame \
  --enable-demuxer=mov \
  --enable-muxer=mp3 \
  --enable-protocol=file \
  --disable-vulkan \
  --enable-static \
  --disable-shared \
  --pkg-config=${PKG_CONFIG_EXECUTABLE} \
  ${EXTRA_BUILD_CONFIGURATION_FLAGS} \
  $ADDITIONAL_COMPONENTS || exit 1

${MAKE_EXECUTABLE} clean
${MAKE_EXECUTABLE} -j${HOST_NPROC}
${MAKE_EXECUTABLE} install

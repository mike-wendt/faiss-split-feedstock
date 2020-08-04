CUDA_CONFIG_ARG=""
if [ ${cuda_compiler_version} != "None" ]; then
    # for documentation see e.g.
    # docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#building-for-maximum-compatibility
    # docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html#major-components__table-cuda-toolkit-driver-versions
    # docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#gpu-feature-list

    # the following are all the x86-relevant gpu arches; for building aarch64-packages, add: 53, 62, 72
    ARCHES=(60 61 70 75 80)
    LATEST_ARCH=80
    for arch in "${ARCHES[@]}"; do
        CUDA_ARCH="${CUDA_ARCH} -gencode=arch=compute_${arch},code=sm_${arch}";
    done
    # to support PTX JIT compilation; see first link above or cf.
    # devblogs.nvidia.com/cuda-pro-tip-understand-fat-binaries-jit-caching
    CUDA_ARCH="${CUDA_ARCH} -gencode=arch=compute_${LATEST_ARCH},code=compute_${LATEST_ARCH}"

    CUDA_CONFIG_ARG="--with-cuda=${CUDA_HOME}"
else
    CUDA_CONFIG_ARG="--without-cuda"
fi

# Build vanilla version (no avx)
./configure --prefix=${PREFIX} --exec-prefix=${PREFIX} \
  --with-blas=-lblas --with-lapack=-llapack \
  ${CUDA_CONFIG_ARG} --with-cuda-arch="${CUDA_ARCH}" || exit 1

# make sets SHAREDEXT correctly for linux/osx
make -j 10 install

# make builds libfaiss.a & libfaiss.so; we only want the latter
rm ${PREFIX}/lib/libfaiss.a

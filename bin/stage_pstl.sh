#! /usr/bin/env bash


src="$1"
srcinc="$src/include/pstl/internal"
srctst="$src/test"

stagebase="$2/libstdc++v3"
stageinc="$stagebase/include/pstl"
stagetst="$stagebase/testsuite"

echo "Staging includes from $srcinc => $stageinc"
mkdir -p $stageinc
cp $srcinc/*.h $stageinc

# Staging tests
echo "Staging tests from $srctst => $stagetst"
mkdir -p "$stagetst/util/pstl"
cp $srctst/support/*.h $stagetst/util/pstl

srctest_algo="$srctst/std/algorithms"
stagetst_algo="$stagetst/25_algorithms/pstl"

# alg.nonmodifying
srctest_algo_nm="$srctest_algo/alg.nonmodifying"
stagetst_algo_nm="$stagetst_algo/alg_nonmodifying"
mkdir -p $stagetst_algo_nm
cp $srctest_algo_nm/*.cpp $stagetst_algo_nm

srctest_algo_mop="$srctest_algo/alg.modifying.operations"
stagetst_algo_mop="$stagetst_algo/alg_modifying_operations"
mkdir -p $stagetst_algo_mop
cp $srctest_algo_mop/*.cpp $stagetst_algo_mop
cp $srctest_algo_mop/alg.copy/*.cpp $stagetst_algo_mop
cp $srctest_algo_mop/alg.partitions/*.cpp $stagetst_algo_mop
cp $srctest_algo_mop/alg.reverse/*.cpp $stagetst_algo_nm

srctest_algo_mrg="$srctest_algo/alg.merge"
stagetst_algo_mrg="$stagetst_algo/alg_merge"
mkdir -p $stagetst_algo_mrg
cp $srctest_algo_mrg/*.cpp $stagetst_algo_mrg

srctest_algo_mrg="$srctest_algo/alg.merge"
stagetst_algo_mrg="$stagetst_algo/alg_merge"
mkdir -p $stagetst_algo_mrg
cp $srctest_algo_mrg/*.cpp $stagetst_algo_mrg

srctest_algo_srt="$srctest_algo/alg.sorting"
stagetst_algo_srt="$stagetst_algo/alg_sorting"
mkdir -p $stagetst_algo_srt
cp $srctest_algo_srt/*.cpp $stagetst_algo_srt
cp $srctest_algo_srt/alg.heap.operations/*.cpp $stagetst_algo_srt
cp $srctest_algo_srt/alg.lex.comparison/*.cpp $stagetst_algo_srt
cp $srctest_algo_srt/alg.min.max/*.cpp $stagetst_algo_srt
cp $srctest_algo_srt/alg.set.operations/*.cpp $stagetst_algo_srt

srctest_num="$srctst/std/numerics/numeric.ops"
stagetst_num="$stagetst/26_numerics/pstl/numeric_ops"
mkdir -p "$stagetst_num"
cp $srctest_num/*.cpp $stagetst_num

srctest_mem="$srctst/std/utilities/memory/specialized.algorithms"
stagetst_mem="$stagetst/20_util/specialized_algorithms/pstl"
mkdir -p "$stagetst_mem"
cp $srctest_mem/*.cpp $stagetst_mem

echo "Renaming all *.pass.cpp files in $stagetst to *.cc"
find $stagetst -iname "*.pass.cpp" -exec rename .pass.cpp .cc '{}' \;

fixup_test() {
    echo "fixing up test $1"
    sed -i '2i// { dg-options "-std=gnu++17 -ltbb" }\n// { dg-do run { target c++17 } }\n// { dg-require-effective-target tbb-backend }\n' $1
    sed -i 's/support\//pstl\//g' $1
}

for tfile in $(find "$stagetst" -iname "*.cc"); do
    fixup_test $tfile
done

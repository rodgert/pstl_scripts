#! /usr/bin/env bash

# Migrate original Intel test/test_*.cpp tests to libc++ directory structure

torigin="test"
tbasedir="testsuite"
MV="git mv"

# Migrate support files to testsuite/support
tsup="$tbasedir/support"
mkdir -p "$tsup"
$MV "$torigin/pstl_test_config.h" "$tsup"
$MV "$torigin/utils.h" "$tsup/parallel_utils.h"

# Tests go initially to testsuite/std
tdest="$tbasedir/std"

function fixup_copyright() {
    sed -i '2s/test_//;2s/\.cpp/.pass.cpp/' $1
}

function fixup_includes() {
    if ! grep -q "pstl_test_config" $1; then
	sed -i '10i#include "pstl_test_config.h"\n\n_foo_' $1;
    else
	sed -i 's/config\.h\"/config.h\"\n\n_foo_/' $1
    fi
    sed -i 's/pstl_test/support\/pstl_test/' $1

    sed -i '/_foo_/{n; d}' $1
    sed -i '/utils\.h/i#else\n_bar_\n_baz_\n#endif \/\/ PSTL_STANDALONE_TESTS\n' $1
    sed -i '/_foo_/c#ifdef PSTL_STANDALONE_TESTS' $1
    sed -i '/_bar_/c#include <execution>' $1
    
    if grep -q "pstl/algorithm" $1; then
	sed -i '/_baz_/c#include <algorithm>' $1
    elif grep -q "pstl/memory" $1; then
        sed -i '/_baz_/c#include <memory>' $1
    elif grep -q "pstl/numeric" $1; then
        sed -i '/_baz_/c#include <numeric>' $1
    fi

    sed -i 's/utils\.h/support\/utils.h/' $1
}

function mogrify_test_names() {
    local -n tfiles=$1
    local -n res=$2
    for tfile in "${tfiles[@]}"
    do
	dfile=${tfile/test_/}
	dfile=${dfile/\.cpp/\.pass\.cpp}
	res[$tfile]=$dfile
    done
}

function rename_tests() {
    dest="$tdest/$1"
    mkdir -p $dest

    local -A names
    local pnames=""
    mogrify_test_names $2 names
    local first=true
    for tfile in "${!names[@]}"
    do
	nfile="${names[$tfile]}"
        ffile="$dest/$nfile"
  	if ! $first ; then
	    pnames+=";"
	fi
        pnames+="$nfile"
	first=false
    	$MV $torigin/$tfile $ffile
     	fixup_copyright $ffile
     	fixup_includes $ffile
    done

    cmakef="$dest/CMakeLists.txt"

    cat > "$cmakef" <<EOF
set(PASS_SOURCES
	$pnames
)
EOF
    cat >> "$cmakef" <<'EOF'

foreach(test_source ${PASS_SOURCES})
  add_pass_test(${test_source})
endforeach(test_source ${PASS_SOURCES})

EOF
    sed -i 's/;/;\n\t/g' "$cmakef"
}

# Migrate numeric test files
numeric_ops=(
    test_transform_reduce.cpp
    test_scan.cpp
    test_transform_scan.cpp
    test_adjacent_difference.cpp
    test_reduce.cpp
)
rename_tests "numerics/numeric.ops" numeric_ops

# Migrate memory test files
specialized_algorithms=(
    test_uninitialized_construct.cpp
    test_uninitialized_copy_move.cpp
    test_uninitialized_fill_destroy.cpp
)
rename_tests "utilities/memory/specialized.algorithms" specialized_algorithms

# Migrate algorithms
alg_nonmodifying=(
    test_nth_element.cpp
    test_equal.cpp
    test_mismatch.cpp
    test_any_of.cpp
    test_find_first_of.cpp
    test_find.cpp
    test_all_of.cpp
    test_find_if.cpp
    test_find_end.cpp
    test_for_each.cpp
    test_search_n.cpp
    test_none_of.cpp
    test_adjacent_find.cpp
    test_count.cpp
)
rename_tests "algorithms/alg.nonmodifying" alg_nonmodifying

alg_merge=(
    test_merge.cpp
    test_inplace_merge.cpp
)
rename_tests "algorithms/alg.merge" alg_merge

alg_min_max=(
    test_minmax_element.cpp
)
rename_tests "algorithms/alg.sorting/alg.min.max" alg_min_max

alg_sorting=(
    test_sort.cpp
    test_partial_sort_copy.cpp
    test_is_sorted.cpp
    test_partial_sort.cpp
)
rename_tests "algorithms/alg.sorting" alg_sorting

alg_heap_operations=(
    test_is_heap.cpp
)
rename_tests "algorithms/alg.sorting/alg.heap.operations" alg_heap_operations

alg_lex_comparison=(
    test_lexicographical_compare.cpp
)
rename_tests "algorithms/alg.sorting/alg.lex.comparison" alg_lex_comparison

alg_set_operations=(
    test_includes.cpp
    test_set.cpp
)
rename_tests "algorithms/alg.sorting/alg.set.operations" alg_set_operations

alg_modifying_operations=(
    test_remove_copy.cpp
    test_copy_move.cpp
    test_rotate_copy.cpp
    test_remove.cpp
    test_replace_copy.cpp
    test_unique.cpp
    test_swap_ranges.cpp
    test_fill.cpp
    test_unique_copy_equal.cpp
    test_generate.cpp
    test_replace.cpp
    test_transform_unary.cpp
    test_transform_binary.cpp
    test_rotate.cpp
)
rename_tests "algorithms/alg.modifying.operations" alg_modifying_operations

alg_copy=(
    test_copy_if.cpp
)
rename_tests "algorithms/alg.modifying.operations/alg.copy" alg_copy

alg_reverse=(
    test_reverse_copy.cpp
    test_reverse.cpp
)
rename_tests "algorithms/alg.modifying.operations/alg.reverse" alg_reverse

alg_partitions=(
    test_partition_copy.cpp
    test_partition.cpp
    test_is_partitioned.cpp 
)
rename_tests "algorithms/alg.modifying.operations/alg.partitions" alg_partitions














test_db() {
    clang-ctags -e --compile-commands=compile_commands.json "$PWD/subdir/a.cpp"
    assert_tag a
}

test_db_with_multiple_source_files() {
    clang-ctags -e --compile-commands=compile_commands.json \
        "$PWD/subdir/a.cpp" "$PWD/subdir/b.cpp" "$PWD/subdir/b.h"
    assert_tag a
    assert_tag b
    assert_emacs '(find-tag "a")' a.cpp:1
    assert_emacs '(find-tag "b")' b.h:1

    clang-ctags --compile-commands=compile_commands.json \
        "$PWD/subdir/a.cpp" "$PWD/subdir/b.cpp" "$PWD/subdir/b.h"
    assert_vim 0 'a' a.cpp:1
    assert_vim 0 'b' b.h:1
}

test_db_find_entry_with_relative_path() {
    clang-ctags -e --compile-commands=compile_commands.json subdir/c.cpp
    assert_tag c
}

test_db_find_entry_with_relative_path_given_absolute_path() {
    clang-ctags -e --compile-commands=compile_commands.json "$PWD/subdir/c.cpp"
    assert_tag c
}

test_db_find_entry_with_absolute_path_given_relative_path() {
    clang-ctags -e --compile-commands=compile_commands.json subdir/a.cpp
    assert_tag a
}

test_db_find_entry_with_canonical_path_given_uncanonical_path() {
    ln -sf subdir subdir2
    clang-ctags -e --compile-commands=compile_commands.json subdir2/a.cpp
    assert_tag a
}

test_db_find_entry_relative_to_directory() {
    clang-ctags -e --compile-commands=compile_commands.json subdir/e.cpp
    assert_tag e
}

test_db_compile_command_from_different_directory() {
    clang-ctags -e --compile-commands=compile_commands.json subdir/d.cpp
    assert_tag d
    assert_emacs '(find-tag "d")' d.cpp:1

    clang-ctags --compile-commands=compile_commands.json subdir/d.cpp
    assert_vim 0 'd' d.cpp:1
}

test_db_compile_command_directory_is_relative_to_database() {
    clang-ctags -e --compile-commands=compile_commands.json subdir/f.cpp
    assert_tag f
    assert_emacs '(find-tag "f")' f.cpp:1

    clang-ctags --compile-commands=compile_commands.json subdir/f.cpp
    assert_vim 0 'f' f.cpp:1

    cd subdir
    clang-ctags -e --compile-commands=../compile_commands.json f.cpp
    assert_tag f
    assert_emacs '(find-tag "f")' f.cpp:1

    clang-ctags --compile-commands=../compile_commands.json f.cpp
    assert_vim 0 'f' f.cpp:1
}

test_no_duplicate_tags() {
    clang-ctags -e --compile-commands=compile_commands.json \
        --suppress-qualifier-tags subdir/b.cpp subdir/b2.cpp subdir/b.h
    assert_tag b
    count=$(grep "${DEL}b$SOH" TAGS | wc -l)
    [ "$count" -eq 1 ] || fail "Too many ($count) tags for 'b'"
}

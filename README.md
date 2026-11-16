# Diff

Line diffs and unified diff text in Ziran, with no allocation: callers own the
text, the workspace buffers and the output.

The algorithm is Myers' divide-and-conquer diff with the same post-passes as
Rust's [`similar`](https://crates.io/crates/similar) crate (compaction, then
delete and insert pairs merged into replacements). The unified output matches
`similar::TextDiff::from_lines(old, new).unified_diff()` byte for byte, which
the tests check against generated edits.

```ziran
#import "diff"

count := DiffLines(old, old_length, new, new_length, 0,
    old_starts, new_starts, old_hashes, new_hashes,
    forward, backward, raw_ops, ops, DiffOpCapacity(old_lines, new_lines))
length := DiffUnified(old, new, old_starts, new_starts, ops, count, 3,
    1, "a", 1, "b", 1, output, capacity)
```

- `DiffLineCount(text, length)` counts lines; `"\n"`, `"\r\n"` and a lone
  `"\r"` end a line, and a final line may lack one.
- `DiffOpCapacity(old_lines, new_lines)` is the op buffer size in ops; each op is
  five `s64` values: tag (`DiffEqual`, `DiffDelete`, `DiffInsert`,
  `DiffReplace`), old index, old length, new index, new length.
- Workspace sizes are listed at the top of `src/diff.zi`.
- `budget` bounds the search work, like `similar`'s deadline: once it is spent,
  the remaining differing ranges become a delete and an insert. `0` means no limit.
- `DiffUnified` returns the full output length; when that exceeds the capacity,
  only the first `capacity` bytes were written, so callers can size a buffer
  with a first call and a capacity of 0.

`make check ZIRAN=path/to/ziran` builds and runs the tests as C. The package targets native
builds (C, Go): it indexes caller-owned pointers and keeps slices in records, which the
portable bundle subset does not allow yet.

## License

BSD 3-Clause; see `LICENSE`.

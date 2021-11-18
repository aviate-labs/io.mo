# Basic Interfaces for I/O Primitives

## Usage

```motoko
let data = Iter.fromArray<Nat8>(Blob.toArray(Text.encodeUtf8(
    "Text or something else that can be converted to bytes.",
)));

let reader = IO.fromIter(data);
switch (IO.readAll(reader)) {
    case (#ok(bs)) // [...].size() == 54.
    ...
};

```

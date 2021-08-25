import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";

import IO "../src/IO";

import D "mo:base/Debug";

func range(n : Nat, m : Nat) : Iter.Iter<Nat8> {
    Iter.map(Iter.range(n, m), Nat8.fromNat);
};

do {
    let r = IO.fromIter(range(0, 100));

    assert(r.read(1) == ([0], 1, ""));
    assert(r.read(5) == ([1, 2, 3, 4, 5], 5, ""));
    assert(IO.readAtLeast(r, 10, 15) == (Iter.toArray(range(6, 20)), 15, ""));
    assert(IO.readFull(r, 40).1 == 40);
    assert(IO.readAll(r).1 == 40);
};

do {
    let data = range(0, 9);
    let r = IO.fromIter(data);
    assert(IO.readFull(r, 100) == (Iter.toArray(range(0, 9)), 10, IO.unexpectedEOF));
};

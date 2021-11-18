import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";

import IO "../src/IO";

func range(n : Nat, m : Nat) : Iter.Iter<Nat8> {
    Iter.map(Iter.range(n, m), Nat8.fromNat);
};

do {
    let r = IO.fromIter(range(0, 100));

    assert(r.read(1) == #ok([0]));
    assert(r.read(5) == #ok([1, 2, 3, 4, 5]));
    assert(IO.readAtLeast(r, 10, 15) == #ok(Iter.toArray(range(6, 20))));
    switch (IO.readFull(r, 40)) {
        case (#ok(b)) assert(b.size() == 40);
        case (_)      assert(false);
    };
    switch (IO.readAll(r)) {
        case (#ok(b)) assert(b.size() == 40);
        case (_)      assert(false);
    }
};

do {
    let data = range(0, 9);
    let r = IO.fromIter(data);
    switch (IO.readFull(r, 100)) {
        case (#err(b, e)) {
            assert(b == Iter.toArray(range(0, 9)));
            assert(e == IO.unexpectedEOF);
        };
        case (_) assert(false);
    };
};

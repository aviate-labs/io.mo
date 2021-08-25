import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

module {
    public type Error = Text;
    public func errorNotNull(e : Error) : Bool {
        e != "";
    };

    // EOF is the error returned by Read when no more input is available.
    public let EOF : Error = "EOF";
    public let unexpectedEOF : Error = "unexpectedEOF";
    private let noErr : Error = "";

    public type Reader<T> = {
        // Reads up to n bytes into p. It returns the number of bytes read (0 <= _ <= n) and any error encountered.
        // When an EOF error is encountered after successfully reading n > 0 bytes, it still returns the bytes and the number read.
        read(n : Nat) : ([T], Nat, Error);
    };

    // Reads from r until it has read at least min bytes. Returns the number of bytes read and an error if fewer bytes were read.
    public func readAtLeast<T>(r : Reader<T>, min : Nat, max : Nat) : ([T], Nat, Error) {
        if (max < min) { return ([], 0, "too short: max < min"); };
        var bs : [T] = []; var n = 0; var err = noErr;
        label l while (n < min and err == noErr) {
            let (b, nn, e) = r.read(max - bs.size());
            bs := Array.append<T>(bs, b);
            n += nn; err := e;
            if (bs.size() == max) { break l; };
        };
        if (min <= n) {
            // Even if there was an error, at least n bytes were read.
            return (bs, n, noErr);
        } else if (0 < n and err == EOF) {
            // No enough bytes.
            err := unexpectedEOF;
        };
        (bs, n, err);
    };

    // Reads exactly n bytes from r.
    public func readFull<T>(r : Reader<T>, n : Nat) : ([T], Nat, Error) {
        readAtLeast(r, n, n);
    };

    // Reads from r until an EOF error and returns the data it read.
    public func readAll<T>(r : Reader<T>) : ([T], Nat, Error) {
        var bs : [T] = []; var n = 512;
        loop {
            let (b, nn, e) = r.read(n);
            bs := Array.append(bs, b);
            n += nn;
            if (errorNotNull(e)) {
                if (e == EOF) {
                    return (bs, bs.size(), noErr);
                };
                return (bs, bs.size(), e);
            };
        };
    };

    public type Writer = {
        // Writes len(b) bytes from b to the underlying data stream.
        // It returns the number of bytes written from b (0 <= _ <= len(b)) and any error encountered.
        write(b : [Nat8]) : (Nat, Error);
    };

    // Writes the contents of the string s to w.
    public func writeText(w : Writer, t : Text) : (Nat, Error) {
        w.write(Blob.toArray(Text.encodeUtf8(t)));
    };

    // Contructs a reader from i.
    public func fromIter<T>(i : Iter.Iter<T>) : Reader<T> = object {
        let arr = Iter.toArray(i);
        var size = arr.size();
        let iter = Iter.fromArray(arr);
        public func read(n : Nat) : ([T], Nat, Error) {
            let s = min(n, size);
            var b : [T] = [];
            for (j in Iter.range(0, s-1)) {
                switch (iter.next()) {
                    case (null) {
                        // This should never happen (unreachable?).
                        return (take(b, j), j, "could not get value");
                    };
                    case (? v) {
                        b := Array.append(b, [v]);
                        size -= 1;
                    };
                };
            };
            if (s < n) { return (b, s, EOF); };
            (b, n, noErr);
        };
    };

    private func min(a : Nat, b : Nat) : Nat {
        if (a < b) { return a; }; b;
    };

    private func take<T>(xs : [T], n : Nat) : [T] {
        if (n == 0)         { return []; };
        if (xs.size() <= n) { return xs;  };
        let b = Array.init<T>(n, xs[0]);
        for (i in b.keys()) { b[i] := xs[i]; };
        Array.freeze(b);
    };
};

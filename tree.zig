const std = @import("std");

// A Stern-Brocot tree node is represented as a struct with four integers.
pub const Node = struct {
    a: i64,
    b: i64,
    c: i64,
    d: i64,

    pub fn left(self: Node) Node {
        return .{ .a = self.a + self.b, .b = self.b, .c = self.c + self.d, .d = self.d };
    }

    pub fn right(self: Node) Node {
        return .{ .a = self.a, .b = self.a + self.b, .c = self.c, .d = self.c + self.d };
    }

    pub fn toFraction(self: Node) f64 {
        return @as(f64, @floatFromInt(self.a + self.b)) / @as(f64, @floatFromInt(self.c + self.d));
    }

    pub fn toN(self: Node) i64 {
        return (self.a + self.b) * (self.c + self.d);
    }

    pub fn det(self: Node) i64 {
        return self.a * self.d - self.b * self.c;
    }
};

const I = Node{ .a = 1, .b = 0, .c = 0, .d = 1 }; // Root node of the tree

pub fn parseSB(str: []const u8) !Node {
    var node: Node = I;

    for (str) |char| {
        node = switch (char) {
            'L' => node.left(),
            'R' => node.right(),
            else => return error.InvalidChar,
        };
    }

    return node;
}

test "parse Stern–Brocot sequences" {
    const parsed = try parseSB("RRRLRLLL");
    const result = Node{ .a = 25, .b = 7, .c = 7, .d = 2 };
    try std.testing.expect(std.meta.eql(parsed, result));
}

pub const Sign = enum { N, Z, P };
pub const Branch = enum { R, L };

pub const PhiIter = struct {
    pos: usize,
    current_chunk: [2]Branch,

    fn get_chunk() [2]Branch {
        return [2]Branch{ Branch.R, Branch.L };
    }

    pub fn init() PhiIter {
        return PhiIter{ .pos = 0, .current_chunk = get_chunk() };
    }

    pub fn next(self: *PhiIter) ?Branch {
        if (self.pos == self.current_chunk.len) {
            self.pos = 1;
            self.current_chunk = get_chunk();
            const retval = self.current_chunk[0];
            return retval;
        } else {
            const retval = self.current_chunk[self.pos];
            self.pos += 1;
            return retval;
        }
    }
};

test "generate the first 5 bits of Phi" {
    var s_iter = PhiIter.init();

    var i: u32 = 0;
    while (i < 5) {
        i += 1;
        if (i % 2 == 0) {
            try std.testing.expect(std.meta.eql(s_iter.next(), Branch.L));
        } else {
            try std.testing.expect(std.meta.eql(s_iter.next(), Branch.R));
        }
    }
}

pub fn qToSB(n_in: i64, d_in: i64, u: *std.ArrayList(Branch)) !void {
    var n = n_in;
    var d = d_in;

    while (n != d) {
        if (n < d) {
            try u.append(Branch.L);
            d -= n;
        } else {
            try u.append(Branch.R);
            n -= d;
        }
    }
}

test "convert positive rationals to Stern–Brocot sequences" {
    const gpa = std.heap.page_allocator;
    var u = std.ArrayList(Branch).init(gpa);
    defer u.deinit();

    try qToSB(4, 3, &u);
    const result = [_]Branch{ Branch.R, Branch.L, Branch.L };

    try std.testing.expect(std.mem.eql(Branch, u.items, &result));
}

pub fn main() !void {
    var s_iter = PhiIter.init();

    var i: u32 = 0;
    while (i < 42) {
        i += 1;
        std.debug.print("{any}\n", .{s_iter.next()});
    }
}

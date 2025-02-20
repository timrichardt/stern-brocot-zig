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
        if (char == 'L') {
            node = node.left();
        } else if (char == 'R') {
            node = node.right();
        } else {
            return error.InvalidChar;
        }
    }

    return node;
}

test "parse Stern–Brocot sequences" {
    const parsed = try parseSB("RRRLRLLL");
    const result = Node{ .a = 25, .b = 7, .c = 7, .d = 2 };
    try std.testing.expect(std.meta.eql(parsed, result));
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const parsed = try parseSB("RRRLRLLL");

    try stdout.print("{} {}\n{} {}\n{}\n", .{ parsed.a, parsed.b, parsed.c, parsed.d, parsed.toFraction() });
}

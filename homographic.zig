const std = @import("std");
const tree = @import("tree.zig");

pub fn sgn(a: i64) i32 {
    if (a == 0) {
        return 0;
    } else if (a > 0) {
        return 1;
    } else {
        return -1;
    }
}

pub fn linSgn(a: i64, b: i64) ?i32 {
    if (a == 0 and b == 0) {
        return 0;
    } else {
        const sumOfSigns = sgn(a) + sgn(b);

        if (sumOfSigns > 0) {
            return 1;
        } else if (sumOfSigns < 0) {
            return -1;
        } else {
            return null;
        }
    }
}

pub fn homSgn(H: tree.Node, u: []const u8) !i32 {
    if (u.len == 0) {
        return sgn(H.a + H.b) * sgn(H.c + H.d);
    }

    const nomSgn = linSgn(H.a, H.b);
    const denomSgn = linSgn(H.c, H.d);

    if (nomSgn) |n| if (denomSgn) |d| {
        return n * d;
    };

    const head = u[0];
    const rest = u[1..];

    return switch (head) {
        'R' => homSgn(H.right(), rest),
        'L' => homSgn(H.left(), rest),
        else => error.InvalidChar,
    };
}

test "Homographic sign algorithm" {
    const node = tree.Node{ .a = 5, .b = -7, .c = 1, .d = 2 };
    const u = "RLLRLR";

    try std.testing.expect(try homSgn(node, u) == -1);
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const node = tree.Node{ .a = 5, .b = -7, .c = 1, .d = 2 };
    const u = "RLLRLR";

    try stdout.print("{}\n", .{try homSgn(node, u)});
}

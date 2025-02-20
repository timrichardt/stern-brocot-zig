const std = @import("std");
const tree = @import("tree.zig");

const SignSum = union(enum) {
    value: i32,
    undefined: bool,
};

pub fn sgn(a: i64) i32 {
    if (a == 0) {
        return 0;
    } else if (a > 0) {
        return 1;
    } else {
        return -1;
    }
}

pub fn linSgn(a: i64, b: i64) SignSum {
    if (a == 0 and b == 0) {
        return SignSum{ .value = 0 };
    } else {
        const sumOfSigns = sgn(a) + sgn(b);

        if (sumOfSigns > 0) {
            return SignSum{ .value = 1 };
        } else if (sumOfSigns < 0) {
            return SignSum{ .value = -1 };
        } else {
            return SignSum{ .undefined = true };
        }
    }
}

pub fn homSgn(H: tree.Node, u: []const u8) !i32 {
    if (u.len == 0) {
        return sgn(H.a + H.b) * sgn(H.c + H.d);
    } else {
        const nomSgn = linSgn(H.a, H.b);
        const denomSgn = linSgn(H.c, H.d);

        if (nomSgn != .undefined and denomSgn != .undefined) {
            return nomSgn.value * denomSgn.value;
        } else {
            const head = u[0];
            const rest = u[1..];

            if (head == 'R') {
                return homSgn(H.right(), rest);
            } else if (head == 'L') {
                return homSgn(H.left(), rest);
            } else {
                return error.InvalidChar;
            }
        }
    }
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

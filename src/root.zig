const std = @import("std");
const net = std.net;
const posix = std.posix;

pub const UDP = struct {
    sock: posix.socket_t,
    server_addr: net.Address,

    pub fn init(ip: []const u8, port: u16) !UDP {
        const sock = try posix.socket(posix.AF.INET, posix.SOCK.DGRAM, 0);
        const server_addr = try net.Address.parseIp(ip, port);
        return .{
            .sock = sock,
            .server_addr = server_addr,
        };
    }

    pub fn checkConnection(self: UDP) !bool {
        // kirim ping
        try self.send("PING");

        // set timeout 1 detik
        var tv = posix.timeval{
            .sec = 1,
            .usec = 0,
        };
        try posix.setsockopt(
            self.sock,
            posix.SOL.SOCKET,
            posix.SO.RCVTIMEO,
            std.mem.asBytes(&tv),
        );

        var buf: [16]u8 = undefined;
        const n = posix.recvfrom(self.sock, &buf, 0, null, null) catch return false;

        if (n >= 3 and std.mem.eql(u8, buf[0..3], "ACK")) {
            return true;
        } else {
            return false;
        }
    }

    pub fn deinit(self: UDP) void {
        posix.close(self.sock);
    }

    pub fn send(self: UDP, message: []const u8) !void {
        _ = try posix.sendto(
            self.sock,
            message,
            0,
            &self.server_addr.any,
            @intCast(self.server_addr.getOsSockLen()),
        );
    }

    pub fn read(self: UDP, buffer: []u8) !usize {
        var addr: net.Address = undefined;
        var addr_len: posix.socklen_t = @sizeOf(@TypeOf(addr.any));
        const n = try posix.recvfrom(
            self.sock,
            buffer,
            0,
            &addr.any,
            &addr_len,
        );
        return n;
    }
};

pub fn delay(ms: u64) void {
    const end_time = std.time.milliTimestamp() + @as(i64, @intCast(ms));
    while (std.time.milliTimestamp() < end_time) {
        std.Thread.yield() catch unreachable;
    }
}

zig fetch --save https://github.com/attarrumi/udp/archive/refs/heads/main.zip

  const udp = b.dependency("udp", .{
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("udp", udp.module("udp"));



const UDP = @import("udp").UDP;

   var udp = try UDP.init("192.168.1.2", 8080);
    defer udp.deinit();

    if (try udp.checkConnection()) {
        std.debug.print("not connected\n", .{});
    }

    try udp.send("GET_RAW_DATA");
        var buffer: [256]u8 = undefined;
        const n = try udp.read(&buffer);
        const data = read_data(buffer[0..n]);

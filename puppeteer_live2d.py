import os
import asyncio
import logging

log = logging.getLogger(__name__)


class EchoServerProtocol:
    def __init__(self, process):
        self.process = process

    def connection_made(self, transport):
        self.transport = transport

    def datagram_received(self, data, addr):
        message = data.decode()
        if message.startswith("!angles"):
            _, angle_x, angle_y = message.split()
            print("recv angles", angle_x, angle_y)
            self.process.stdin.write(f"set ParamAngleX {angle_x}\n".encode())
            self.process.stdin.write(f"set ParamAngleY {angle_y}\n".encode())
        else:
            self.process.stdin.write(f"{message}\n".encode())

    def connection_lost(self, exc):
        log.error("shitpants %r", exc)


async def main():
    loop = asyncio.get_running_loop()

    cmdline = (
        f"cd {os.environ['LIVE2D_PATH']} && ./Demo -c {os.environ['LIVE2D_CONFIG']}"
    )

    print("running command ", cmdline)

    vtuber_process = await asyncio.create_subprocess_shell(
        cmdline,
        stderr=asyncio.subprocess.PIPE,
        stdout=asyncio.subprocess.PIPE,
        stdin=asyncio.subprocess.PIPE,
    )

    assert vtuber_process.stdin.can_write_eof()
    if vtuber_process.returncode is not None:
        stdout, stderr = await vtuber_process.communicate()
        out, err = map(lambda s: s.decode(), await vtuber_process.communicate())
        print(f"process exited with exit code {vtuber_process.returncode}: {out}{err}")
        return

    print("Starting UDP server")
    transport, protocol = await loop.create_datagram_endpoint(
        lambda: EchoServerProtocol(vtuber_process),
        local_addr=(
            os.environ["CARNATION_BIND_IP"],
            os.environ.get("CARNATION_BIND_PORT", 6699),
        ),
    )

    try:
        await asyncio.sleep(3600)
    finally:
        transport.close()
        vtuber_process.kill()


asyncio.run(main())

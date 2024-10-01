# RISCV Bare Metal Program Learning   
## Development environment prepare   
This porject can be used on the linux operating system, I used the Ubuntu22.04 operating system   
### spike   
[GitHub: riscv-isa-sim](https://github.com/riscv-software-src/riscv-isa-sim)   

You can get the source code on github for the link above.   

Spike, the RISC-V ISA Simulator, implements a functional model of one or more RISC-V harts. It is named after the golden spike used to celebrate the completion of the US transcontinental railway.   

spike is supported for both riscv32 and riscv64. We can use option `--isa=rv32imafdc` and option `--isa=rv64imafdc`(default) to specify whether the current spike supports riscv32 or riscv64.   

how to build and install spike:   
You can customize your spike's installation directory by using the `$RISCV` variable.   

```
git clone https://github.com/riscv-software-src/riscv-isa-sim.git
cd riscv-isa-sim
mkdir build
cd build
../configure --prefix=$RISCV
make
[sudo] make install
```

After you complete the installation, you need to add your spike's installation path to your `.bashrc` file.   

### pk   
[GitHub: rscv-pk](https://github.com/riscv-software-src/riscv-pk)   

You can get the source code on github for the link above.   

The RISC-V Proxy Kernel, pk, is a lightweight application execution environment that can host statically-linked RISC-V ELF binaries. It is designed to support tethered RISC-V implementations with limited I/O capability and thus handles I/O-related system calls by proxying them to a host computer.   

This package also contains the Berkeley Boot Loader, bbl, which is a supervisor execution environment for tethered RISC-V systems. It is designed to host the RISC-V Linux port.   

How to build it:   
You can customize your pk's installation directory by using the `$RISCV` variable.   

```
git clone https://github.com/riscv-software-src/riscv-pk.git
cd riscv-pk
mkdir build
cd build
# build riscv64 riscv-pk:
../configure --prefix=$RISCV --host=riscv64-unknown-elf
# if build riscv32 riscv-pk we can use: ../configure --prefix=$RISCV --host=riscv32-unknown-elf
make
[sudo] make install
```

The `pk` is an executable file of the riscv instruction architecture that you can execute using the `spike` emulator.   
Example, my riscv32 and riscv64 pk is installed on `~/.bin/pk/riscv32-unknown-elf/bin/pk` and `~/.bin/pk/riscv64-unknown-elf/bin/pk`.    

If we were to execute the pk file directly using spike, the result would be as follows.   

```
$ spike ~/.bin/pk/riscv64-unknown-elf/bin/pk 
tell me what ELF to load!

$ spike --isa=rv32imafdc  ~/.bin/pk/riscv32-unknown
-elf/bin/pk 
tell me what ELF to load!
```

If we have a c code like:   

```
// hello.c
#include <stdio.h>
int main()
{
    printf("Hello RISCV\n");
    return 0;
}
```

compile use command like:   

```
riscv32-unknown-elf-gcc hello.c -o hello_32

riscv64-unknown-elf-gcc hello.c -o hello_64
```

We can get output log like:   

```
$ spike --isa=rv32imafdc  ~/.bin/pk/riscv32-unknown
-elf/bin/pk hello_32
Hello RISCV


$ spike ~/.bin/pk/riscv64-unknown-elf/bin/pk  hello_64 
Hello RISCV
```

### openocd   
[GitHub: riscv-openocd](https://github.com/riscv-collab/riscv-openocd)   

You can get the source code on github for the link above.   

OpenOCD provides on-chip programming and debugging support with a layered architecture of JTAG interface and TAP support including:   

- (X)SVF playback to facilitate automated boundary scan and FPGA/CPLD programming;   
- debug target support (e.g. ARM, MIPS): single-stepping, breakpoints/watchpoints, gprof profiling, etc;   
- flash chip drivers (e.g. CFI, NAND, internal flash);   
- embedded TCL interpreter for easy scripting.   

Several network interfaces are available for interacting with OpenOCD: telnet, TCL, and GDB. The GDB server enables OpenOCD to function as a "remote target" for source-level debugging of embedded systems using the GNU GDB program (and the others who talk GDB protocol, e.g. IDA Pro).   

The [riscv-openocd](https://github.com/riscv-collab/riscv-openocd) is a fork of [OpenOCD](https://openocd.org/) that has RISC-V support.   

How to build the OpenOCD:   
We need enable the bitbang adapter for OpenOCD use the option `--enable-remote-bitbang`.   

```
git clone https://github.com/riscv-collab/riscv-openocd.git
cd riscv-openocd
make build
cd build
../configure --prefix=~/.bin/openocd  --enable-remote-bitbang
make
[sudo] make install
```

After you complete the installation, you need to add your openocd's installation path to your `.bashrc` file.   

How to use OpenOCD's bitbang adapter combined with riscv's gdb to debug code executed by the spike emulator.   
Create the OpenOCD configuration file as follows.   

```
# openocd.cfg
adapter driver remote_bitbang
remote_bitbang host localhost
remote_bitbang port 9824

set _WORKAREASIZE 0x100000 

set _CHIPNAME riscv
jtag newtap $_CHIPNAME cpu -irlen 5 -expected-id 0xDEADBEEF

set _TARGETNAME $_CHIPNAME.cpu
target create $_TARGETNAME riscv -chain-position $_TARGETNAME

$_TARGETNAME configure -work-area-phys 0x81000000 -work-area-size $_WORKAREASIZE -work-area-backup 0

gdb report_data_abort enable
```

We use the remote bitband port:9824 to communicate with spike.   

The spike use option `--rbb-port=9824` to listen for remote bitbang connection on port 9824.   

If the code exits directly, remote bitbang will automatically shut down when the code exits, so we can use the `-H` option to halt the CPU before executing the code. Or we can put a loop in the code to ensure that the code does not exit after execution, so that the remote bitbang service can always work.   

Detailed commands are as follows.   

```
$ spike --rbb-port=9824 ~/.bin/pk/riscv64-unknown-e
lf/bin/pk hello_64
Listening for remote bitbang connection on port 9824.
Hello RISCV

$ spike --rbb-port=9824 -H ~/.bin/pk/riscv64-unknow
n-elf/bin/pk hello_64
Listening for remote bitbang connection on port 9824.
```

```
$ openocd -f openocd.cfg 
Open On-Chip Debugger 0.12.0+dev-04007-g3bed4c801 (2024-09-20-20:16)
Licensed under GNU GPL v2
For bug reports, read
        http://openocd.org/doc/doxygen/bugs.html
Info : auto-selecting first available session transport "jtag". To override use 'transport select <transport>'.
Info : Listening on port 6666 for tcl connections
Info : Listening on port 4444 for telnet connections
Info : Initializing remote_bitbang driver
Info : Connecting to localhost:9824
Info : remote_bitbang driver initialized
Info : Note: The adapter "remote_bitbang" doesn't support configurable speed
Info : JTAG tap: riscv.cpu tap/device found: 0xdeadbeef (mfg: 0x777 (Fabric of Truth Inc), part: 0xeadb, ver: 0xd)
Info : [riscv.cpu] datacount=2 progbufsize=2
Info : [riscv.cpu] Examined RISC-V core
Info : [riscv.cpu]  XLEN=64, misa=0x800000000014112d
[riscv.cpu] Target successfully examined.
Info : [riscv.cpu] Examination succeed
Info : [riscv.cpu] starting gdb server on 3333
Info : Listening on port 3333 for gdb connections
```

```
$ riscv64-unknown-elf-gdb
(gdb) target remote localhost:3333
Remote debugging using localhost:3333
warning: No executable has been specified and target does not support
determining executable automatically.  Try using the "file" command.
0x0000000000001000 in ?? ()
(gdb) continue 
Continuing.

Program received signal SIGINT, Interrupt.
0x00000000800043ae in ?? ()
......
Program received signal SIGINT, Interrupt.
0xffffffc000001e70 in ?? ()
(gdb) 
Continuing.
remote_bitbang: socket closed by remote
```

Since `pk` has an interrupt enabled, gdb `continue` needs to be executed several times in gdb for the code to complete the pk + hello_64 process. When the execution is complete, `spike` exits the remote bitbang listen process, so we can from the gdb terminal see messages: "remote_bitbang: socket closed by remote."   

If we want `spike` don't close the remote bitbang, wen can loop at the end of the `hello_64` code. like as follows.   

```
hello.c
#include <stdio.h>
int main()
{
    printf("Hello RISCV\n");
    while(1);
    return 0;
}
```

### toolchain   
[GitHub: riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)   

You can get the riscv gnu toolchain on github for the link above. You can also get the riscv gnu toolchain in other ways. Note that the toolchains used in the previous steps are the same as the toolchains you have installed in your system.   


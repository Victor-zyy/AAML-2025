#! /bin/bash

# build VexRiscv+CFU+Perf Gateware
prog() {
    echo "Build VexRiscv + CFU + Perf GateWare"
    #for debug
    #echo "make prog USE_VIVADO=1 TARGET=microphase_a7_lite UART_SPEED=115200"
    #make prog USE_VIVADO=1 TARGET=microphase_a7_lite UART_SPEED=115200
    make prog USE_VIVADO=1 TARGET=microphase_a7_lite UART_SPEED=460800
}

# build tensorflow-lite software framework
load() {
    echo "Build TensorFlow-Lite Software Framework"
    #for debug
    #echo "make load BUILD_JOBS=8 TARGET=microphase_a7_lite UART_SPEED=115200 TTY=$1"
    #make load BUILD_JOBS=4 TARGET=microphase_a7_lite UART_SPEED=115200 TTY=$1
    make load BUILD_JOBS=4 TARGET=microphase_a7_lite UART_SPEED=460800 TTY=$1
}

# solid SPI-Nor-Flash Firmware into the FPGA
flash() {
    echo "Solid Spi-Nor-Flash Onto the FPGA Board"
    #for debug
    #echo "make flash USE_VIVAD=1 TARGET=microphase_a7_lite UART_SPEED=115200"
    #make flash USE_VIVAD=1 TARGET=microphase_a7_lite UART_SPEED=115200
    make flash USE_VIVAD=1 TARGET=microphase_a7_lite UART_SPEED=460800
}

clean() {
    echo "Clean-Soc Project"
    make TARGET=microphase_a7_lite clean
}

debug() {
    echo "Platform Simulation Using Verilator Debugging..."
    make PLATFORM=sim load
}

renode() {
    echo "Platform Simulation Using Verilator Debugging..."
    make renode 
}
end() {
    echo "kill the litex-term process"
}
#   Main Script Starts Here

if [ "$1" = "prog" ]; then
    prog 
elif [ "$1" = "load" ]; then
    load $2
elif [ "$1" = "flash" ]; then
    flash
elif [ "$1" = "clean" ]; then
    clean
elif [ "$1" = "debug" ]; then
    debug
elif [ "$1" = "renode" ]; then
    renode
elif [ "$1" = "end" ]; then
    end
else
    echo "Shell Script Usage: "
    echo "($0) prog for generate gateware "
    echo "($0) load /dev/ttyUSB for generate software"
    echo "($0) flash for solid gateware"
fi



#!/bin/sh

set -e

ROOT="$(pwd)/.."
GHDL_ARGS=--std=08

rm -rf "$ROOT"/build
mkdir -p "$ROOT"/build
cd "$ROOT"/build

ghdl -a "$GHDL_ARGS" "$ROOT"/hdl/uart_rx.vhd
ghdl -a "$GHDL_ARGS" "$ROOT"/hdl/uart_tx.vhd
ghdl -a "$GHDL_ARGS" "$ROOT"/hdl/uart_top.vhd
ghdl -e "$GHDL_ARGS" uart_rx
ghdl -e "$GHDL_ARGS" uart_tx

# test TX -> RX
ghdl -a "$GHDL_ARGS" "$ROOT"/test/tb_uart.vhd
ghdl -e "$GHDL_ARGS" tb_uart
ghdl -r tb_uart --stop-time=25ms
# ghdl -r tb_uart --wave=tb_uart.ghw --stop-time=25ms
# gtkwave tb_uart.ghw ../tb_uart.gtkw

# test TOP (RX -> TX) -> RX
ghdl -a "$GHDL_ARGS" "$ROOT"/test/tb_uart2.vhd
ghdl -e "$GHDL_ARGS" tb_uart2
ghdl -r tb_uart2 --stop-time=40ms
# ghdl -r tb_uart2 --wave=tb_uart2.ghw --stop-time=40ms
# gtkwave tb_uart2.ghw ../tb_uart2.gtkw
set_property -dict { PACKAGE_PIN M20  IOSTANDARD LVCMOS33 } [get_ports { a }]; #IO_L7N_T1_AD2N_35 Sch=SW0
set_property -dict { PACKAGE_PIN M19  IOSTANDARD LVCMOS33 } [get_ports { b }]; #IO_L7P_T1_AD2P_35 Sch=SW1

set_property -dict { PACKAGE_PIN R14    IOSTANDARD LVCMOS33 } [get_ports { p }]; #IO_L6N_T0_VREF_34 Sch=LED0

set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports clk]

create_clock -period 8.000 -name clk -waveform {0.000 4.000} [get_ports clk]

########################
# Physical Constraints #
########################

# I2C Chain on FMC-IMAGEON
set_property PACKAGE_PIN U25 [get_ports fmc_imageon_iic_scl_io]
set_property IOSTANDARD LVCMOS25 [get_ports fmc_imageon_iic_scl_io]
set_property SLEW SLOW [get_ports fmc_imageon_iic_scl_io]
set_property DRIVE 8 [get_ports fmc_imageon_iic_scl_io]

set_property PACKAGE_PIN V26 [get_ports fmc_imageon_iic_sda_io]
set_property IOSTANDARD LVCMOS25 [get_ports fmc_imageon_iic_sda_io]
set_property SLEW SLOW [get_ports fmc_imageon_iic_sda_io]
set_property DRIVE 8 [get_ports fmc_imageon_iic_sda_io]

set_property PACKAGE_PIN AJ19 [get_ports {fmc_imageon_iic_rst_n[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc_imageon_iic_rst_n[0]}]
set_property SLEW SLOW [get_ports {fmc_imageon_iic_rst_n[0]}]
set_property DRIVE 8 [get_ports {fmc_imageon_iic_rst_n[0]}]

# VITA interface
set_property PACKAGE_PIN AG24 [get_ports vita_cam_clk_pll]
set_property PACKAGE_PIN AG25 [get_ports {vita_cam_trigger[2]}]
set_property PACKAGE_PIN AF23 [get_ports {vita_cam_trigger[1]}]
set_property PACKAGE_PIN AF24 [get_ports {vita_cam_trigger[0]}]
set_property PACKAGE_PIN V28 [get_ports {vita_cam_monitor[0]}]
set_property PACKAGE_PIN V29 [get_ports {vita_cam_monitor[1]}]
set_property PACKAGE_PIN AJ25 [get_ports vita_spi_spi_sclk]
set_property PACKAGE_PIN AK25 [get_ports vita_spi_spi_ssel_n]
set_property PACKAGE_PIN AD21 [get_ports vita_spi_spi_mosi]
set_property PACKAGE_PIN AE21 [get_ports vita_spi_spi_miso]
set_property PACKAGE_PIN AH21 [get_ports vita_cam_clk_out_n]
set_property PACKAGE_PIN AE23 [get_ports vita_cam_sync_n]
set_property PACKAGE_PIN AD24 [get_ports {vita_cam_data_n[0]}]
set_property PACKAGE_PIN AK21 [get_ports {vita_cam_data_n[1]}]
set_property PACKAGE_PIN AH24 [get_ports {vita_cam_data_n[2]}]
set_property PACKAGE_PIN AK20 [get_ports {vita_cam_data_n[3]}]
#set_property PACKAGE_PIN AG20 [get_ports {vita_cam_data_n[4]}];
#set_property PACKAGE_PIN AJ24 [get_ports {vita_cam_data_n[5]}];
#set_property PACKAGE_PIN AK23 [get_ports {vita_cam_data_n[6]}];
#set_property PACKAGE_PIN AK18 [get_ports {vita_cam_data_n[7]}];

set_property IOSTANDARD LVCMOS25 [get_ports vita_cam_clk_pll]
set_property IOSTANDARD LVCMOS25 [get_ports vita_cam_reset_n]
set_property IOSTANDARD LVCMOS25 [get_ports vita_cam_trigger*]
set_property IOSTANDARD LVCMOS25 [get_ports vita_cam_monitor*]
set_property IOSTANDARD LVCMOS25 [get_ports vita_spi_spi_*]

set_property IOSTANDARD LVDS_25 [get_ports vita_cam_clk_out_*]
set_property IOSTANDARD LVDS_25 [get_ports vita_cam_sync_*]
set_property IOSTANDARD LVDS_25 [get_ports vita_cam_data_*]

set_property PACKAGE_PIN AF22 [get_ports vita_cam_reset_n]

# Video Clock Synthesizer
set_property PACKAGE_PIN AE22 [get_ports vita_clk]
set_property IOSTANDARD LVCMOS25 [get_ports vita_clk]


##################
# Primary Clocks #
##################

create_clock -period 6.730 -name vita_clk [get_ports vita_clk]
create_clock -period 2.692 -name vita_ser_clk [get_ports vita_cam_clk_out_p]

set_clock_groups -asynchronous -group [get_clocks clk_fpga_0] -group [get_clocks {clk_fpga_1 clk_fpga_2}] -group [get_clocks -include_generated_clocks {vita_clk vita_ser_clk}]




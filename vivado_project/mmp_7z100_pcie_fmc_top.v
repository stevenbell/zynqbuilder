//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (lin64) Build 1412921 Wed Nov 18 09:44:32 MST 2015
//Date        : Sun Nov 27 15:09:13 2016
//Host        : kiwi running 64-bit Ubuntu 14.04.5 LTS
//Command     : generate_target mmp_proj_bd_wrapper.bd
//Design      : mmp_proj_bd_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module mmp_proj_bd_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    EXT_LEDS,
    EXT_PCIE_REFCLK_P,
    EXT_PCIE_REFCLK_N,
    EXT_PCIE_rxn,
    EXT_PCIE_rxp,
    EXT_PCIE_txn,
    EXT_PCIE_txp,
    EXT_SYS_RST,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    fmc_imageon_iic_rst_n,
    fmc_imageon_iic_scl_io,
    fmc_imageon_iic_sda_io,
    vita_cam_clk_out_n,
    vita_cam_clk_out_p,
    vita_cam_clk_pll,
    vita_cam_data_n,
    vita_cam_data_p,
    vita_cam_monitor,
    vita_cam_reset_n,
    vita_cam_sync_n,
    vita_cam_sync_p,
    vita_cam_trigger,
    vita_clk,
    vita_spi_spi_miso,
    vita_spi_spi_mosi,
    vita_spi_spi_sclk,
    vita_spi_spi_ssel_n);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  output [4:0]EXT_LEDS;
  input EXT_PCIE_REFCLK_P;
  input EXT_PCIE_REFCLK_N;
  input [3:0]EXT_PCIE_rxn;
  input [3:0]EXT_PCIE_rxp;
  output [3:0]EXT_PCIE_txn;
  output [3:0]EXT_PCIE_txp;
  input EXT_SYS_RST;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  output [0:0]fmc_imageon_iic_rst_n;
  inout fmc_imageon_iic_scl_io;
  inout fmc_imageon_iic_sda_io;
  input vita_cam_clk_out_n;
  input vita_cam_clk_out_p;
  output vita_cam_clk_pll;
  input [3:0]vita_cam_data_n;
  input [3:0]vita_cam_data_p;
  input [1:0]vita_cam_monitor;
  output vita_cam_reset_n;
  input vita_cam_sync_n;
  input vita_cam_sync_p;
  output [2:0]vita_cam_trigger;
  input vita_clk;
  input vita_spi_spi_miso;
  output vita_spi_spi_mosi;
  output vita_spi_spi_sclk;
  output vita_spi_spi_ssel_n;


  wire EXT_PCIE_REFCLK;

  IBUFDS_GTE2 pcie_refclk_buf (.O(EXT_PCIE_REFCLK), .ODIV2(), .I(EXT_PCIE_REFCLK_P), .CEB(1'b0), .IB(EXT_PCIE_REFCLK_N));

  IOBUF fmc_imageon_iic_scl_iobuf
       (.I(fmc_imageon_iic_scl_o),
        .IO(fmc_imageon_iic_scl_io),
        .O(fmc_imageon_iic_scl_i),
        .T(fmc_imageon_iic_scl_t));
  IOBUF fmc_imageon_iic_sda_iobuf
       (.I(fmc_imageon_iic_sda_o),
        .IO(fmc_imageon_iic_sda_io),
        .O(fmc_imageon_iic_sda_i),
        .T(fmc_imageon_iic_sda_t));
  mmp_proj_bd mmp_proj_bd_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .EXT_LEDS(EXT_LEDS),
        .EXT_PCIE_REFCLK(EXT_PCIE_REFCLK),
        .EXT_PCIE_rxn(EXT_PCIE_rxn),
        .EXT_PCIE_rxp(EXT_PCIE_rxp),
        .EXT_PCIE_txn(EXT_PCIE_txn),
        .EXT_PCIE_txp(EXT_PCIE_txp),
        .EXT_SYS_RST(EXT_SYS_RST),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .fmc_imageon_iic_rst_n(fmc_imageon_iic_rst_n),
        .fmc_imageon_iic_scl_i(fmc_imageon_iic_scl_i),
        .fmc_imageon_iic_scl_o(fmc_imageon_iic_scl_o),
        .fmc_imageon_iic_scl_t(fmc_imageon_iic_scl_t),
        .fmc_imageon_iic_sda_i(fmc_imageon_iic_sda_i),
        .fmc_imageon_iic_sda_o(fmc_imageon_iic_sda_o),
        .fmc_imageon_iic_sda_t(fmc_imageon_iic_sda_t),
        .vita_cam_clk_out_n(vita_cam_clk_out_n),
        .vita_cam_clk_out_p(vita_cam_clk_out_p),
        .vita_cam_clk_pll(vita_cam_clk_pll),
        .vita_cam_data_n(vita_cam_data_n),
        .vita_cam_data_p(vita_cam_data_p),
        .vita_cam_monitor(vita_cam_monitor),
        .vita_cam_reset_n(vita_cam_reset_n),
        .vita_cam_sync_n(vita_cam_sync_n),
        .vita_cam_sync_p(vita_cam_sync_p),
        .vita_cam_trigger(vita_cam_trigger),
        .vita_clk(vita_clk),
        .vita_spi_spi_miso(vita_spi_spi_miso),
        .vita_spi_spi_mosi(vita_spi_spi_mosi),
        .vita_spi_spi_sclk(vita_spi_spi_sclk),
        .vita_spi_spi_ssel_n(vita_spi_spi_ssel_n));
endmodule

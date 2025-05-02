`include "variant_1/vc_vr_converter.sv"
`timescale 1ps/1ps

module tb;

parameter DATA_WIDTH = 8;

reg rst_n;
reg clk;

reg [DATA_WIDTH-1:0] s_data_i;
reg s_valid_i;
wire s_credit_o;

wire [DATA_WIDTH-1:0] m_data_o;
wire m_valid_o;
reg m_ready_i;

always #5 clk = ~clk;

vc_vr_converter vv (
    clk,
    rst_n,

    //valid/credit interface
    s_data_i,
    s_valid_i,
    s_credit_o,
    
    //valid/ready interface
    m_data_o,
    m_valid_o,
    m_ready_i
);

initial begin
    
    clk = 1;
    rst_n = 0;
    s_valid_i = 0;
    m_ready_i = 1;

    #12 rst_n = 1;

    #20;
    @(posedge clk) begin
        s_data_i <= 8'hA5;
        s_valid_i <= 1;
    end
    @(posedge clk) begin
        s_valid_i <= 0;
    end
    @(posedge clk) begin
        m_ready_i <= 0;
    end

    #15;
    @(posedge clk) begin
        s_valid_i <= 0;
    end
    @(posedge clk) begin
        s_data_i <= 8'hB8;
        s_valid_i <= 1;
    end
    @(posedge clk) begin
        s_data_i <= 8'hC6;
        s_valid_i <= 1;
    end
    @(posedge clk) begin
        s_data_i <= 8'hD1;
        s_valid_i <= 1;
    end
    @(posedge clk) begin
        s_data_i <= 8'hF4;
        s_valid_i <= 1;
    end
    @(posedge clk) begin
        s_valid_i <= 0;
    end

    #15;
    @(posedge clk) begin
        m_ready_i <= 1;
    end
    
    #15;
    @(posedge clk) begin
        s_data_i <= 8'h34;
        s_valid_i <= 1;
    end
    @(posedge clk) begin
        s_valid_i <= 0;
    end

    
    #50 $stop;
    
end

endmodule
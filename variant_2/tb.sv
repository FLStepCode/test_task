`include "variant_2/reorder_buffer.sv"
`timescale 1ps/1ps

module tb;

parameter DATA_WIDTH = 8;

reg rst_n;
reg clk;

reg [3:0] s_arid_i;
reg s_arvalid_i;
wire s_arready_o;

wire [DATA_WIDTH-1:0] s_rdata_o;
wire [3:0] s_rid_o;
wire s_rvalid_o;
reg s_rready_i;

wire [3:0] m_arid_o;
wire m_arvalid_o;
reg m_arready_i;

reg [DATA_WIDTH-1:0] m_rdata_i;
reg [3:0] m_rid_i;
reg m_rvalid_i;
wire m_rready_o;

always #5 clk = ~clk;

reg [3:0] s_arid_entries [$] = {4'h2, 4'hB, 4'hF, 4'hE, 4'hD, 4'h4, 4'h5};
reg [DATA_WIDTH-1:0] m_rdata_entries [$] = {8'h1A, 8'h99, 8'h67, 8'h02, 8'h23, 8'hF8, 8'hD6};
reg [3:0] m_rid_entries [$] = {4'hB, 4'h2, 4'hE, 4'h4, 4'hD, 4'h5, 4'hF};

    
task slave_send_id (
    input integer repeats
);

    integer i;
    reg flag;

    flag = 1;
    i = 0;

    while (i < repeats) begin
        @(posedge clk) begin
            if (s_arvalid_i == 0 || s_arready_o) begin
                s_arid_i <= s_arid_entries.pop_front();
                s_arvalid_i <= 1;
                i = i + 1;
            end
        end
    end

    do begin
        @(posedge clk) begin
            if (s_arready_o == 1) begin
                s_arvalid_i <= 0;
                flag = 0;
            end
        end
    end
    while (flag);

endtask

task master_send_data (
    input integer repeats
);

    integer i;
    reg flag;

    flag = 1;
    i = 0;

    while (i < repeats) begin
        @(posedge clk) begin
            if (m_rvalid_i == 0 || m_rready_o) begin
                m_rdata_i <= m_rdata_entries.pop_front();
                m_rid_i <= m_rid_entries.pop_front();
                m_rvalid_i <= 1;
                i = i + 1;
            end
        end
    end

    do begin
        @(posedge clk) begin
            if (m_rready_o == 1) begin
                m_rvalid_i <= 0;
                flag = 0;
            end
        end
    end
    while (flag);
    
endtask

reorder_buffer #(DATA_WIDTH) rb (
    .clk(clk),
    .rst_n(rst_n),

    //AR slave interface
    .s_arid_i(s_arid_i),
    .s_arvalid_i(s_arvalid_i),
    .s_arready_o(s_arready_o),

    //R slave interface
    .s_rdata_o(s_rdata_o),
    .s_rid_o(s_rid_o),
    .s_rvalid_o(s_rvalid_o),
    .s_rready_i(s_rready_i),

    //AR master interface
    .m_arid_o(m_arid_o),
    .m_arvalid_o(m_arvalid_o),
    .m_arready_i(m_arready_i),

    //R master interface
    .m_rdata_i(m_rdata_i),
    .m_rid_i(m_rid_i),
    .m_rvalid_i(m_rvalid_i),
    .m_rready_o(m_rready_o)
);

initial begin
    
    clk = 1;
    rst_n = 0;

    s_arvalid_i = 0;
    s_rready_i = 1;
    m_arready_i = 1;
    m_rvalid_i = 0;

    #12 rst_n = 1;
    
end

initial begin

    #12;

    #25;
    slave_send_id(1);

    #15;
    fork
        slave_send_id(1);
        master_send_data(1);
    join

    #15;
    fork
        #10 slave_send_id(2);
        #10 master_send_data(2);

        begin
            @(posedge clk) begin
                m_arready_i <= 0;
            end
            #25;
            @(posedge clk) begin
                m_arready_i <= 1;
                s_rready_i <= 0;
            end
            #25;
            @(posedge clk) begin
                s_rready_i <= 1;
            end
        end

        #50 master_send_data(1);

    join

    #25;
    fork
        
        slave_send_id(3);
        master_send_data(3);

    join

    #100;
    $stop;

end

endmodule
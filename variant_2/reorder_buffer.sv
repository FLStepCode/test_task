module reorder_buffer #(
    parameter DATA_WIDTH = 8
) (
    input logic clk,
    input logic rst_n,

    //AR slave interface
    input logic [3:0] s_arid_i,
    input logic s_arvalid_i,
    output logic s_arready_o,

    //R slave interface
    output logic [DATA_WIDTH-1:0] s_rdata_o,
    output logic [3:0] s_rid_o,
    output logic s_rvalid_o,
    input logic s_rready_i,

    //AR master interface
    output logic [3:0] m_arid_o,
    output logic m_arvalid_o,
    input logic m_arready_i,

    //R master interface
    input logic [DATA_WIDTH-1:0] m_rdata_i,
    input logic [3:0] m_rid_i,
    input logic m_rvalid_i,
    output logic m_rready_o
);
    
    assign m_arid_o = s_arid_i;
    assign m_arvalid_o = s_arvalid_i;
    assign s_arready_o = m_arready_i;
    assign m_rready_o = s_rready_i;

    logic [3:0] s_arid_FIFO [0:15];
    logic [3:0] FIFO_head;
    logic [3:0] FIFO_tail;

    logic [DATA_WIDTH:0] m_rdata_buffer [0:15];
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            FIFO_head <= 0;
            FIFO_tail <= 0;

            s_arid_FIFO <= '{16{0}};
            m_rdata_buffer <= '{16{0}};

        end 
        else begin

            s_rvalid_o <= 1'b0;
            
            if (s_arready_o && s_arvalid_i) begin
                s_arid_FIFO[FIFO_tail] <= s_arid_i;
                FIFO_tail <= FIFO_tail + 1;
            end

            if (m_rvalid_i && m_rready_o) begin
                m_rdata_buffer[m_rid_i] <= {1'b1, m_rdata_i};
            end

            if (m_rdata_buffer[s_arid_FIFO[FIFO_head]][DATA_WIDTH]) begin
                if (s_rready_i || !s_rvalid_o) begin
                    FIFO_head <= FIFO_head + 1;
                    s_rdata_o <= m_rdata_buffer[s_arid_FIFO[FIFO_head]];
                    s_rid_o <= s_arid_FIFO[FIFO_head];
                end
                s_rvalid_o <= 1'b1;
            end

        end
    end


endmodule
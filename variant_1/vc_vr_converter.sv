module vc_vr_converter #(
    parameter DATA_WIDTH = 8,
    CREDIT_NUM = 3,
    CREDIT_NUM_WIDTH = $clog2(CREDIT_NUM)
)(
    input logic clk,
    input logic rst_n,

    //valid/credit interface
    input logic [DATA_WIDTH-1:0] s_data_i,
    input logic s_valid_i,
    output logic s_credit_o,
    
    //valid/ready interface
    output logic [DATA_WIDTH-1:0] m_data_o,
    output logic m_valid_o,
    input logic m_ready_i
);

    logic [DATA_WIDTH-1:0] s_data_i_FIFO [0:CREDIT_NUM-1];
    logic [CREDIT_NUM_WIDTH-1:0] FIFO_head, FIFO_tail;
    logic [CREDIT_NUM_WIDTH:0] FIFO_count;

    logic [CREDIT_NUM_WIDTH:0] credit_counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            FIFO_head <= 0;
            FIFO_tail <= 0;
            FIFO_count <= 0;
            credit_counter <= 0;
        end
        else begin

            s_credit_o <= 1'b0;
            m_valid_o <= 1'b0;

            if (credit_counter < CREDIT_NUM) begin
                s_credit_o <= 1'b1;
                credit_counter <= credit_counter + 1;
            end
            else begin
                case ({s_valid_i, m_ready_i})
                    2'b00: begin
                        if (m_valid_o) begin
                            m_valid_o <= 1'b1;
                        end
                    end
                    2'b01: begin
                        if (FIFO_count != 0) begin
                            m_data_o <= s_data_i_FIFO[FIFO_head];
                            FIFO_head <= (FIFO_head == CREDIT_NUM - 1) ? 0 : FIFO_head + 1;
                            FIFO_count <= FIFO_count - 1;
                            s_credit_o <= 1'b1;
                            m_valid_o <= 1'b1;
                        end
                    end
                    2'b10: begin
                        if (FIFO_count < CREDIT_NUM) begin
                            s_data_i_FIFO[FIFO_tail] <= s_data_i;
                            FIFO_tail <= (FIFO_tail == CREDIT_NUM - 1) ? 0 : FIFO_tail + 1;
                            FIFO_count <= FIFO_count + 1;
                        end
                        if (m_valid_o) begin
                            m_valid_o <= 1'b1;
                        end
                    end
                    2'b11: begin
                        s_data_i_FIFO[FIFO_tail] <= s_data_i;
                        FIFO_tail <= (FIFO_tail == CREDIT_NUM - 1) ? 0 : FIFO_tail + 1;
                        
                        if (FIFO_count != 0) begin
                            m_data_o <= s_data_i_FIFO[FIFO_head];
                            FIFO_head <= (FIFO_head == CREDIT_NUM - 1) ? 0 : FIFO_head + 1;
                            s_credit_o <= 1'b1;
                            m_valid_o <= 1'b1;
                        end
                        else begin
                            FIFO_count <= FIFO_count + 1;
                        end

                    end
                endcase
            end
        end
    end

endmodule
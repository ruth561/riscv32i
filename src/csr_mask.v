module csr_mask (
    input  [ 2:0]   csr_funct,
    input  [31:0]   csr_val,
    input  [31:0]   rs1_val,
    input  [31:0]   imm,

    output [31:0]   result
);

    function [31:0] csr_mask_f;
        input  [ 2:0]   csr_funct;
        input  [31:0]   csr_val;
        input  [31:0]   rs1_val;
        input  [31:0]   imm;

        case (csr_funct)
            `INST_CSRRW_FUNCT:  csr_mask_f = rs1_val;
            `INST_CSRRWI_FUNCT: csr_mask_f = imm;
            `INST_CSRRS_FUNCT:  csr_mask_f = csr_val | rs1_val;
            `INST_CSRRSI_FUNCT: csr_mask_f = csr_val | imm;
            `INST_CSRRC_FUNCT:  csr_mask_f = csr_val & ~rs1_val;
            `INST_CSRRCI_FUNCT: csr_mask_f = csr_val & ~imm;
            default:            csr_mask_f = csr_val;
        endcase
    endfunction

    assign result = csr_mask_f(csr_funct, csr_val, rs1_val, imm);
    
endmodule

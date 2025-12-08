package Counter;

interface Counter;
    method Action inc;
    method Bit#(2) read;
endinterface

module mkCounter(Counter);
    Reg#(Bit#(2)) cnt <- mkReg(0);
    method Action inc;
        cnt <= {cnt[1] ^ cnt[0], ~cnt[0]};
    endmethod
    method Bit#(2) read;
        return cnt;
    endmethod
endmodule 

endpackage

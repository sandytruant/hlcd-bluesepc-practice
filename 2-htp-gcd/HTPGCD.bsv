import FIFO::*;

interface GCD;
    method Action start(Bit#(32) a, Bit#(32) b);
    method ActionValue#(Bit#(32)) getResult;
endinterface

typedef struct {
    Bit#(32) a;
    Bit#(32) b;
} Job deriving (Bits, Eq);

(* synthesize *)
module mkGCD(GCD);
    Reg#(Bit#(32)) x <- mkReg(0);
    Reg#(Bit#(32)) y <- mkReg(0);
    Reg#(Bool) busy_flag <- mkReg(False);

    rule gcd if (busy_flag);
        if (x >= y) begin
            x <= x - y;
        end else if (x != 0) begin
            x <= y; 
            y <= x; 
        end
    endrule
    method Action start (Bit#(32) a, Bit#(32) b) if (!busy_flag);
        x <= a;
        y <= b;
        busy_flag <= True;
    endmethod
    method ActionValue#(Bit#(32)) getResult if (busy_flag && (x == 0));
        busy_flag <= False;
        return y;
    endmethod
endmodule

(* synthesize *)
module mkHTPGCD(GCD);
    let gcd0 <- mkGCD;
    let gcd1 <- mkGCD;

    FIFO#(Job) inQ <- mkFIFO;
    FIFO#(Bit#(32)) outQ <- mkFIFO;
    Reg#(Bool) turnI <- mkReg(False);
    Reg#(Bool) turnO <- mkReg(False);

    rule feed0 if (!turnI);
        let t = inQ.first;
        inQ.deq;
        gcd0.start(t.a, t.b);
        turnI <= True;
    endrule

    rule feed1 if (turnI);
        let t = inQ.first;
        inQ.deq;
        gcd1.start(t.a, t.b);
        turnI <= False;
    endrule

    rule collect0 if (!turnO);
        let r <- gcd0.getResult;
        outQ.enq(r);
        turnO <= True;
    endrule

    rule collect1 if (turnO);
        let r <- gcd1.getResult;
        outQ.enq(r);
        turnO <= False;
    endrule

    method Action start (Bit#(32) a, Bit#(32) b);
        Job j = Job { a: a, b: b };
        inQ.enq(j);
    endmethod

    method ActionValue#(Bit#(32)) getResult;
        let r = outQ.first;
        outQ.deq;
        return r;
    endmethod

endmodule

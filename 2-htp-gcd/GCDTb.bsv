import HTPGCD::*;
import Vector::*;

// Batch-test multiple (a, b) pairs sequentially.
module mkTb();
    GCD gcd <- mkHTPGCD;

    Reg#(UInt#(8)) in_idx <- mkReg(0);
    Reg#(UInt#(8)) out_idx <- mkReg(0);

    Vector#(4, Tuple3#(Bit#(32), Bit#(32), Bit#(32))) tests = newVector;
    tests[0] = tuple3(48, 18, 6);
    tests[1] = tuple3(1071, 1029, 21);
    tests[2] = tuple3(270, 192, 6); 
    tests[3] = tuple3(0, 5, 5);

    // Start next test when gcd is idle
    rule startTest if (in_idx < 4);
        let t = tests[in_idx];
        let a = tpl_1(t);
        let b = tpl_2(t);
        $display("Starting case %0d: a=%0d b=%0d", in_idx, a, b);
        gcd.start(a, b);

        UInt#(8) nextInIdx = in_idx + 1;
        in_idx <= nextInIdx;
    endrule

    // Collect result and advance to next vector
    rule collectResult;
        Bit#(32) result <- gcd.getResult;
        let t = tests[out_idx];
        Bit#(32) exp = tpl_3(t);
        $display("Case %0d result: got=%0d expect=%0d", out_idx, result, exp);
        if (result != exp) $display("Mismatch!");

        UInt#(8) nextOutIdx = out_idx + 1;
        out_idx <= nextOutIdx;
        if (nextOutIdx == 4) $finish(0);
    endrule
endmodule

import GCD::*;
import Vector::*;

// Batch-test multiple (a, b) pairs sequentially.
module mkTb();
    GCD gcd <- mkGCD;

    Reg#(UInt#(8)) idx <- mkReg(0);

    Vector#(4, Tuple3#(Bit#(32), Bit#(32), Bit#(32))) tests = newVector;
    tests[0] = tuple3(48, 18, 6);
    tests[1] = tuple3(1071, 1029, 21);
    tests[2] = tuple3(270, 192, 6); 
    tests[3] = tuple3(0, 5, 5);

    // Start next test when gcd is idle
    rule startTest if (idx < 4);
        let t = tests[idx];
        let a = tpl_1(t);
        let b = tpl_2(t);
        $display("Starting case %0d: a=%0d b=%0d", idx, a, b);
        gcd.start(a, b);
    endrule

    // Collect result and advance to next vector
    rule collectResult;
        Bit#(32) result <- gcd.getResult;
        let t = tests[idx];
        Bit#(32) exp = tpl_3(t);
        $display("Case %0d result: got=%0d expect=%0d", idx, result, exp);
        if (result != exp) $display("Mismatch!");

        UInt#(8) nextIdx = idx + 1;
        idx <= nextIdx;
        if (nextIdx == 4) $finish(0);
    endrule
endmodule

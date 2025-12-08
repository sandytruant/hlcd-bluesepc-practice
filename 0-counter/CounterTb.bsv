import Counter::*;

module mkTb();
    Counter c <- mkCounter;

    rule inc;
        c.inc;
    endrule

    rule read;
        Bit#(2) value = c.read;
        $display("Counter value: %b", value);
        if (value == 3) $finish;
    endrule
endmodule

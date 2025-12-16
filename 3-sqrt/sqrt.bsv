
import FIFO::*;


module mkSqrtUInt32( FIFO#(UInt#(32)) );

    function Tuple2#(UInt#(32), UInt#(32)) sqrtIteration( 
        Tuple2#(UInt#(32), UInt#(32)) data, int n 
    );
        match {.x, .y} = data;
        let t = (y<<1<<n) + (1<<n<<n);
        if(x >= t) begin
            x = x - t;
            y = y + (1<<n);
        end
        return tuple2(x, y);
   endfunction
   
    FIFO#( Tuple2#(UInt#(32), UInt#(32)) ) fifos [17];

    for(int n=0; n<=16; n=n+1)
        fifos[n] <- mkFIFO;

    for(int n=15; n>=0; n=n-1)
    rule pipe_stages;
        fifos[n+1].deq;
        fifos[n].enq( sqrtIteration( fifos[n+1].first , n )  );
    endrule

    method Action enq(UInt#(32) x);        // 模块的 enq 方法负责：
        fifos[16].enq( tuple2(x, 0) );      //   把输入数据压入流水线最前级的 fifo
    endmethod

    method deq = fifos[0].deq;             // 模块的 deq 方法负责：流水线最末级的 fifo deq
   
    method UInt#(32) first;                // 模块的 first 方法负责：
        match {.x, .y} = fifos[0].first;    //   拿到流水线最末级的 fifo.first , 解构该 Tuple2 
        return y;                           //   返回其中的结果数据 y
    endmethod

    method Action clear;                   // 模块的 clear 方法负责：
        for(int n=0; n<=16; n=n+1)          //
            fifos[n].clear;                  //   清空所有流水级 fifo
    endmethod

endmodule


module mkTb();

    Reg#(int) cnt <- mkReg(0);
    rule up_counter;
        cnt <= cnt + 1;
        if(cnt > 40) $finish;
    endrule

    Reg#(UInt#(32)) x <- mkReg(1);
    
    FIFO#(UInt#(32)) sqrter <- mkSqrtUInt32;

    rule sqrter_input;
        sqrter.enq(x * 5);
        x <= x + 1;
    endrule

    rule sqrter_output (cnt%2==0);
        sqrter.deq;
        $display("%d", sqrter.first);
    endrule

endmodule

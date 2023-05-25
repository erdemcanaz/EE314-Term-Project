library verilog;
use verilog.vl_types.all;
entity d_latch_with_asynch_reset is
    port(
        D               : in     vl_logic;
        R               : in     vl_logic;
        CLK             : in     vl_logic;
        Q               : out    vl_logic;
        NQ              : out    vl_logic
    );
end d_latch_with_asynch_reset;

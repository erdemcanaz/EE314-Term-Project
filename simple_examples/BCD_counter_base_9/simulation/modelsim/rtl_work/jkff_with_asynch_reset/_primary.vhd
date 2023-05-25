library verilog;
use verilog.vl_types.all;
entity jkff_with_asynch_reset is
    port(
        J               : in     vl_logic;
        K               : in     vl_logic;
        R               : in     vl_logic;
        CLK             : in     vl_logic;
        Q               : out    vl_logic;
        NQ              : out    vl_logic
    );
end jkff_with_asynch_reset;

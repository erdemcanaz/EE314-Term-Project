library verilog;
use verilog.vl_types.all;
entity clock_divider is
    port(
        clk             : in     vl_logic;
        clk_25          : out    vl_logic
    );
end clock_divider;

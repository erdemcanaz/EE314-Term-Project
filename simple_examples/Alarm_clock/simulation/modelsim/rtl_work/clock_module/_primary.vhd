library verilog;
use verilog.vl_types.all;
entity clock_module is
    generic(
        clock_counter_max_val: integer := 5
    );
    port(
        clk_in          : in     vl_logic;
        clk_out         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of clock_counter_max_val : constant is 1;
end clock_module;

library verilog;
use verilog.vl_types.all;
entity horizontal_and_vertical_counter is
    port(
        clk_25          : in     vl_logic;
        h_count         : out    vl_logic_vector(10 downto 0);
        h_sync          : out    vl_logic;
        v_count         : out    vl_logic_vector(10 downto 0);
        v_sync          : out    vl_logic
    );
end horizontal_and_vertical_counter;

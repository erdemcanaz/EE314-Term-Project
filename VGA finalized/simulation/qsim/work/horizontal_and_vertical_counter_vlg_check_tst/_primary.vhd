library verilog;
use verilog.vl_types.all;
entity horizontal_and_vertical_counter_vlg_check_tst is
    port(
        h_count         : in     vl_logic_vector(10 downto 0);
        h_sync          : in     vl_logic;
        v_count         : in     vl_logic_vector(10 downto 0);
        v_sync          : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end horizontal_and_vertical_counter_vlg_check_tst;

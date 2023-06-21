library verilog;
use verilog.vl_types.all;
entity main_vga_module_vlg_check_tst is
    port(
        blue_8bit       : in     vl_logic_vector(7 downto 0);
        clock_out_25MHZ : in     vl_logic;
        green_8bit      : in     vl_logic_vector(7 downto 0);
        h_sync          : in     vl_logic;
        red_8bit        : in     vl_logic_vector(7 downto 0);
        v_sync          : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end main_vga_module_vlg_check_tst;

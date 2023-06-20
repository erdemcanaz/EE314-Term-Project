library verilog;
use verilog.vl_types.all;
entity main_vga_module is
    port(
        clock_builtin_50MHZ: in     vl_logic;
        clock_out_25MHZ : out    vl_logic;
        h_sync          : out    vl_logic;
        v_sync          : out    vl_logic;
        red_8bit        : out    vl_logic_vector(7 downto 0);
        green_8bit      : out    vl_logic_vector(7 downto 0);
        blue_8bit       : out    vl_logic_vector(7 downto 0)
    );
end main_vga_module;

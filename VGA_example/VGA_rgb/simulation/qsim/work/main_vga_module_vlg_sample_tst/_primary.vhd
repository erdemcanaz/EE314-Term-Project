library verilog;
use verilog.vl_types.all;
entity main_vga_module_vlg_sample_tst is
    port(
        clock_builtin_50MHZ: in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end main_vga_module_vlg_sample_tst;

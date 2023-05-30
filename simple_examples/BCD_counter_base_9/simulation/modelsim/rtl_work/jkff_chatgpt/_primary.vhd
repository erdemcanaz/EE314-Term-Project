library verilog;
use verilog.vl_types.all;
entity jkff_chatgpt is
    port(
        J               : in     vl_logic;
        K               : in     vl_logic;
        RST             : in     vl_logic;
        CLK             : in     vl_logic;
        Q               : out    vl_logic;
        NQ              : out    vl_logic
    );
end jkff_chatgpt;

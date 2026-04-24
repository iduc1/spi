`timescale 1ns / 1ps


module fsm(
input clk,reset,baslat,
input [7:0]veri_gonder,


output reg mosi,
output sclk,cs,hazir
    );
  localparam s_bosta = 0, s_hazirlik= 1, s_aktarim = 2, s_bitis = 3;
reg [1:0] state, next_state;
reg sclk_reg;
reg [7:0] shift_reg; 
reg [2:0]bit_sayac; 
   reg  [5:0]sayac;
   assign cs = (state == s_bosta) ? 1 : 0;
   assign hazir = (state == s_bitis);
   assign sclk = sclk_reg;
always @(posedge clk or posedge reset) begin
    if (reset) state <= s_bosta;
    else       state <= next_state;
end


always @(*) begin

    next_state = state;
    case(state)
        s_bosta:    if (baslat) next_state = s_hazirlik;
        s_hazirlik: next_state = s_aktarim;
        s_aktarim:  if (bit_sayac == 7) next_state = s_bitis;
        s_bitis:    next_state = s_bosta;
    endcase
end



always @(posedge clk or posedge reset) begin
if(reset)begin
shift_reg <= 0;
        bit_sayac <= 0;
        mosi <= 0;
    end else begin
    case(state)
        s_hazirlik: begin
            shift_reg <= veri_gonder;
            bit_sayac <= 0;
            mosi <= veri_gonder[7]; 
        end
        
        s_aktarim: begin
           
            if (sayac == 49 && sclk_reg == 1) begin
                if (bit_sayac < 7) begin
                    shift_reg <= {shift_reg[6:0], 1'b0};
                    mosi <= shift_reg[7]; 
                    bit_sayac <= bit_sayac + 1;
                end
                else begin
                    bit_sayac <= 7; 
                end
            end
        end
        
        s_bitis: begin
            mosi <= 0;
            bit_sayac <= 0;
        end
    endcase
end
end




always @(posedge clk or posedge reset) begin
    if (reset) begin
        sayac <= 0;
        sclk_reg <= 0;
    end 
    else if (state == s_aktarim) begin
        if (sayac == 49) begin 
            sayac <= 0;
            sclk_reg <= ~sclk_reg;
        end 
        else begin
            sayac <= sayac + 1;
        end
    end 
    else begin
        sayac <= 0;
        sclk_reg <= 0; 
    end
end


endmodule 
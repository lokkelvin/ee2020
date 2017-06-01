//1 change wave freq works

`timescale 1ns / 1ps

module myDAC_TOP(
	input CLK,
	input RESET,
	input btnL,btnR,btnU,btnD,btnC,
	sw10,sw11,sw12,sw13,sw14,sw15,sw1,sw2,sw3,sw4,sw5,sw6,sw7,sw8,
	output LED,
	output reg [11:0]LEDARRAY,
	output [3:0] JA,
	output [3:0] an,
	output [6:0] seg,
	output dp
	   );
	wire abtoggle;
	assign abtoggle = sw8;
	
	//channel A
	reg [11:0] DATA_A = 12'hFFF; //VOL-Gen -> Data_A bus and VOL-Gen -> Data_B
	reg [11:0] CurrentWave;
	
	//channel B
	reg [11:0] DATA_B = 12'hFFF;
	reg [11:0] CurrentWave2;
	
	wire HALF_CLOCK; //CLOCK DIVIDER- 50MHz
	wire SAMP_CLOCK; //1.5kHz
	
	//channel A Clocks Declaration
	wire DDS_CLOCK; //clock for 512 slices of waveform, 512 of freqwire
	wire SSD_CLOCK; // 60-1000hz
	wire SLOWER_CLOCK; // 
	wire waveclock;
	wire ramp_square_clock;
	wire phase_freq_clock;
	wire var_freq_clock;
	wire one_hz_clock;
	wire two_clock;
	
	//channel B Clocks Declaration
	wire DDS_CLOCK2; //clock for 512 slices of waveform, 512 of freqwire
	wire SSD_CLOCK2; // 60-1000hz
	wire SLOWER_CLOCK2; // 
	wire waveclock2;
	wire ramp_square_clock2;
	wire phase_freq_clock2;
	wire var_freq_clock2;
	wire one_hz_clock2;
	wire two_clock2;
	
	//common pulse declaration 
	wire PULSE_u; 
	wire PULSE_d;
	wire PULSE_r;
	wire PULSE_l;
	wire PULSE_c;
	
	//common
	wire HF_toggle; //toggle between Hz and kHz freqwireand ssd
	assign HF_toggle = sw7;
	wire PAGE; //toggle between page 1 and page 2
	assign PAGE = sw6; 
	
	//channel A Voltage and Pivot
	wire [11:0] Vmax;// = 12'hFFF;
	wire [11:0] Vmin;// = 12'b0;
	wire [11:0] pivot; //Max = number of timebase = 512 <-- depends on DDS_clock
	
	//channel B Voltage and Pivot
	wire [11:0] Vmax2;// = 12'hFFF;
	wire [11:0] Vmin2;// = 12'b0;
	wire [11:0] pivot2; //Max = number of timebase = 512 <-- depends on DDS_clock
	
	//channel A Waves
	wire [11:0] squarewave;
	wire [11:0] sawtoothwave;
	wire [11:0] SawtoothVaryDutyWave;
	wire [11:0] triwave;
	wire [11:0] sinewave;
	wire [11:0] rectifiedsinewave;
	wire [11:0] trapwave;

	wire [11:0] squarefy_wave;
	wire [11:0] squarefy_invert_wave;
	wire [11:0] invert_vertical_wave;
	wire [11:0] sinefy_wave;
	
	//channel B Waves
	wire [11:0] squarewave2;
	//wire [11:0] sawtoothwave2;
	wire [11:0] SawtoothVaryDutyWave2;
	wire [11:0] triwave2;
	wire [11:0] sinewave2;
	wire [11:0] rectifiedsinewave2;
	wire [11:0] trapwave2;

	wire [11:0] squarefy_wave2;
	wire [11:0] squarefy_invert_wave2;
	wire [11:0] invert_vertical_wave2;
	wire [11:0] sinefy_wave2;
	
	//common
	reg [11:0]stepsize = 12'b0;
	
	//channel A generated parameters
	wire [27:0]freqwire; //12 bits because alphamux expects 12 bits
	wire [11:0]combinedisplay; //Displays amp and freq
	wire [11:0]voltmax; //displays max in volts
	wire [11:0]voltmin; //displays min in volts

	
	//channel B generated parameters
	wire [27:0]freqwire2; //12 bits because alphamux expects 12 bits
	wire [11:0]combinedisplay2; //Displays amp and freq
	wire [11:0]voltmax2; //displays max in volts
	wire [11:0]voltmin2; //displays min in volts

	
    wire [3:0]hex; //input for ssd
    
    //channel A
	wire [15:0] eightfreqwire;
	assign eightfreqwire = 8*freqwire;
	wire [27:0] var_freqwire;
	assign var_freqwire = 20*200*freqwire; //waveform_num * (phases = (-100 to 100) == 200) * frequency
    wire [27:0] phasefreqwire;
	assign phasefreqwire = 200*freqwire; //BECAUASE sine mode uses @(posedge clock)
	
	//channel B
	wire [27:0] var_freqwire2;
	assign var_freqwire2 = 20*200*freqwire2; //waveform_num * (phases = (-100 to 100) == 200) * frequency
    wire [27:0] phasefreqwire2;
	assign phasefreqwire2 = 200*freqwire2; //BECAUASE sine mode uses @(posedge clock)
	
    //Module instantiation
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    //common
	clock_divider_half cdh1 (CLK,HALF_CLOCK);
	clock_divider_slower cds1 (CLK,SLOWER_CLOCK);
	clock_divider_ssd cdssd1 (CLK,SSD_CLOCK);
	debouncer debounce_left (SLOWER_CLOCK,btnL,PULSE_l);
	debouncer debounce_right (SLOWER_CLOCK,btnR,PULSE_r);
	debouncer debounce_up (SLOWER_CLOCK,btnU,PULSE_u);
	debouncer debounce_down (SLOWER_CLOCK,btnD,PULSE_d);
	debouncer debounce_center (SLOWER_CLOCK,btnC,PULSE_c);
	
	//common
	change_wave_freq cwf1(CLK,SLOWER_CLOCK,RESET,abtoggle,HF_toggle,sw13,sw14,sw15,btnL,btnR,stepsize,
		PULSE_l,PULSE_r,freqwire,freqwire2,waveclock,waveclock2);
	change_wave_amp cwa1 (CLK,SLOWER_CLOCK,RESET,abtoggle,sw11,sw12,sw13,sw14,sw15,btnU,btnD,stepsize,
		PULSE_u,PULSE_d,Vmax,Vmin,voltmax,voltmin,pivot,
		Vmax2,Vmin2,voltmax2,voltmin2,pivot2);

	clock_divider_samp cd1 (CLK,SAMP_CLOCK); //output clock for DAC port -> 3.125 Mhz
	clock_divider_custom_wave onehertz (CLK,1,one_hz_clock);
	
	//channel A
	clock_divider cd2 (CLK,freqwire,DDS_CLOCK); //output clock at 512*freqwire hz
	clock_divider cd3 (CLK,var_freqwire,DDS_CLOCK_faster); //output clock at 512*20*200*freqwire
	clock_divider_custom_wave sin_phase_accumulator (CLK,phasefreqwire,phase_freq_clock);
	clock_divider_custom_wave twofreqwire (CLK,2*freqwire,two_clock);
	clock_divider ramp_square_clock_div1 (CLK,eightfreqwire,ramp_square_clock);
	clock_divider_custom_wave varfreq (CLK,var_freqwire,var_freq_clock);
	
	//channel B
	clock_divider cd4 (CLK,freqwire2,DDS_CLOCK2); //output clock at 512*freqwire hz
	clock_divider cd5 (CLK,var_freqwire2,DDS_CLOCK_faster2); //output clock at 512*20*200*freqwire
	clock_divider_custom_wave sin_phase_accumulator2 (CLK,phasefreqwire2,phase_freq_clock2);
	clock_divider_custom_wave twofreqwire2 (CLK,2*freqwire2,two_clock2);
	clock_divider_custom_wave varfreq2 (CLK,var_freqwire2,var_freq_clock2);
	
	//Page 1: Basic waves
	/* Waves that can be operated on */
	//channel A
	gen_square_wave squarewave1(DDS_CLOCK,two_clock,HF_toggle,Vmax,Vmin,pivot,squarewave);
	gen_sawtooth_wave sawtooth1 (DDS_CLOCK,Vmax,Vmin,pivot,sawtoothwave,SawtoothVaryDutyWave);
	gen_tri_wave triwave1(DDS_CLOCK,Vmax,Vmin,triwave);
	gen_sin_wave2 sinwavedutycycle1 (CLK,DDS_CLOCK,freqwire,pivot,1,Vmax,Vmin, sinewave); //vary
	gen_half_rectified_sine rectsinwave1 (DDS_CLOCK,phase_freq_clock,Vmax,Vmin, rectifiedsinewave);
	gen_trapezium_wave trapwave1 (DDS_CLOCK,Vmax,Vmin,pivot,trapwave);
	
	//channel B
	gen_square_wave squarewave22(DDS_CLOCK2,two_clock2,HF_toggle,Vmax2,Vmin2,pivot2,squarewave2);
	gen_sawtooth_wave sawtooth22 (DDS_CLOCK2,Vmax2,Vmin2,pivot2,sawtoothwave2,SawtoothVaryDutyWave2);
	//gen_tri_wave triwave22(DDS_CLOCK2,Vmax2,Vmin2,triwave2);
	gen_sin_wave sinwave22 (DDS_CLOCK2,phase_freq_clock2,1,Vmax2,Vmin2, sinewave2);
	gen_half_rectified_sine rectsinwave22 (DDS_CLOCK2,phase_freq_clock2,Vmax2,Vmin2, rectifiedsinewave2);
	gen_trapezium_wave trapwave22 (DDS_CLOCK2,Vmax2,Vmin2,pivot2,trapwave2);
	
	
	//channel A only
	wire [11:0] fastsinewave;
	wire [11:0] fastsinewave2;
	wire [11:0] sinewaveAM;
	wire [11:0] sinewaveAM2;
	wire [11:0] flippingwave;
	wire [11:0] hiwave;
	//Page 2: Complex waves
	gen_hi_wave hiwave1 (DDS_CLOCK,var_freq_clock,Vmax,Vmin,hiwave);
    gen_sin_wave fastsine1 (DDS_CLOCK,phase_freq_clock,1,Vmax,Vmin,fastsinewave); //normal speeed
    gen_sin_wave fastsine2 (DDS_CLOCK,phase_freq_clock,0,Vmax,Vmin,fastsinewave2); //normal speed
    gen_sine_AM sinaddsin (DDS_CLOCK,var_freq_clock,1,fastsinewave,fastsinewave2,sinewaveAM);
    gen_sine_AM_two sinboundsin (DDS_CLOCK,DDS_CLOCK_faster,phase_freq_clock,var_freq_clock,Vmax,Vmin,pivot,sinewaveAM2,flippingwave);
	
	//Operations
	operation_squarefy squarefy (CurrentWave, var_freq_clock, squarefy_wave);
	operation_squarefy_invert squarefy_invert (CurrentWave, var_freq_clock, squarefy_invert_wave);
	operation_invert_vertical invert_vert (CurrentWave, invert_vertical_wave);
	gen_sin_wave sinefy (SAMP_CLOCK,var_freq_clock,1,CurrentWave,Vmin, sinefy_wave); //sin amplitude modulation
	
	
	//channel A
	reg [7:0]selected_wave=0; //256 possible waveforms to choose from
	wire [11:0]selected_wave_wire;
	assign selected_wave_wire = selected_wave;
	
	//channel B
	reg [7:0]selected_wave2=0; //256 possible waveforms to choose from
	wire [11:0]selected_wave_wire2;
	assign selected_wave_wire2 = selected_wave2;
	
	reg [31:0]display_timer=0; //timer for time that selected wave is shown on ssd
	reg show_CurrentWave_state=0; //state output
	wire show_CurrentWave_state_wire;
	assign show_CurrentWave_state_wire = show_CurrentWave_state;
	reg one_second_up_state=0; //internal state for timer fsm
	
	//channel A
	display_freq_n_amp display_freq_amp (one_hz_clock,Vmax,Vmin,freqwire,combinedisplay);
	//channel B
	display_freq_n_amp display_freq_amp2 (one_hz_clock,Vmax2,Vmin2,freqwire2,combinedisplay2);
	
	//mux SSD
	ssd_anode ssd_anode1 (SSD_CLOCK,sw1,sw2,sw12,sw13,sw14,sw15,show_CurrentWave_state_wire,an,dp); 
	alphanum_mux alphamux1 (abtoggle,HF_toggle,sw10,sw11,sw12,sw13,sw14,sw15,show_CurrentWave_state_wire,
		selected_wave_wire,Vmax,Vmin,freqwire,voltmax,voltmin,combinedisplay,pivot,
		selected_wave_wire2,Vmax2,Vmin2,freqwire2,voltmax2,voltmin2,combinedisplay2,pivot2,
			an,hex);
	ssd_cathode ssd_cathode1 (sw12,hex,seg);
	///////////////////////////////////////////////////////////////////////////////////////////

	//toggle waveform
	always @(posedge SLOWER_CLOCK) begin
		//channel A 
		if (PULSE_c && ~abtoggle) begin
			selected_wave <= (selected_wave == 11)?0:selected_wave+1; //increase number to number of waveforms
		end
		//channel B
		else if (PULSE_c && abtoggle) begin
			selected_wave2 <= (selected_wave2 == 4)?0:selected_wave2 + 1; //increase number to number of waveforms
		end
	end

	//fsm 1 second timer for seven segment display
	always @(posedge HALF_CLOCK) begin
		if ((show_CurrentWave_state == 1) || (display_timer > 0))begin
			display_timer <= display_timer + 1;
			if (display_timer == 32'd50_000_000) begin
				one_second_up_state <= 1;
			end
		end
		if (PULSE_c) begin
			show_CurrentWave_state <= 1;
		end
		else if (one_second_up_state) begin
			show_CurrentWave_state <= 0;
			display_timer <=0;
			one_second_up_state <=0;
		end
	end
	
	
	//toggle waveform
	//channel A
	always @(*) begin
		case (selected_wave) //increase bit bus for selected_wave if >3 waves
			0: CurrentWave = hiwave;
			1: CurrentWave = Vmax;
			2: CurrentWave = squarewave;
			3: CurrentWave = sawtoothwave;
			4: CurrentWave = SawtoothVaryDutyWave;
			5: CurrentWave = triwave;
			6: CurrentWave = trapwave;
			7: CurrentWave = sinewave;
			8: CurrentWave = rectifiedsinewave;
			9: CurrentWave = sinewaveAM;
			10: CurrentWave = sinewaveAM2;
			11: CurrentWave = flippingwave;
			default: CurrentWave = Vmax;
		endcase
	end
	//channel B
	always @(*) begin
		case (selected_wave2) //increase bit bus for selected_wave if >3 waves
			0: CurrentWave2 = squarewave2;
			1: CurrentWave2 = SawtoothVaryDutyWave2;
			2: CurrentWave2 = trapwave2;
			3: CurrentWave2 = sinewave2; //no pivot
			4: CurrentWave2 = rectifiedsinewave2;
			default: CurrentWave2 = Vmax2;
		endcase
	end
	
	//mux LED array
	always @* begin
		LEDARRAY = (abtoggle)?CurrentWave2:CurrentWave;
	end
	
    //math operations
    //channel A
	always @* begin
		case ({sw5,sw4,sw3})
			3'b001: DATA_A = squarefy_invert_wave;
			3'b010: DATA_A = squarefy_wave;
			3'b011: DATA_A = invert_vertical_wave;
			3'b100: DATA_A = sinefy_wave;
			default: DATA_A = CurrentWave;
		endcase
	end
	
	//channel B
	always @* begin
		DATA_B = CurrentWave2;
	end
	
	//switch low-high gain
	always @(*)begin
		case ({sw2,sw1})
			2'b01: stepsize = 12'd10;
			2'b10: stepsize = 12'd100;
			2'b11: stepsize = 12'd1000;
			default: stepsize = 12'd1;
		endcase
	end
	
//--------------------------------------------------------------------------------------------------------------------

DA2RefComp u1( //instantiate vhd code
    //SIGNALS PROVIDED TO DA2RefComp
    .CLK(HALF_CLOCK),  //output ports decalration
    .START(SAMP_CLOCK), 
    .DATA1(DATA_A), 
    .DATA2(DATA_B), 
    .RST(RESET), 
        
    //DO NOT CHANGE THE FOLLOWING LINES
    .D1(JA[1]), 
    .D2(JA[2]), 
    .CLK_OUT(JA[3]), 
    .nSYNC(JA[0]), 
    .DONE(LED)
    );

endmodule

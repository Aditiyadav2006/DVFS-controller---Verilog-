`timescale 1ns / 1ps

module dvfs_controller_tb;

// ------------------------------------------------------------------
// 1. SIGNALS
// ------------------------------------------------------------------
reg          clk;
reg          rst_n;
reg  [7:0]   job_queue_occupancy;

wire [1:0]   freq_sel;
wire [1:0]   volt_sel;
wire         dvfs_busy;

// ------------------------------------------------------------------
// 2. INSTANTIATION
// ------------------------------------------------------------------
// The Design Under Test (DUT)
dvfs_controller dut (
    .clk                  (clk),
    .rst_n                (rst_n),
    .job_queue_occupancy  (job_queue_occupancy),
    .freq_sel             (freq_sel),
    .volt_sel             (volt_sel),
    .dvfs_busy            (dvfs_busy)
);

// ------------------------------------------------------------------
// 3. CLOCK GENERATION
// ------------------------------------------------------------------
initial begin
    clk = 1'b0;
    // Clock period is 20ns (50 MHz)
    forever #10 clk = ~clk; 
end

// ------------------------------------------------------------------
// 4. WAVEFORM DUMP
// ------------------------------------------------------------------
initial begin
    // Setup the file for waveform viewing (GTKWave)
    $dumpfile("dvfs_wave.vcd");
    $dumpvars(0, dvfs_controller_tb);
    
    // Monitor key signals in the terminal for text-based checks
    $display("Time | Load | Current State | Busy | Freq/Volt | Target State");
    $monitor("%0t | %0d | %b | %b | %b | %b", 
             $time, job_queue_occupancy, dut.current_state, dvfs_busy, freq_sel, dut.target_state);
    $display("---------------------------------------------------------------");
end

// ------------------------------------------------------------------
// 5. STIMULUS (Test Scenarios - REVISED)
// ------------------------------------------------------------------
initial begin
    // --- 5.1: Reset Phase ---
    rst_n = 1'b0;
    job_queue_occupancy = 8'd0;
    #100; // Hold reset for 100ns

    // De-assert reset and set the initial, stable load condition (Normal State)
    rst_n = 1'b1;
    job_queue_occupancy = 8'd80; 
    
    // CRITICAL FIX: Wait one full clock cycle (20ns) to ensure the FSM sees the '80' load
    #20; 

    $display("\n--- Simulation Start (Stable in Normal State) ---");
    #2000; // Let it run in S_NORMAL for 100 cycles

    // --- 5.2: TEST 1: Normal -> Low Power (Load drops significantly) ---
    $display("\n--- TEST 1: Normal -> Low Power (Load=30) ---");
    // Load drops below THRESH_LOW (60) -> Should trigger S_TRANSITION
    job_queue_occupancy = 8'd30; 
    #2500; // Wait for the transition to finish (2000ns delay + buffer)

    // --- 5.3: TEST 2: Low Power -> High Performance (Load spikes) ---
    $display("\n--- TEST 2: Low Power -> High Performance (Load=200) ---");
    // Load spikes above THRESH_HIGH (128) -> Should trigger S_TRANSITION
    job_queue_occupancy = 8'd200; 
    #2500; // Wait for the transition to finish

    // --- 5.4: TEST 3: High Performance -> Normal (Moderate load) ---
    $display("\n--- TEST 3: High Performance -> Normal (Load=90) ---");
    // Load drops back to the middle (90) -> Should trigger S_TRANSITION
    job_queue_occupancy = 8'd90;
    #2500; // Wait for the transition to finish

    // --- 5.5: Stop Simulation ---
    $display("\n--- Simulation Finished ---");
    #100;
    $finish;
end

endmodule
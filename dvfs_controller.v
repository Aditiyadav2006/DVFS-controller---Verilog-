module dvfs_controller (
    // Clock and Reset
    input wire         clk,        // System clock
    input wire         rst_n,      // Active-low reset
    
    // Inputs (from Monitoring Block)
    input wire [7:0]   job_queue_occupancy, // 8-bit measure of system load

    // Outputs (to PLL/PMU)
    output reg [1:0]   freq_sel,   // 00: Low, 01: Normal, 10: High
    output reg [1:0]   volt_sel,   // 00: Low, 01: Normal, 10: High
    output reg         dvfs_busy   // High during frequency/voltage transition
);

// ------------------------------------------------------------------
// 1. PARAMETERS & STATE DEFINITIONS
// ------------------------------------------------------------------

// States (Mapped directly to frequency/voltage settings)
localparam S_LOW_POWER    = 2'b00;
localparam S_NORMAL       = 2'b01;
localparam S_HIGH_PERF    = 2'b10;
localparam S_TRANSITION   = 2'b11; 

// Thresholds for Load (0-255)
localparam THRESH_LOW     = 8'd60;  
localparam THRESH_HIGH    = 8'd128; 

// Transition Delay (in clock cycles)
localparam [7:0] TRANSITION_CYCLES = 8'd100; 

// ------------------------------------------------------------------
// 2. STATE MACHINE REGISTERS
// ------------------------------------------------------------------

reg [1:0] current_state, next_state;
reg [1:0] target_state;           // State we are moving *to*
reg [7:0] transition_counter;     // Counter for the S_TRANSITION state

// --- State Register ---
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        current_state <= S_NORMAL; 
    else
        current_state <= next_state;
end

// ------------------------------------------------------------------
// 3. NEXT STATE LOGIC
// ------------------------------------------------------------------

always @(*) begin
    next_state = current_state; 
    
    case (current_state)
        S_LOW_POWER: begin
            if (job_queue_occupancy > THRESH_HIGH) 
                next_state = S_TRANSITION;
            else if (job_queue_occupancy > THRESH_LOW) 
                next_state = S_TRANSITION; // Transition needed even for small steps
        end
        
        S_NORMAL: begin
            if (job_queue_occupancy > THRESH_HIGH) 
                next_state = S_TRANSITION;
            else if (job_queue_occupancy < THRESH_LOW) 
                next_state = S_TRANSITION;
        end
        
        S_HIGH_PERF: begin
            if (job_queue_occupancy < THRESH_LOW) 
                next_state = S_TRANSITION;
            else if (job_queue_occupancy < THRESH_HIGH) 
                next_state = S_TRANSITION;
        end

        S_TRANSITION: begin
            // Stay in transition until the counter finishes
            if (transition_counter == 8'd1) 
                next_state = target_state; // Move to the stored target state
            else 
                next_state = S_TRANSITION;
        end
        
        default: next_state = S_NORMAL;
    endcase
end

// ------------------------------------------------------------------
// 4. TRANSITION CONTROL LOGIC (Target and Busy)
// ------------------------------------------------------------------

// Determine the target state based on occupancy, regardless of current state
function [1:0] calculate_target_state;
    input [7:0] occupancy;

    begin
        if (occupancy > THRESH_HIGH)
            calculate_target_state = S_HIGH_PERF;
        else if (occupancy < THRESH_LOW)
            calculate_target_state = S_LOW_POWER;
        else 
            calculate_target_state = S_NORMAL;
    end
endfunction

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        transition_counter <= 8'd0;
        dvfs_busy          <= 1'b0;
        target_state       <= S_NORMAL;
    end else begin
        
        // 1. Entering Transition
        if (next_state == S_TRANSITION && current_state != S_TRANSITION) begin
            // Start counter, assert busy, and determine the destination state
            transition_counter <= TRANSITION_CYCLES;
            dvfs_busy          <= 1'b1;
            target_state       <= calculate_target_state(job_queue_occupancy);
        end 
        
        // 2. During Transition
        else if (current_state == S_TRANSITION && transition_counter > 8'd0) begin
            transition_counter <= transition_counter - 8'd1;
            dvfs_busy          <= 1'b1; 
        end 
        
        // 3. Exiting Transition
        else begin
            // Reset control signals when settled
            transition_counter <= 8'd0;
            dvfs_busy          <= 1'b0;
        end
    end
end

// ------------------------------------------------------------------
// 5. OUTPUT MAPPING (Frequency and Voltage)
// ------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        freq_sel <= S_NORMAL;
        volt_sel <= S_NORMAL;
    end else if (next_state != current_state && next_state != S_TRANSITION) begin
        // Only update the outputs when we are moving *out* of a transition 
        // and settling into the final, stable state (S_LOW, S_NORMAL, S_HIGH).
        freq_sel <= next_state;
        volt_sel <= next_state;
    end
end

endmodule
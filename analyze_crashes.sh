#!/bin/bash

OUTPUT_FILE="crash_analysis_results.txt"
rm -f "$OUTPUT_FILE"  

BINARY="json-2017-02-12-fsanitize_fuzzer"

analyze_crashes() {
    local dir=$1
    local sanitizer=$2
    local options=$3
    
    echo "=== Analyzing crashes in $dir with $sanitizer ===" | tee -a "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    if [ ! -d "$dir/default/crashes" ]; then
        echo "No crashes directory found in $dir" | tee -a "$OUTPUT_FILE"
        return
    fi
    
    for crash_file in "$dir/default/crashes/id:"*; do
        if [ -f "$crash_file" ]; then
            echo "Testing crash file: $(basename "$crash_file")" | tee -a "$OUTPUT_FILE"
            echo "----------------------------------------" >> "$OUTPUT_FILE"
            
            # Run the crash file with appropriate sanitizer options
            if [ -n "$options" ]; then
                env "$options" "./$BINARY" "$crash_file" 2>&1 | tee -a "$OUTPUT_FILE"
            else
                "./$BINARY" "$crash_file" 2>&1 | tee -a "$OUTPUT_FILE"
            fi
            
            echo "" >> "$OUTPUT_FILE"
            echo "----------------------------------------" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
        fi
    done
}

analyze_crashes "OUT_FIRST_RUN" "No Sanitizer" ""
analyze_crashes "OUT_SECOND_ASAN" "AddressSanitizer" "ASAN_OPTIONS=halt_on_error=1:print_stacktrace=1"
analyze_crashes "OUT_THIRD_LSAN" "LeakSanitizer" "LSAN_OPTIONS=halt_on_error=1:print_stacktrace=1"
analyze_crashes "OUT_FOURTH_MSAN" "MemorySanitizer" "MSAN_OPTIONS=halt_on_error=1:print_stacktrace=1"
analyze_crashes "OUT_FIFTH_UBSAN" "UndefinedBehaviorSanitizer" "UBSAN_OPTIONS=halt_on_error=1:print_stacktrace=1"

echo "Analysis complete. Results saved in $OUTPUT_FILE"
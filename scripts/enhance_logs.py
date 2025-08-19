#!/usr/bin/env python3
"""
Enhanced logging for IMO solution logs.
Adds timestamps, progress indicators, and better formatting.
"""

import os
import sys
import json
import re
from datetime import datetime
from pathlib import Path

class LogEnhancer:
    def __init__(self, log_dir="logs"):
        self.log_dir = Path(log_dir)
        self.start_time = None
        self.phase_times = {}
        
    def enhance_file(self, filepath):
        """Enhance a single log file with better formatting."""
        print(f"Enhancing {filepath}...")
        
        with open(filepath, 'r') as f:
            lines = f.readlines()
        
        enhanced_path = filepath.parent / f"{filepath.stem}_enhanced.log"
        with open(enhanced_path, 'w') as out:
            self.start_time = datetime.now()
            phase = "initialization"
            iteration = 0
            run = 0
            
            for i, line in enumerate(lines):
                timestamp = self._calculate_timestamp(i, len(lines))
                
                # Detect phase changes
                if ">>>>>>> First solution:" in line:
                    phase = "initial_solution"
                    out.write(f"\n{'='*80}\n")
                    out.write(f"{timestamp} [PHASE: INITIAL SOLUTION GENERATION]\n")
                    out.write(f"{'='*80}\n")
                elif ">>>>>>> Self improvement start:" in line:
                    phase = "self_improvement"
                    out.write(f"\n{'='*80}\n")
                    out.write(f"{timestamp} [PHASE: SELF-IMPROVEMENT]\n")
                    out.write(f"{'='*80}\n")
                elif ">>>>>>> Verify the solution." in line:
                    phase = "verification"
                    iteration += 1
                    out.write(f"\n{'-'*60}\n")
                    out.write(f"{timestamp} [VERIFICATION ITERATION {iteration}]\n")
                    out.write(f"{'-'*60}\n")
                elif "Number of iterations:" in line:
                    # Extract iteration info
                    match = re.search(r"iterations: (\d+).*corrects: (\d+).*errors: (\d+)", line)
                    if match:
                        it, correct, error = match.groups()
                        out.write(f"{timestamp} [PROGRESS] Iteration {it}: "
                                f"✅ {correct} correct, ❌ {error} errors\n")
                        continue
                elif "Found a correct solution" in line:
                    out.write(f"\n{'='*80}\n")
                    out.write(f"{timestamp} 🎉 [SUCCESS] SOLUTION FOUND!\n")
                    out.write(f"{'='*80}\n")
                    continue
                elif "Failed in finding" in line:
                    out.write(f"\n{timestamp} ❌ [FAILURE] {line}")
                    continue
                elif "Error" in line and "Error:" in line:
                    out.write(f"{timestamp} ⚠️  [ERROR] {line}")
                    continue
                    
                # Format JSON blocks better
                if line.strip().startswith('"') and "\\n" in line:
                    # This is likely a JSON string with embedded newlines
                    try:
                        # Extract and format the content
                        content = json.loads(line.strip())
                        if isinstance(content, str) and "Summary" in content:
                            # This is a solution summary
                            formatted = self._format_solution_summary(content)
                            out.write(formatted + "\n")
                            continue
                    except:
                        pass
                
                # Write the line with timestamp for important markers
                if line.startswith(">>>"):
                    out.write(f"{timestamp} {line}")
                else:
                    out.write(line)
        
        print(f"  ✅ Enhanced log saved to: {enhanced_path}")
        return enhanced_path
    
    def _calculate_timestamp(self, line_num, total_lines):
        """Calculate approximate timestamp based on line position."""
        if not self.start_time:
            self.start_time = datetime.now()
        
        # Assume linear progress (rough approximation)
        progress_ratio = line_num / max(total_lines, 1)
        elapsed_estimate = int(progress_ratio * 900)  # Assume 15 min total
        
        return f"[T+{elapsed_estimate:04d}s]"
    
    def _format_solution_summary(self, content):
        """Format solution summary for better readability."""
        lines = content.split("\\n")
        formatted = []
        
        for line in lines:
            if "Verdict" in line:
                formatted.append(f"  📋 {line}")
            elif "final answer" in line.lower():
                # Highlight the answer
                formatted.append(f"  🎯 {line}")
            elif line.startswith("*"):
                formatted.append(f"    {line}")
            else:
                formatted.append(f"  {line}")
        
        return "\n".join(formatted)
    
    def enhance_all(self):
        """Enhance all log files in the directory."""
        log_files = list(self.log_dir.glob("imo*.log"))
        
        if not log_files:
            print(f"No IMO log files found in {self.log_dir}")
            return
        
        print(f"Found {len(log_files)} log files to enhance")
        
        for log_file in sorted(log_files):
            # Skip already enhanced files
            if "_enhanced" not in str(log_file):
                self.enhance_file(log_file)
        
        print(f"\n✅ All logs enhanced!")

def main():
    if len(sys.argv) > 1:
        log_dir = sys.argv[1]
    else:
        log_dir = "logs"
    
    enhancer = LogEnhancer(log_dir)
    enhancer.enhance_all()

if __name__ == "__main__":
    main()
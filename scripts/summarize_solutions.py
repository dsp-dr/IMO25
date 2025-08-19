#!/usr/bin/env python3
"""
Generate a summary report of all IMO solutions found.
"""

import os
import sys
import json
import re
from pathlib import Path
from datetime import datetime

class SolutionSummarizer:
    def __init__(self, log_dir="logs"):
        self.log_dir = Path(log_dir)
        self.solutions = {}
        
    def extract_solution_info(self, filepath):
        """Extract key information from a solution log."""
        problem_num = re.search(r'imo0?(\d+)', filepath.name)
        if not problem_num:
            return None
        
        problem_id = int(problem_num.group(1))
        info = {
            'problem': problem_id,
            'file': filepath.name,
            'status': 'unknown',
            'answer': None,
            'method': None,
            'iterations': 0,
            'errors': [],
            'runtime': None
        }
        
        with open(filepath, 'r') as f:
            content = f.read()
        
        # Check if solution was found
        if "Found a correct solution" in content:
            info['status'] = 'solved'
        elif "Failed in finding" in content:
            info['status'] = 'failed'
        elif ">>>>>>> First solution:" in content:
            info['status'] = 'partial'
        
        # Extract answer based on problem type
        answer_patterns = {
            1: r"k\s*[∈=]\s*\{([^}]+)\}",
            3: r"smallest.*constant.*c.*is.*(\d+)",
            5: r"λ\s*=\s*([^,\n]+)"
        }
        
        if problem_id in answer_patterns:
            match = re.search(answer_patterns[problem_id], content, re.IGNORECASE)
            if match:
                info['answer'] = match.group(1).strip()
        
        # Extract iteration count
        iteration_matches = re.findall(r"Number of iterations: (\d+)", content)
        if iteration_matches:
            info['iterations'] = max(map(int, iteration_matches))
        
        # Extract errors
        error_matches = re.findall(r"Error[:\s]+([^\n]+)", content)
        info['errors'] = error_matches[:3]  # Keep first 3 errors
        
        # Extract method summary if available
        if "Method Sketch" in content:
            method_match = re.search(r"Method Sketch[:\s]*([^*]+)\*", content)
            if method_match:
                info['method'] = method_match.group(1).strip()[:200] + "..."
        
        return info
    
    def generate_markdown_summary(self):
        """Generate a markdown summary of all solutions."""
        output = []
        output.append("# IMO 2025 Solutions Summary")
        output.append(f"\nGenerated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        
        # Collect all solution info
        for log_file in sorted(self.log_dir.glob("imo*.log")):
            if "_enhanced" not in str(log_file):
                info = self.extract_solution_info(log_file)
                if info:
                    self.solutions[info['problem']] = info
        
        # Overall statistics
        total = len(self.solutions)
        solved = sum(1 for s in self.solutions.values() if s['status'] == 'solved')
        failed = sum(1 for s in self.solutions.values() if s['status'] == 'failed')
        partial = sum(1 for s in self.solutions.values() if s['status'] == 'partial')
        
        output.append("## Overall Statistics\n")
        output.append(f"- **Total Problems Attempted:** {total}")
        output.append(f"- **Solved:** {solved} ✅")
        output.append(f"- **Partial Solutions:** {partial} ⚠️")
        output.append(f"- **Failed:** {failed} ❌")
        output.append(f"- **Success Rate:** {solved/max(total,1)*100:.1f}%\n")
        
        # Problem-by-problem summary
        output.append("## Problem Details\n")
        
        for prob_id in sorted(self.solutions.keys()):
            info = self.solutions[prob_id]
            status_icon = {
                'solved': '✅',
                'partial': '⚠️',
                'failed': '❌',
                'unknown': '❓'
            }[info['status']]
            
            output.append(f"### Problem {prob_id} {status_icon}")
            output.append(f"- **Status:** {info['status'].upper()}")
            
            if info['answer']:
                output.append(f"- **Answer:** `{info['answer']}`")
            
            if info['iterations'] > 0:
                output.append(f"- **Iterations:** {info['iterations']}")
            
            if info['errors']:
                output.append(f"- **Errors Encountered:** {len(info['errors'])}")
                for error in info['errors'][:2]:
                    output.append(f"  - {error[:100]}...")
            
            if info['method']:
                output.append(f"- **Method:** {info['method']}")
            
            output.append(f"- **Log File:** `{info['file']}`")
            output.append("")
        
        # Quick reference table
        output.append("## Quick Reference Table\n")
        output.append("| Problem | Status | Answer | Iterations | Log File |")
        output.append("|---------|--------|--------|------------|----------|")
        
        for prob_id in sorted(self.solutions.keys()):
            info = self.solutions[prob_id]
            status_icon = {
                'solved': '✅',
                'partial': '⚠️',
                'failed': '❌',
                'unknown': '❓'
            }[info['status']]
            
            answer = info['answer'] if info['answer'] else '-'
            iterations = str(info['iterations']) if info['iterations'] > 0 else '-'
            
            output.append(f"| {prob_id} | {status_icon} {info['status']} | {answer} | {iterations} | {info['file']} |")
        
        output.append("\n---")
        output.append("*Note: This summary was automatically generated from log files.*")
        
        return "\n".join(output)
    
    def save_summary(self, output_path=None):
        """Save the summary to a file."""
        if output_path is None:
            output_path = self.log_dir / "SUMMARY.md"
        
        summary = self.generate_markdown_summary()
        
        with open(output_path, 'w') as f:
            f.write(summary)
        
        return output_path

def main():
    if len(sys.argv) > 1:
        log_dir = sys.argv[1]
    else:
        log_dir = "logs"
    
    summarizer = SolutionSummarizer(log_dir)
    summary = summarizer.generate_markdown_summary()
    print(summary)

if __name__ == "__main__":
    main()
#!/usr/bin/env python3
import argparse
import os
import signal
import sys
import time
import fcntl

# ── Default visual parameters ───────────────────────────────────────────────
DEFAULT_WIDTH  = 64
DEFAULT_HEIGHT = 12
DEFAULT_FPS    = 30
DEFAULT_DECAY  = 0.92
CHARS = [" ", ".", ":", "·", "•", "•"]  # ascending intensity


def parse_frame(line: str, width: int):
    """Parse a semicolon-separated line from CAVA into a list of ints."""
    try:
        return [int(x) for x in line.strip().split(";") if x][:width]
    except ValueError:
        return [0] * width


def normalize(vals):
    """Scale values to [0,1] range."""
    min_val = min(vals)
    max_val = max(vals)
    denom = max_val - min_val
    if denom == 0:
        return [0] * len(vals)
    return [(v - min_val) / denom for v in vals]


def get_char_index(val):
    """Map normalized value to CHARS index."""
    return min(int(val * (len(CHARS) - 1)), len(CHARS) - 1)


def build_ascii(decay_buffer, height, width):
    """Build ASCII frame from decay buffer."""
    lines = [""] * height
    for y in range(height):
        row = []
        for x in range(width):
            idx = get_char_index(decay_buffer[height - y - 1][x])
            row.append(CHARS[idx])
        lines[y] = "".join(row)
    return lines


def run(cava_path, out_path, width, height, fps, decay):
    os.makedirs(os.path.dirname(out_path), exist_ok=True)

    # Preallocate decay buffer
    decay_buffer = [[0.0] * width for _ in range(height)]
    prev_output = None

    # Open input FIFO non-blocking
    try:
        cava_file = open(cava_path, "r")
        fd = cava_file.fileno()
        fl = fcntl.fcntl(fd, fcntl.F_GETFL)
        fcntl.fcntl(fd, fcntl.F_SETFL, fl | os.O_NONBLOCK)
    except Exception as e:
        print(f"[!] Failed to open {cava_path}: {e}")
        return

    # Open output file persistently
    out_file = open(out_path, "w")

    while True:
        frame_start = time.time()

        try:
            line = cava_file.readline()
            if not line:
                # No data yet, just continue
                time.sleep(0.001)
                continue
        except Exception:
            time.sleep(0.001)
            continue

        # Parse & normalize
        values = parse_frame(line, width)
        norm_vals = normalize(values)

        # Build new frame and apply decay
        for x, val in enumerate(norm_vals):
            bar_h = int(val * height)
            for y in range(height):
                decay_buffer[y][x] = max(decay_buffer[y][x] * decay, 1.0 if y < bar_h else 0.0)

        # Convert to ASCII
        ascii_lines = build_ascii(decay_buffer, height, width)
        output = "\n".join(ascii_lines)

        # Write only if changed
        if output != prev_output:
            out_file.seek(0)
            out_file.write(output + "\n")
            out_file.flush()
            prev_output = output

        # Maintain FPS
        elapsed = time.time() - frame_start
        sleep_time = max(0, 1 / fps - elapsed)
        time.sleep(sleep_time)


def _handle_sigint(signum, frame):
    print("\n[+] CAVA ASCII visualizer stopped.")
    sys.exit(0)


def main():
    parser = argparse.ArgumentParser(description="CAVA → ASCII visualizer")
    parser.add_argument("--cava-path", default="/tmp/cava.raw")
    parser.add_argument("--out-path", default="/tmp/visualizer.txt")
    parser.add_argument("--width", type=int, default=DEFAULT_WIDTH)
    parser.add_argument("--height", type=int, default=DEFAULT_HEIGHT)
    parser.add_argument("--fps", type=int, default=DEFAULT_FPS)
    parser.add_argument("--decay", type=float, default=DEFAULT_DECAY)
    args = parser.parse_args()

    signal.signal(signal.SIGINT, _handle_sigint)
    print("[+] Starting CAVA ASCII visualizer …")
    run(
        cava_path=args.cava_path,
        out_path=args.out_path,
        width=args.width,
        height=args.height,
        fps=args.fps,
        decay=args.decay,
    )


if __name__ == "__main__":
    main()


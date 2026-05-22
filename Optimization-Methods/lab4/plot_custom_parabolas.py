import argparse
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np


# Default values. You can change them here or pass values from the terminal.
K = 0.018
X1_POINT = 1.0
X2_POINT = 1.0

# If AUTO_C_BY_POINT = True, C_plus and C_minus are calculated so both
# parabolas pass through (X1_POINT, X2_POINT).
#
# The constants below are the constants inside sqrt:
# x2 = sqrt( 2*k*x1 + C_PLUS)
# x2 = sqrt(-2*k*x1 + C_MINUS)
AUTO_C_BY_POINT = True
C_PLUS = 0.964
C_MINUS = 1.036

X1_MIN = -30.0
X1_MAX = 30.0
POINTS = 2000
BRANCHES = "upper"  # upper, lower, both

OUTPUT = "custom_parabolas.png"


def constants_by_point(k, x1_point, x2_point):
    """Return sqrt constants for curves through one selected point."""
    c_plus = x2_point**2 - 2 * k * x1_point
    c_minus = x2_point**2 + 2 * k * x1_point
    return c_plus, c_minus


def parabola_branch(x1, k, direction, c, sign):
    """
    Curve branch:
    direction = +1: x2 = sign * sqrt( 2*k*x1 + C)
    direction = -1: x2 = sign * sqrt(-2*k*x1 + C)

    sign = +1 gives the upper branch, sign = -1 gives the lower branch.
    """
    radicand = direction * 2 * k * x1 + c
    x2 = np.full_like(x1, np.nan, dtype=float)
    mask = radicand >= 0
    x2[mask] = sign * np.sqrt(radicand[mask])
    return x2


def plot_parabolas(
    k,
    c_plus,
    c_minus,
    x1_min,
    x1_max,
    points,
    x1_point,
    x2_point,
    branches,
    output,
):
    x1 = np.linspace(x1_min, x1_max, points)

    plus_upper = parabola_branch(x1, k, direction=1, c=c_plus, sign=1)
    plus_lower = parabola_branch(x1, k, direction=1, c=c_plus, sign=-1)
    minus_upper = parabola_branch(x1, k, direction=-1, c=c_minus, sign=1)
    minus_lower = parabola_branch(x1, k, direction=-1, c=c_minus, sign=-1)

    fig, ax = plt.subplots(figsize=(8, 5), dpi=140)
    if branches in ("upper", "both"):
        ax.plot(x1, plus_upper, color="#dc2626", linewidth=2.0, label=r"$x_2=\sqrt{2kx_1+C_+}$")
        ax.plot(x1, minus_upper, color="#2563eb", linewidth=2.0, label=r"$x_2=\sqrt{-2kx_1+C_-}$")
    if branches in ("lower", "both"):
        ax.plot(x1, plus_lower, color="#dc2626", linewidth=2.0, linestyle="--", label=r"$x_2=-\sqrt{2kx_1+C_+}$")
        ax.plot(x1, minus_lower, color="#2563eb", linewidth=2.0, linestyle="--", label=r"$x_2=-\sqrt{-2kx_1+C_-}$")

    ax.scatter([x1_point], [x2_point], color="black", s=45, zorder=5, label="selected point")
    ax.axhline(0, color="black", linewidth=0.8)
    ax.axvline(0, color="black", linewidth=0.8)
    ax.axvline(x1_point, color="0.35", linewidth=1.0, linestyle=":", alpha=0.8)
    ax.axhline(x2_point, color="0.35", linewidth=1.0, linestyle=":", alpha=0.8)

    ax.set_title("Phase parabolas")
    ax.set_xlabel(r"$x_1$")
    ax.set_ylabel(r"$x_2$")
    ax.grid(True, alpha=0.35)
    ax.legend(loc="best", fontsize=9)
    fig.tight_layout()

    output_path = Path(output)
    fig.savefig(output_path, bbox_inches="tight")
    print(f"Saved plot: {output_path.resolve()}")
    print(f"k = {k}")
    print(f"C_plus  in sqrt( 2*k*x1 + C_plus):  {c_plus:.9f}")
    print(f"C_minus in sqrt(-2*k*x1 + C_minus): {c_minus:.9f}")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Plot parabolas x2 = +/-sqrt(+/-2*k*x1 + C)."
    )
    parser.add_argument("--k", type=float, default=K)
    parser.add_argument("--x1-point", type=float, default=X1_POINT)
    parser.add_argument("--x2-point", type=float, default=X2_POINT)
    parser.add_argument("--c-plus", type=float, default=C_PLUS)
    parser.add_argument("--c-minus", type=float, default=C_MINUS)
    parser.add_argument("--manual-c", action="store_true", help="Use --c-plus and --c-minus instead of calculating them by point.")
    parser.add_argument("--x1-min", type=float, default=X1_MIN)
    parser.add_argument("--x1-max", type=float, default=X1_MAX)
    parser.add_argument("--points", type=int, default=POINTS)
    parser.add_argument("--branches", choices=("upper", "lower", "both"), default=BRANCHES)
    parser.add_argument("--output", default=OUTPUT)
    return parser.parse_args()


def main():
    args = parse_args()

    if AUTO_C_BY_POINT and not args.manual_c:
        c_plus, c_minus = constants_by_point(args.k, args.x1_point, args.x2_point)
    else:
        c_plus, c_minus = args.c_plus, args.c_minus

    plot_parabolas(
        k=args.k,
        c_plus=c_plus,
        c_minus=c_minus,
        x1_min=args.x1_min,
        x1_max=args.x1_max,
        points=args.points,
        x1_point=args.x1_point,
        x2_point=args.x2_point,
        branches=args.branches,
        output=args.output,
    )


if __name__ == "__main__":
    main()

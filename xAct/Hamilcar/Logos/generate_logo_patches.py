#!/usr/bin/env python3
"""
Generate precomputed TikZ fill commands for the Hamilcar logo.
This replaces the slow pgfmath calculations with fast NumPy operations.
"""

import numpy as np

# Parameters matching the logo layout
NSLICES = 3
CUBESIZE = 3.0
XSIZE = CUBESIZE
YSIZE = CUBESIZE
ZSIZE = CUBESIZE
SLICEHEIGHT = ZSIZE / NSLICES
CURVATURE = 0.12
ZMAX = NSLICES * SLICEHEIGHT

# Annular Gaussian parameters
MAXRINGRADIUS = 1.0
MINSIGMA = 0.2
MAXSIGMA = 0.6
MAXAMPLITUDE = 1.0
MINAMPLITUDE = 0.4

# Spiral modulation
SPIRALAMP = 0.5
SPIRALARMS = 2
SPIRALRADIAL = 15

# Patch sizes - use finer resolution since Python is fast
PATCHSIZE = 0.05
VPATCHSIZE = 0.05


def compute_color(xx, yy, zz, xsize, ysize, zmax):
    """Compute the blue color value (15-100) for a patch at position (xx, yy, zz)."""
    tfrac = zz / zmax if zmax > 0 else 0
    ringradius = tfrac * MAXRINGRADIUS
    ringsigma = MINSIGMA + tfrac * (MAXSIGMA - MINSIGMA)
    amplitude = MAXAMPLITUDE - tfrac * (MAXAMPLITUDE - MINAMPLITUDE)

    cx = xx - xsize / 2
    cy = yy - ysize / 2
    rr = np.sqrt(cx * cx + cy * cy)
    thetadeg = np.degrees(np.arctan2(cy, cx))

    rmod = ringradius + SPIRALAMP * np.sin(np.radians(SPIRALARMS * thetadeg + SPIRALRADIAL * rr * 180 / np.pi))

    if ringsigma > 0:
        gaussval = amplitude * np.exp(-((rr - rmod) / ringsigma) ** 2)
    else:
        gaussval = 0

    return gaussval


def get_color_string(gaussval):
    """Convert gaussval to TikZ color string."""
    if gaussval < 0.7:
        # Scale 0-0.7 to blue!15 to blue!100
        blue_pct = 15 + (gaussval / 0.7) * 85
        return f"blue!{blue_pct:.1f}"
    else:
        # Scale 0.7-1.0 to blue!100!black down to blue!5!black
        black_mix = (gaussval - 0.7) / 0.3 * 95
        blue_in_mix = 100 - black_mix
        return f"blue!{blue_in_mix:.1f}!black"


def vcurve_offset(z):
    """Compute vertical curve offset at height z."""
    return 0.5 * CURVATURE * (1 - np.cos(np.radians(z * 180 / ZMAX)))


def generate_horizontal_patches(slice_idx, xsize, ysize, patchsize, output_file):
    """Generate patches for a horizontal slice, with corners offset to match curved vertical edges."""
    zbase = slice_idx * SLICEHEIGHT

    # Vertical curve offset at this slice height
    vc = 0.5 * CURVATURE * (1 - np.cos(np.radians(zbase * 180 / ZMAX)))

    xx_vals = np.arange(0, xsize + 0.001, patchsize)
    yy_vals = np.arange(0, ysize + 0.001, patchsize)

    for xx in xx_vals[:-1]:
        for yy in yy_vals[:-1]:
            colval = compute_color(xx + patchsize/2, yy + patchsize/2, zbase, xsize, ysize, ZMAX)

            xxp = min(xx + patchsize, xsize)
            yyp = min(yy + patchsize, ysize)

            # x offsets: interpolate from +vc at x=0 to -vc at x=xsize
            x00_off = vc * (1 - 2 * xx / xsize)
            x10_off = vc * (1 - 2 * xxp / xsize)
            x11_off = vc * (1 - 2 * xxp / xsize)
            x01_off = vc * (1 - 2 * xx / xsize)

            # y offsets: interpolate from -vc at y=0 to +vc at y=ysize
            y00_off = vc * (-1 + 2 * yy / ysize)
            y10_off = vc * (-1 + 2 * yy / ysize)
            y11_off = vc * (-1 + 2 * yyp / ysize)
            y01_off = vc * (-1 + 2 * yyp / ysize)

            z00 = zbase + CURVATURE * np.sin(np.radians(xx * 180 / xsize)) + CURVATURE * np.sin(np.radians(yy * 180 / ysize))
            z10 = zbase + CURVATURE * np.sin(np.radians(xxp * 180 / xsize)) + CURVATURE * np.sin(np.radians(yy * 180 / ysize))
            z11 = zbase + CURVATURE * np.sin(np.radians(xxp * 180 / xsize)) + CURVATURE * np.sin(np.radians(yyp * 180 / ysize))
            z01 = zbase + CURVATURE * np.sin(np.radians(xx * 180 / xsize)) + CURVATURE * np.sin(np.radians(yyp * 180 / ysize))

            color_str = get_color_string(colval)
            output_file.write(f"\\fill[{color_str}, opacity=0.7] "
                            f"({xx + x00_off:.4f}, {yy + y00_off:.4f}, {z00:.4f}) -- "
                            f"({xxp + x10_off:.4f}, {yy + y10_off:.4f}, {z10:.4f}) -- "
                            f"({xxp + x11_off:.4f}, {yyp + y11_off:.4f}, {z11:.4f}) -- "
                            f"({xx + x01_off:.4f}, {yyp + y01_off:.4f}, {z01:.4f}) -- cycle;\n")


def generate_front_face_patches(xsize, ysize, vpatchsize, output_file):
    """Generate patches for front face (y=0), warped to match curved vertical edges."""
    xx_vals = np.arange(0, xsize + 0.001, vpatchsize)
    zz_vals = np.arange(0, ZMAX + 0.001, vpatchsize)

    for xx in xx_vals[:-1]:
        for zz in zz_vals[:-1]:
            colval = compute_color(xx + vpatchsize/2, 0, zz + vpatchsize/2, xsize, ysize, ZMAX)

            xxp = min(xx + vpatchsize, xsize)
            zzp = min(zz + vpatchsize, ZMAX)

            # Vertical curve offsets at each z height
            vc1 = vcurve_offset(zz)
            vc2 = vcurve_offset(zzp)

            # x offsets: interpolate from +vcurve at x=0 to -vcurve at x=xsize
            x1_off = vc1 * (1 - 2 * xx / xsize)
            x2_off = vc1 * (1 - 2 * xxp / xsize)
            x3_off = vc2 * (1 - 2 * xxp / xsize)
            x4_off = vc2 * (1 - 2 * xx / xsize)

            # y offset: -vcurve (front face curves outward in -y)
            y1 = -vc1
            y2 = -vc2

            # Curved z interpolation (horizontal sheet curvature)
            zbotcurve = CURVATURE * np.sin(np.radians(xx * 180 / xsize))
            zbotcurvep = CURVATURE * np.sin(np.radians(xxp * 180 / xsize))
            ztopcurve = ZMAX + CURVATURE * np.sin(np.radians(xx * 180 / xsize))
            ztopcurvep = ZMAX + CURVATURE * np.sin(np.radians(xxp * 180 / xsize))

            z1 = zbotcurve + (zz / ZMAX) * (ztopcurve - zbotcurve)
            z2 = zbotcurvep + (zz / ZMAX) * (ztopcurvep - zbotcurvep)
            z3 = zbotcurvep + (zzp / ZMAX) * (ztopcurvep - zbotcurvep)
            z4 = zbotcurve + (zzp / ZMAX) * (ztopcurve - zbotcurve)

            color_str = get_color_string(colval)
            output_file.write(f"\\fill[{color_str}, opacity=0.5] "
                            f"({xx + x1_off:.4f}, {y1:.4f}, {z1:.4f}) -- "
                            f"({xxp + x2_off:.4f}, {y1:.4f}, {z2:.4f}) -- "
                            f"({xxp + x3_off:.4f}, {y2:.4f}, {z3:.4f}) -- "
                            f"({xx + x4_off:.4f}, {y2:.4f}, {z4:.4f}) -- cycle;\n")


def generate_right_face_patches(xsize, ysize, vpatchsize, output_file):
    """Generate patches for right face (x=xsize), warped to match curved vertical edges."""
    yy_vals = np.arange(0, ysize + 0.001, vpatchsize)
    zz_vals = np.arange(0, ZMAX + 0.001, vpatchsize)

    for yy in yy_vals[:-1]:
        for zz in zz_vals[:-1]:
            colval = compute_color(xsize, yy + vpatchsize/2, zz + vpatchsize/2, xsize, ysize, ZMAX)

            yyp = min(yy + vpatchsize, ysize)
            zzp = min(zz + vpatchsize, ZMAX)

            # Vertical curve offsets at each z height
            vc1 = vcurve_offset(zz)
            vc2 = vcurve_offset(zzp)

            # x offset: -vcurve (right face curves inward in -x direction)
            x1 = xsize - vc1
            x2 = xsize - vc2

            # y offsets: interpolate from -vcurve at y=0 to +vcurve at y=ysize
            y1_off = vc1 * (-1 + 2 * yy / ysize)
            y2_off = vc1 * (-1 + 2 * yyp / ysize)
            y3_off = vc2 * (-1 + 2 * yyp / ysize)
            y4_off = vc2 * (-1 + 2 * yy / ysize)

            # Curved z interpolation (x=xsize, so sin(180)=0)
            zbotcurve = CURVATURE * np.sin(np.radians(180)) + CURVATURE * np.sin(np.radians(yy * 180 / ysize))
            zbotcurvep = CURVATURE * np.sin(np.radians(180)) + CURVATURE * np.sin(np.radians(yyp * 180 / ysize))
            ztopcurve = ZMAX + CURVATURE * np.sin(np.radians(180)) + CURVATURE * np.sin(np.radians(yy * 180 / ysize))
            ztopcurvep = ZMAX + CURVATURE * np.sin(np.radians(180)) + CURVATURE * np.sin(np.radians(yyp * 180 / ysize))

            z1 = zbotcurve + (zz / ZMAX) * (ztopcurve - zbotcurve)
            z2 = zbotcurvep + (zz / ZMAX) * (ztopcurvep - zbotcurvep)
            z3 = zbotcurvep + (zzp / ZMAX) * (ztopcurvep - zbotcurvep)
            z4 = zbotcurve + (zzp / ZMAX) * (ztopcurve - zbotcurve)

            color_str = get_color_string(colval)
            output_file.write(f"\\fill[{color_str}, opacity=0.5] "
                            f"({x1:.4f}, {yy + y1_off:.4f}, {z1:.4f}) -- "
                            f"({x1:.4f}, {yyp + y2_off:.4f}, {z2:.4f}) -- "
                            f"({x2:.4f}, {yyp + y3_off:.4f}, {z3:.4f}) -- "
                            f"({x2:.4f}, {yy + y4_off:.4f}, {z4:.4f}) -- cycle;\n")


def main():
    # Generate patches for left figure (xoffset=0): front face, right face, top slice only
    with open('GitHubLogoPatchesLeft.tex', 'w') as f:
        f.write("% Auto-generated by generate_logo_patches.py\n")
        f.write("% Front face patches\n")
        generate_front_face_patches(XSIZE, YSIZE, VPATCHSIZE, f)
        f.write("% Right face patches\n")
        generate_right_face_patches(XSIZE, YSIZE, VPATCHSIZE, f)
        f.write("% Top slice horizontal patches\n")
        generate_horizontal_patches(NSLICES, XSIZE, YSIZE, PATCHSIZE, f)

    # Generate patches for right figure (xoffset=14): all slices
    with open('GitHubLogoPatchesRight.tex', 'w') as f:
        f.write("% Auto-generated by generate_logo_patches.py\n")
        for i in range(NSLICES + 1):
            f.write(f"% Slice {i} horizontal patches\n")
            generate_horizontal_patches(i, XSIZE, YSIZE, PATCHSIZE, f)

    print("Generated GitHubLogoPatchesLeft.tex and GitHubLogoPatchesRight.tex")


if __name__ == '__main__':
    main()

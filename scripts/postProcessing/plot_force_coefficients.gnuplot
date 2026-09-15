# =============================================================================
# Macarena Wing — Aerodynamic Coefficient Post-Processing
#
# This script generates aerodynamic coefficient histories from OpenFOAM
# forceCoeffs output.
#
# Expected data columns:
#
#   1 : Time
#   2 : Cm
#   3 : Cd
#   4 : Cl
#
# The script can be used in two ways:
#
#   1. Published-data mode
#      Provide an existing merged coefficient file using DataFile.
#
#   2. Raw OpenFOAM mode
#      Set MergeRaw = 1 while running inside an OpenFOAM
#      postProcessing/forceCoeffs*/ directory. Segmented forceCoeffs.dat
#      files will be merged automatically.
#
# Example:
#
#   gnuplot -e "CaseName='Normal Motion'; \
#               DataFile='results/normal/coefficients/forceCoeffs_Normal.dat'; \
#               OutputDir='results/normal/coefficients'; \
#               OutputPrefix='Macarena_Normal'" \
#               scripts/postProcessing/plot_force_coefficients.gnuplot
#
# =============================================================================


# =============================================================================
# User-configurable parameters
# =============================================================================

if (!exists("CaseName"))     CaseName = "Normal Motion"
if (!exists("MergeRaw"))     MergeRaw = 0
if (!exists("DataFile"))     DataFile = "forceCoeffs_merged.dat"
if (!exists("OutputDir"))    OutputDir = "."
if (!exists("OutputPrefix")) OutputPrefix = "Macarena"


# =============================================================================
# Optional: merge segmented OpenFOAM forceCoeffs.dat files
# =============================================================================

if (MergeRaw == 1) {

    print "Merging segmented OpenFOAM forceCoeffs.dat files..."

    system "for f in $(find . -mindepth 2 -maxdepth 2 -type f -name forceCoeffs.dat -print | sort -V); do \
        awk '!/^#/ && NF > 0' \"$f\"; \
    done | sort -n -k1,1 -u > forceCoeffs_merged.dat"

    DataFile = "forceCoeffs_merged.dat"
}


# =============================================================================
# Create output directory if necessary
# =============================================================================

system sprintf("mkdir -p '%s'", OutputDir)


# =============================================================================
# Common plotting configuration
# =============================================================================

set datafile commentschars "#"

set terminal pngcairo \
    size 1800,1000 \
    enhanced \
    font "Arial,17"

set border linewidth 1.2

set grid xtics ytics \
    linecolor rgb "#E3E3E3" \
    linewidth 1

set xrange [0.04:0.65]

set lmargin 8
set rmargin 16
set tmargin 3
set bmargin 4


# =============================================================================
# Colors
#
# Colorblind-friendly palette:
#
# Cd : vermillion
# Cl : blue
# Cm : green
# =============================================================================

CdColor = "#D55E00"
ClColor = "#0072B2"
CmColor = "#009E73"


# =============================================================================
# Motion-event times
# =============================================================================

OpeningStart = 0.05
OpeningEnd   = 0.45


# =============================================================================
# Reusable motion-period annotation
# =============================================================================

set object 1 rect \
    from OpeningStart, graph 0 \
    to OpeningEnd, graph 1 \
    behind \
    fillcolor rgb "#F2F2F2" \
    fillstyle solid 1.0 \
    noborder

set arrow 1 \
    from OpeningStart, graph 0 \
    to OpeningStart, graph 1 \
    nohead \
    dashtype 2 \
    linewidth 1.3 \
    linecolor rgb "#888888"

set arrow 2 \
    from OpeningEnd, graph 0 \
    to OpeningEnd, graph 1 \
    nohead \
    dashtype 2 \
    linewidth 1.3 \
    linecolor rgb "#888888"

set label 1 "Opening begins" \
    at OpeningStart + 0.008, graph 0.935 \
    textcolor rgb "#555555" \
    font "Arial,14"

set label 2 "Fully open" \
    at OpeningEnd + 0.008, graph 0.935 \
    textcolor rgb "#555555" \
    font "Arial,14"

set label 3 "Flap opening" \
    at (OpeningStart + OpeningEnd)/2.0, graph 0.06 \
    center \
    textcolor rgb "#777777" \
    font "Arial,14"


# =============================================================================
# Cd plot
# =============================================================================

set output sprintf("%s/%s_Cd.png", OutputDir, OutputPrefix)

unset y2tics
unset y2label

set xlabel "Time (s)" \
    font "Arial,18" \
    offset 0,0.8

set ylabel "C_{d}" \
    font "Arial,18" \
    offset 1.2,0 \
    textcolor rgb CdColor

set ytics textcolor rgb CdColor

set title sprintf("Drag Coefficient History — %s", CaseName) \
    font "Arial,20" \
    offset 0,0.6

set key outside right top vertical \
    opaque box linewidth 1 \
    spacing 1.15 \
    samplen 3.2 \
    width 0.8 \
    height 0.3 \
    font "Arial,16"

plot \
    DataFile using 1:3 \
    with lines \
    linewidth 2.6 \
    linecolor rgb CdColor \
    title "C_{d}"

set output


# =============================================================================
# Cl plot
# =============================================================================

set output sprintf("%s/%s_Cl.png", OutputDir, OutputPrefix)

unset y2tics
unset y2label

set xlabel "Time (s)" \
    font "Arial,18" \
    offset 0,0.8

set ylabel "C_{l}" \
    font "Arial,18" \
    offset 1.2,0 \
    textcolor rgb ClColor

set ytics textcolor rgb ClColor

set title sprintf("Lift Coefficient History — %s", CaseName) \
    font "Arial,20" \
    offset 0,0.6

set key outside right top vertical \
    opaque box linewidth 1 \
    spacing 1.15 \
    samplen 3.2 \
    width 0.8 \
    height 0.3 \
    font "Arial,16"

plot \
    DataFile using 1:4 \
    with lines \
    linewidth 2.6 \
    linecolor rgb ClColor \
    title "C_{l}"

set output


# =============================================================================
# Cm plot
# =============================================================================

set output sprintf("%s/%s_Cm.png", OutputDir, OutputPrefix)

unset y2tics
unset y2label

set xlabel "Time (s)" \
    font "Arial,18" \
    offset 0,0.8

set ylabel "C_{m}" \
    font "Arial,18" \
    offset 1.2,0 \
    textcolor rgb CmColor

set ytics textcolor rgb CmColor

set title sprintf("Moment Coefficient History — %s", CaseName) \
    font "Arial,20" \
    offset 0,0.6

set key outside right top vertical \
    opaque box linewidth 1 \
    spacing 1.15 \
    samplen 3.2 \
    width 0.8 \
    height 0.3 \
    font "Arial,16"

plot \
    DataFile using 1:2 \
    with lines \
    linewidth 2.6 \
    linecolor rgb CmColor \
    title "C_{m}"

set output


# =============================================================================
# Cd + Cl dual-axis plot
# =============================================================================

set output sprintf("%s/%s_Cd_Cl.png", OutputDir, OutputPrefix)

set xlabel "Time (s)" \
    font "Arial,18" \
    offset 0,0.8

set ylabel "C_{d}" \
    font "Arial,18" \
    offset 1.2,0 \
    textcolor rgb CdColor

set y2label "C_{l}" \
    font "Arial,18" \
    offset -1.2,0 \
    textcolor rgb ClColor

set ytics nomirror \
    textcolor rgb CdColor

set y2tics \
    textcolor rgb ClColor

set title sprintf("Aerodynamic Coefficient Histories — %s", CaseName) \
    font "Arial,20" \
    offset 0,0.6

set key outside right top vertical \
    opaque box linewidth 1 \
    spacing 1.15 \
    samplen 3.2 \
    width 0.8 \
    height 0.3 \
    font "Arial,16"

plot \
    DataFile using 1:3 axes x1y1 \
        with lines \
        linewidth 2.6 \
        linecolor rgb CdColor \
        title "C_{d}", \
    DataFile using 1:4 axes x1y2 \
        with lines \
        linewidth 2.6 \
        linecolor rgb ClColor \
        title "C_{l}"

set output


# =============================================================================
# Finished
# =============================================================================

print sprintf("Finished plotting: %s", CaseName)
print sprintf("Input data:        %s", DataFile)
print sprintf("Output directory:  %s", OutputDir)

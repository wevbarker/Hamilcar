#!/bin/bash

# Generate precomputed patches
python3 generate_logo_patches.py

# Compile with lualatex (dynamic memory for large patch files)
lualatex -interaction=nonstopmode GitHubLogo.tex
lualatex -interaction=nonstopmode GitLabLogo.tex

# Convert to PNG with transparency
magick -density 800 GitHubLogo.pdf -transparent white GitHubLogo.png
magick -density 300 GitLabLogo.pdf -transparent white GitLabLogo.png

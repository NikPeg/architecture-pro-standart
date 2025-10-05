#!/bin/bash

# Script to generate PlantUML diagrams locally
# For macOS, Linux, and Windows (Git Bash)

set -e

echo "🔍 Checking dependencies..."

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "❌ Java is not installed. Please install Java first."
    echo "   On macOS: brew install openjdk"
    echo "   On Ubuntu: sudo apt-get install default-jre"
    exit 1
fi

# Check if PlantUML is available
PLANTUML_JAR="plantuml.jar"
PLANTUML_URL="https://github.com/plantuml/plantuml/releases/download/v1.2024.3/plantuml-1.2024.3.jar"

if [ ! -f "$PLANTUML_JAR" ]; then
    echo "📥 Downloading PlantUML..."
    if command -v wget &> /dev/null; then
        wget -O "$PLANTUML_JAR" "$PLANTUML_URL"
    elif command -v curl &> /dev/null; then
        curl -L -o "$PLANTUML_JAR" "$PLANTUML_URL"
    else
        echo "❌ Neither wget nor curl is installed. Please install one of them."
        echo "   On macOS: brew install wget"
        echo "   On Ubuntu: sudo apt-get install wget"
        exit 1
    fi
    echo "✅ PlantUML downloaded successfully"
fi

echo "🎨 Generating diagrams..."

# Find all .puml files and generate diagrams
find . -name "*.puml" -not -path "./.git/*" | while read -r puml_file; do
    echo "  Processing: $puml_file"

    # Generate PNG
    java -jar "$PLANTUML_JAR" -tpng "$puml_file" 2>/dev/null || {
        echo "  ⚠️  Failed to generate PNG for $puml_file"
    }

    # Generate SVG
    java -jar "$PLANTUML_JAR" -tsvg "$puml_file" 2>/dev/null || {
        echo "  ⚠️  Failed to generate SVG for $puml_file"
    }
done

echo "✅ Diagram generation complete!"
echo ""
echo "📊 Generated files:"
find . -name "*.png" -o -name "*.svg" | grep -v ".git" | sort

# Optional: Open generated diagrams on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo ""
    read -p "Would you like to open the generated diagrams? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        find Task1/diagrams -name "*.png" -exec open {} \;
    fi
fi

#!/bin/bash

# Test script for Enhanced dbt CI/CD with Recce
# This script helps verify that the setup is working correctly

set -e

echo "🧪 Testing Enhanced dbt CI/CD with Recce Setup"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Check prerequisites
echo -e "\n${BLUE}1. Checking Prerequisites${NC}"
echo "------------------------"

# Check Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
    print_status "SUCCESS" "Python $PYTHON_VERSION found"
else
    print_status "ERROR" "Python3 not found. Please install Python 3.8+"
    exit 1
fi

# Check dbt
if command -v dbt &> /dev/null; then
    DBT_VERSION=$(dbt --version 2>&1 | head -n1 | cut -d' ' -f2)
    print_status "SUCCESS" "dbt $DBT_VERSION found"
else
    print_status "ERROR" "dbt not found. Please install dbt-snowflake"
    exit 1
fi

# Check recce
if command -v recce &> /dev/null; then
    RECCE_VERSION=$(recce --version 2>&1 | head -n1 | cut -d' ' -f2)
    print_status "SUCCESS" "Recce $RECCE_VERSION found"
else
    print_status "ERROR" "Recce not found. Please install recce"
    exit 1
fi

# Check required files
echo -e "\n${BLUE}2. Checking Required Files${NC}"
echo "---------------------------"

required_files=("dbt_project.yml" "profiles.yml" "recce.yml" "dbt-requirements.txt")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        print_status "SUCCESS" "$file exists"
    else
        print_status "ERROR" "$file not found"
        exit 1
    fi
done

# Check GitHub Actions workflows
echo -e "\n${BLUE}3. Checking GitHub Actions Workflows${NC}"
echo "--------------------------------------"

workflow_files=(".github/workflows/ci.yml" ".github/workflows/cd.yml" ".github/workflows/ci_teardown.yml")
for file in "${workflow_files[@]}"; do
    if [ -f "$file" ]; then
        print_status "SUCCESS" "$file exists"
    else
        print_status "ERROR" "$file not found"
        exit 1
    fi
done

# Test dbt configuration
echo -e "\n${BLUE}4. Testing dbt Configuration${NC}"
echo "----------------------------"

# Test dbt debug
if dbt debug --target pr --vars "schema_id: test_123__abc123" &> /dev/null; then
    print_status "SUCCESS" "dbt debug passed for PR target"
else
    print_status "WARNING" "dbt debug failed for PR target (check your Snowflake credentials)"
fi

# Test dbt deps
if dbt deps &> /dev/null; then
    print_status "SUCCESS" "dbt deps completed"
else
    print_status "WARNING" "dbt deps failed (check packages.yml)"
fi

# Test Recce configuration
echo -e "\n${BLUE}5. Testing Recce Configuration${NC}"
echo "-------------------------------"

# Test recce debug
if recce debug &> /dev/null; then
    print_status "SUCCESS" "Recce debug passed"
else
    print_status "WARNING" "Recce debug failed (this is normal if no base artifacts exist yet)"
fi

# Check recce.yml syntax
if python3 -c "import yaml; yaml.safe_load(open('recce.yml'))" &> /dev/null; then
    print_status "SUCCESS" "recce.yml syntax is valid"
else
    print_status "ERROR" "recce.yml has syntax errors"
    exit 1
fi

# Test workflow syntax
echo -e "\n${BLUE}6. Testing Workflow Syntax${NC}"
echo "---------------------------"

# Check if we have yq or can use python to validate YAML
if command -v yq &> /dev/null; then
    for workflow in .github/workflows/*.yml; do
        if yq eval '.' "$workflow" &> /dev/null; then
            print_status "SUCCESS" "$(basename "$workflow") syntax is valid"
        else
            print_status "ERROR" "$(basename "$workflow") has syntax errors"
            exit 1
        fi
    done
else
    print_status "WARNING" "yq not found, skipping workflow syntax validation"
fi

# Summary
echo -e "\n${BLUE}7. Test Summary${NC}"
echo "==============="

print_status "SUCCESS" "Basic setup validation completed!"
print_status "INFO" "Next steps:"
echo "  1. Set up GitHub secrets (SNOWFLAKE_*, RECCE_STATE_PASSWORD)"
echo "  2. Create a test PR to trigger the CI workflow"
echo "  3. Monitor the GitHub Actions tab for results"
echo "  4. Check for PR comments with validation results"

echo -e "\n${BLUE}For detailed testing instructions, see test-setup.md${NC}"

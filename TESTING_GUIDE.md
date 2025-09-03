# 🧪 Complete Testing Guide for Enhanced dbt CI/CD with Recce

## ✅ Current Status
Your enhanced dbt CI/CD pipeline is **ready for testing**! The local setup validation shows:
- ✅ All required files are present
- ✅ dbt and Recce are installed correctly
- ✅ Recce configuration is valid
- ✅ GitHub Actions workflows are in place

## 🚀 Testing Options

### Option 1: GitHub Actions Testing (Recommended)

This is the most comprehensive way to test the full pipeline:

#### Step 1: Set Up GitHub Secrets
Add these secrets to your repository settings (Settings → Secrets and variables → Actions):

**Required Secrets:**
```
SNOWFLAKE_ACCOUNT=your-account-name
SNOWFLAKE_USER=your-username
SNOWFLAKE_PASSWORD=your-password
SNOWFLAKE_ROLE=your-role
SNOWFLAKE_WAREHOUSE=your-warehouse
SNOWFLAKE_DATABASE=your-database
SNOWFLAKE_SCHEMA=your-schema
RECCE_STATE_PASSWORD=your-secure-password
```

#### Step 2: Create a Test PR
```bash
# Create a new branch
git checkout -b test-recce-validation

# Make a small change to test validation
echo "-- Test comment for Recce validation" >> models/marts/dim_customers.sql

# Commit and push
git add .
git commit -m "Test: Add comment to trigger Recce validation"
git push origin test-recce-validation
```

#### Step 3: Open PR and Monitor
1. Go to GitHub and open a PR from `test-recce-validation` to `main`
2. Watch the **Actions** tab for the CI workflow
3. Look for the **PR comment** with validation results
4. Check **Artifacts** for the Recce state file

### Option 2: Local Testing (Without Snowflake)

If you want to test locally without Snowflake credentials:

#### Test Recce Configuration
```bash
# Test Recce configuration
recce debug

# This should show:
# ✅ Artifacts found in target/ (if any exist)
# ✅ Base artifacts found in target-base/ (if any exist)
# ⚠️ Warehouse connection failed (expected without credentials)
```

#### Test Recce YAML Syntax
```bash
# Validate the recce.yml file
python3 -c "import yaml; yaml.safe_load(open('recce.yml')); print('✅ recce.yml syntax is valid')"
```

### Option 3: Mock Testing

Create a simple test to verify the workflow logic:

#### Test Workflow Syntax
```bash
# Install yq for YAML validation (optional)
brew install yq

# Validate workflow files
yq eval '.' .github/workflows/ci.yml
yq eval '.' .github/workflows/cd.yml
```

## 🎯 What to Expect During Testing

### First Run (No Base Artifacts)
When you first run the CI workflow:
- ✅ dbt build will complete successfully
- ⚠️ Recce will run without base comparison
- ✅ PR comment will appear with validation results
- ✅ State file will be uploaded as artifact

### Subsequent Runs (With Base Artifacts)
After the first successful run:
- ✅ dbt build will use Slim CI (only changed models)
- ✅ Recce will compare against base artifacts
- ✅ PR comment will show detailed validation results
- ✅ State file will be available for detailed review

## 📊 Validation Results You'll See

### PR Comment Example
```markdown
# Recce Validation Summary

## ✅ Validation Results
- **Row count validation - dim_customers**: ✅ PASSED
- **Customer Lifetime Value validation**: ✅ PASSED  
- **Order status distribution validation**: ✅ PASSED
- **Payment method revenue impact**: ✅ PASSED
- **Schema validation - fct_orders**: ✅ PASSED

## 📊 Key Metrics
- Total customers: 1,234 (no change)
- Total revenue: $45,678 (+2.3% from base)
- Order count: 5,678 (+1.1% from base)

## Next Steps
Download the Recce state file from workflow artifacts and run:
```bash
recce server --review recce_state.json
```
```

### Artifacts Available
- `recce-state-pr-{number}` - Detailed validation state file
- `dbt-manifest` - dbt manifest for future comparisons
- `dbt-catalog` - dbt catalog for schema validation
- `dbt-run-results` - dbt run results for performance tracking

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. GitHub Actions Fails
**Problem**: Workflow fails to start or complete
**Solutions**:
- Check that all required secrets are set
- Verify repository permissions
- Check workflow file syntax
- Review action logs for specific errors

#### 2. Recce Validation Fails
**Problem**: Recce validation step fails
**Solutions**:
- Check that `recce.yml` syntax is valid
- Verify that dbt build completed successfully
- Check that base artifacts are available (for subsequent runs)
- Review Recce debug output

#### 3. PR Comment Not Appearing
**Problem**: Validation runs but no PR comment
**Solutions**:
- Check that `GITHUB_TOKEN` secret is set
- Verify that the PR comment action has proper permissions
- Check workflow logs for comment posting errors

#### 4. State File Not Uploaded
**Problem**: Artifacts not appearing
**Solutions**:
- Check that `RECCE_STATE_PASSWORD` secret is set
- Verify that Recce validation completed successfully
- Check artifact upload permissions

## 🎉 Success Criteria

Your enhanced CI/CD pipeline is working correctly when:

1. **✅ CI Workflow Runs**: GitHub Actions triggers on PR creation
2. **✅ dbt Build Completes**: Slim CI builds only changed models
3. **✅ Recce Validation Runs**: Data validation executes successfully
4. **✅ PR Comment Appears**: Validation results posted to PR
5. **✅ Artifacts Uploaded**: State files and dbt artifacts saved
6. **✅ CD Workflow Runs**: Deployment works on merge to main

## 🚀 Next Steps After Testing

Once testing is successful:

1. **Customize Validation Checks**: Edit `recce.yml` for your specific needs
2. **Add Team-Specific Checks**: Create validation for your business logic
3. **Set Up Monitoring**: Monitor validation results over time
4. **Train Team**: Show team how to review validation results
5. **Document Patterns**: Create guidelines for common validation scenarios

## 📚 Additional Resources

- **Recce Documentation**: [recce_context/](recce_context/) folder
- **Test Setup Guide**: [test-setup.md](test-setup.md)
- **Model Change Examples**: [test-model-change.md](test-model-change.md)
- **Setup Script**: [test-recce-setup.sh](test-recce-setup.sh)

## 🆘 Getting Help

If you encounter issues:

1. **Check the logs**: Review GitHub Actions logs for specific errors
2. **Run local tests**: Use the test script to verify local setup
3. **Review documentation**: Check the Recce context files
4. **Test incrementally**: Start with simple changes and build up

---

**Ready to test?** Start with Option 1 (GitHub Actions Testing) for the most comprehensive validation of your enhanced CI/CD pipeline!

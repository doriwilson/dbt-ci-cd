# Test Model Changes for Validation

## Quick Test Changes

Here are some simple model changes you can make to test the Recce validation:

### 1. Test Row Count Validation
**File**: `models/marts/dim_customers.sql`
**Change**: Add a filter to reduce row count
```sql
-- Add this line before the final select
where customer_id < 1000  -- This will reduce row count for testing
```

### 2. Test Business Logic Validation
**File**: `models/marts/dim_customers.sql`
**Change**: Modify customer tier logic
```sql
-- Change the customer tier logic
case
    when cm.total_spent >= 2000 then 'VIP'      -- Changed from 1000
    when cm.total_spent >= 1000 then 'Premium'  -- Changed from 500
    when cm.total_spent >= 200 then 'Regular'   -- Changed from 100
    else 'New'
end as customer_tier
```

### 3. Test Schema Change Detection
**File**: `models/marts/dim_customers.sql`
**Change**: Add a new column
```sql
-- Add this line in the final select
c.created_at,
c.updated_at,
'Test Column' as test_field,  -- Add this new column
coalesce(cm.total_orders, 0) as total_orders,
```

### 4. Test Data Quality Validation
**File**: `models/staging/stg_orders.sql`
**Change**: Modify order status
```sql
-- Change the status field
select
    order_id,
    customer_id,
    order_date,
    'TEST_STATUS' as status,  -- Change this line
    total_amount,
    -- ... rest of the fields
```

## Testing Workflow

1. **Make a small change** from the examples above
2. **Commit and push** to a new branch
3. **Open a PR** to main
4. **Watch the CI workflow** in GitHub Actions
5. **Check the PR comment** for validation results
6. **Download the state file** from artifacts for detailed review

## Expected Results

- **Row count changes**: Should show in validation results
- **Business logic changes**: Should affect customer tier distribution
- **Schema changes**: Should be detected by schema validation
- **Data quality issues**: Should trigger warnings in validation

## Reverting Changes

After testing, you can revert the changes:
```bash
git checkout HEAD~1 -- models/marts/dim_customers.sql
git commit -m "Revert test changes"
git push
```

## Advanced Testing

For more comprehensive testing, you can:

1. **Test multiple changes** in one PR
2. **Test edge cases** (empty results, null values)
3. **Test performance** with large datasets
4. **Test error handling** with invalid SQL

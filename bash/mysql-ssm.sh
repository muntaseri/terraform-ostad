# 1. Define your environment variables
DB_HOST="terraform-ostad-dev-mysql.csjgoyqkw5w2.us-east-1.rds.amazonaws.com"
DB_NAME="appdb"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:223532248928:secret:rds!db-958c04a7-8704-42bf-873e-8d53ee976334-sKyc7S"

# 2. Fetch credentials securely from AWS Secrets Manager
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --query SecretString --output text --region us-east-1)
export DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
export MYSQL_PWD=$(echo "$SECRET_JSON" | jq -r '.password')

# 3. Run the MySQL test query
mysql -h "$DB_HOST" -u "$DB_USER" -D "$DB_NAME" -e "SELECT NOW() AS connection_time, VERSION() AS mysql_version;"

# 4. Clear sensitive variables immediately for a safe screenshot
unset MYSQL_PWD
unset SECRET_JSON


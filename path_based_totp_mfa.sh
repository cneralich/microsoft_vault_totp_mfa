#!/bin/bash
TEST_USER=${TEST_USER:-testuser}
TEST_PASSWORD=${TEST_PASSWORD:-testpassword}
SECRET_KEY=${SECRET_KEY:-foo}
SECRET_VALUE=${SECRET_VALUE:-zoo}
TOTP_PERIOD=${TOTP_PERIOD:-30}
TOTP_KEYSIZE=${TOTP_KEYSIZE:-30}
TOTP_ALGO=${TOTP_ALGO:-SHA1}
TOTP_DIGITS=${TOTP_DIGITS:-6}

vault auth enable userpass

vault write sys/mfa/method/totp/my_totp \
  issuer=Vault \
  period=${TOTP_PERIOD} \
  key_size=${TOTP_KEYSIZE} \
  algorithm=${TOTP_ALGO} \
  digits=${TOTP_DIGITS}

vault policy write totp-policy -<<EOF
#Support both v1 and v2 paths
path "secret/${SECRET_KEY}" {
capabilities = ["read"]
mfa_methods  = ["my_totp"]
}
path "secret/data/${SECRET_KEY}" {
capabilities = ["read"]
mfa_methods  = ["my_totp"]
}
EOF

vault secrets enable -path=secret kv

vault kv put secret/${SECRET_KEY} password=${SECRET_VALUE}

vault write auth/userpass/users/${TEST_USER} password=${TEST_PASSWORD} policies=totp-policy

TOKEN=$(vault write -field=token auth/userpass/login/${TEST_USER} password=${TEST_PASSWORD})

ENTITY_ID=$(vault token lookup -format=json ${TOKEN} | jq -r .data.entity_id)

BARCODE=$(vault write -field=barcode sys/mfa/method/totp/my_totp/admin-generate entity_id=${ENTITY_ID})

echo "Paste the following into your browser to generate the TOTP image to import into your MFA device e.g. Google Authenticator"

echo "data:image/png;base64,${BARCODE}"
echo

echo "Run the following commands to login and test"
cat <<EOF
unset VAULT_TOKEN
vault login -method=userpass username=${TEST_USER} password=${TEST_PASSWORD}
vault kv get -mfa=my_totp:${CODE} secret/${SECRET_KEY}
EOF

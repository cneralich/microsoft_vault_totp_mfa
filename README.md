# How to Set Up MFA on Vault using TOTP and the Microsoft Authenticator App
This repo contains examples for how to setup MFA in Vault for both LDAP Authentication and path-based CRUD Operations using TOTP and the Microsoft Authenticator App.
> **_Note:_** The below workflows will only work when interacting with Vault via the CLI/API, not the UI.

## PATH-BASED MFA
MFA can be enforced against specific paths within Vault, and may even be applied to specific CRUD Operations against them.  To enable this workflow using the Microsft Authenticator App, Vault's [TOTP MFA](https://www.vaultproject.io/docs/enterprise/mfa/mfa-totp) feature can be used to verify `totp` values generated by the Microsoft Authenticator App and passed to Vault when performing operations.  An example of the setup for this workflow can be found [here](path_based_totp_mfa.sh).  As an example, a request meeting the MFA requirement might look like:
```
vault kv get -mfa=my_totp:123456 secret_new/${SECRET_KEY}
```


## LDAP AUTH MFA
LDAP Auth MFA can be enforced by creating a Sentinel [Endpoint Governing Policy (EGP)](https://www.vaultproject.io/docs/enterprise/sentinel#endpoint-governing-policies-egps) using [this](ldap_auth_totp_mfa) example code. Once enabled, users authenticating via LDAP will be expected to pass the `-mfa` flag in their authentication requests and must include the `totp` generated by their Microsoft Authenticator App.  For example, an expected call might look like:
```
vault login -mfa=my_totp:123456 -method=ldap username=testuser
```
To set up Microsoft Authenticator App code generation for this purpose, you may follow the same steps outlined [here](path_based_totp_mfa.sh).

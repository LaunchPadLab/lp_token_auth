# Migration Guide
*Note: this guide assumes you are upgrading from LP Token Auth from v1 to v2. This update pertains to the gem `lp_token_auth`. If you want to continue using the previous version of the gem, point the gem to the correct github branch, as found here: https://bundler.io/guides/git.html*

The purpose of this update is to increase the security of our JWT payloads by using JWE.

This version change will end all user sessions. This will requre users to sign in upon implementing the changes. All other features of previous authentication, such as duration are not affected. Aside from re-signing in, users will not be affected.

This version contains the following breaking changes:

1. Includes the [jwe](https://github.com/jwt/ruby-jwe) gem. This will require a `bundle update` to install this gem.

2. Requires 1 new environment variable and an optional environment variable to specify the encryption.
   `JWE_PRIVATE_KEY` contains an RSA key.
   `JWE_ENCRYPTION` is optional and specifies the encryption used. The default encryption is `A256GCM`.

Values for the new settings can alternatively be configured within your LpTokenAuth initializer by setting `LpTokenAuth.config.jwe_private_key` and `LpTokenAuth.config.jwe_encryption`. For example, apps using Rails credentials can set the private key as follows (or point to an ENV variable with a name other than `JWE_PRIVATE_KEY`)
```
LpTokenAuth.config.jwe_private_key = Rails.application.credentials[:jwe_private_key] || ENV['SOME_OTHER_ENV_VARIABLE']
```
The RSA key is generated by running `rails generate lp_token_auth:rsa` in the terminal of your application. This generator will output a formatted RSA key to your console. Directly copy and paste this token as an environment variable with a key of `JWE_PRIVATE_KEY`.

**Common Pitfalls in Copy and Pasting RSA Keys**

The generated RSA key is formatted as a string on a single line with newline characters (\n) at the end of each line. Commonly, there are errors in copy and pasting a string without explicit newline characters.

Please keep in mind this is for the most common use case of using the `JWE_PRIVATE_KEY` in the `.env.[environment]` file. If you are encountering an error during your migration, consider the format of your RSA string.

Be sure to include the `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----` portions of the generated string.
